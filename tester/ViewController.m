//
//  ViewController.m
//  tester
//
//  Created by Kostas on 6/28/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UISearchDisplayDelegate, UISearchBarDelegate>{
    
    BOOL updatedLocation;
    NSMutableArray *usersToTrack;
    
}

- (void) setupLocationManager;
- (BOOL) enableLocationServices;
- (void) setupSearchController;
- (void) setupSearchBar;
- (void) searchQuery:(NSString *)query;

@end

@implementation ViewController{
    
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *results;
}

//@synthesize ibSearchBar;
@synthesize searchController;
@synthesize localSearch;
@synthesize results;


#define TOP_BAR_HEIGHT 65.0


- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.user = [UserInfo user];
    

    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.showsUserLocation = YES;
    [self.mapView setUserInteractionEnabled:YES];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];

    // Set up location operators
    [self setupLocationManager];
    
    
    // Set up search operators
    [self setupSearchController];
    [self setupSearchBar];


    updatedLocation = false;
    [self refresh];
    
    NSTimer *t = [NSTimer scheduledTimerWithTimeInterval: 10.0
                                                  target: self
                                                selector:@selector(onTick:)
                                                userInfo: nil repeats:YES];
   
}

-(void)onTick:(NSTimer *)timer {

    NSLog(@"Time Refresh");
    [self refresh];
}

//**************************************************************************************

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//Location Manager
//**************************************************************************************
//**************************************************************************************

- (BOOL) enableLocationServices {
    
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager.distanceFilter = 10;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingLocation];
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
        return YES;
    } else {
        return NO;
    }
}


//**************************************************************************************

- (void) setupLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Will call locationManager:didChangeAuthorizationStatus: delegate method
    [CLLocationManager authorizationStatus];
}


- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    NSString *message = @"You must enable Location Services for this app in order to use it.";
    NSString *button = @"Ok";
    NSString *title;
    
    if (status == kCLAuthorizationStatusDenied) {
        title = @"Location Services Disabled";
        [[[UIAlertView alloc] initWithTitle:title
                                    message:message
                                   delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:button, nil] show];
    } else if(status == kCLAuthorizationStatusRestricted) {
        title = @"Location Services Restricted";
        [[[UIAlertView alloc] initWithTitle:title
                                    message:message
                                   delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:button, nil] show];
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // Note: kCLAuthorizationStatusAuthorizedWhenInUse depends on the request...Authorization
        // (Always or WhenInUse)
        if ([self enableLocationServices]) {
            NSLog(@"Location Services enabled.");
        } else {
            NSLog(@"Couldn't enable Location Services. Please enable them in Settings > Privacy > Location Services.");
        }
    } else if (status == kCLAuthorizationStatusNotDetermined) {
        NSLog(@"Error : Authorization status not determined.");
        [self.locationManager requestWhenInUseAuthorization];
    }
}

//**************************************************************************************

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation * newLocation = [locations lastObject];

    if(!updatedLocation && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
                            [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) &&
       newLocation.horizontalAccuracy <= 65.0f &&
       newLocation.coordinate.latitude != 0.0 &&
       newLocation.coordinate.longitude != 0.0){
    
       // NSLog(@"Zoomed in on location!");  /////?????
        updatedLocation = false;
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = newLocation.coordinate.latitude;
        coordinate.longitude = newLocation.coordinate.longitude;
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, METERS_PER_MILE, METERS_PER_MILE);
        
        [self.mapView setRegion:viewRegion animated:YES];
        self.mapView.showsUserLocation = YES;
        
    }
    
}

//**************************************************************************************

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    
    [self.user setUserSpeed:0.0f];
    
}

//if user has disabled location services, show alert
//**************************************************************************************

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enable Location Services" message:@"To use King, location services must be enabled within Settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alertView show];
    }
}

//**************************************************************************************
//**************************************************************************************
- (void)showPins
{
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enable Location Services" message:@"To use King, location services must be enabled within Settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alertView show];
        
    } else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
              [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
     
        [self zoomMapViewToFitAnnotations];
    }
}

//**************************************************************************************
#define MINIMUM_ZOOM_ARC 0.014 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.15
#define MAX_DEGREES_ARC 360
    //size the mapView region to fit its annotations
- (void)zoomMapViewToFitAnnotations
    {
    
    NSArray *annotations = self.mapView.annotations;
    unsigned long count = [self.mapView.annotations count];
    if ( count == 0) { return; } //bail if no annotations
    
    //convert NSArray of id <MKAnnotation> into an MKCoordinateRegion that can be used to set the map size
    //can't use NSArray with MKMapPoint because MKMapPoint is not an id
    MKMapPoint points[count+1]; //C array of MKMapPoint struct
    for( int i=0; i<count; i++ ) //load points C array by converting coordinates to points
    {
        CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
        points[i] = MKMapPointForCoordinate(coordinate);
    }
        points[count] = MKMapPointForCoordinate(self.locationManager.location.coordinate);
    
    //create MKMapRect from array of MKMapPoint
    MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];
    //convert MKCoordinateRegion from MKMapRect
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    //add padding so pins aren't scrunched on the edges
    region.span.latitudeDelta  *= ANNOTATION_REGION_PAD_FACTOR;
    region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
    //but padding can't be bigger than the world
    if( region.span.latitudeDelta > MAX_DEGREES_ARC ) { region.span.latitudeDelta  = MAX_DEGREES_ARC; }
    if( region.span.longitudeDelta > MAX_DEGREES_ARC ){ region.span.longitudeDelta = MAX_DEGREES_ARC; }
    
    //and don't zoom in stupid-close on small samples
    if( region.span.latitudeDelta  < MINIMUM_ZOOM_ARC ) { region.span.latitudeDelta  = MINIMUM_ZOOM_ARC; }
    if( region.span.longitudeDelta < MINIMUM_ZOOM_ARC ) { region.span.longitudeDelta = MINIMUM_ZOOM_ARC; }
    //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
    if( count == 1 )
    {
        region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
    }
    [self.mapView setRegion:region animated:NO];
    
}

////////TEST   TEST  /////////////////////////////////////////
- (void)zoomMapViewToFitAnnotations2
{
    
    NSArray *annotations = self.mapView.annotations;
    unsigned long count = [self.mapView.annotations count];
    if ( count == 0) { return; } //bail if no annotations
    
    //convert NSArray of id <MKAnnotation> into an MKCoordinateRegion that can be used to set the map size
    //can't use NSArray with MKMapPoint because MKMapPoint is not an id
    MKMapPoint points[count+1]; //C array of MKMapPoint struct
    for( int i=0; i<count; i++ ) //load points C array by converting coordinates to points
    {
        CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
        points[i] = MKMapPointForCoordinate(coordinate);
    }
    points[count] = MKMapPointForCoordinate(self.locationManager.location.coordinate);
    
    
    //make a list of users to track
    for(int i=0; i<[usersToTrack count]; i++){
        CLLocationCoordinate2D coordinate = [[usersToTrack objectAtIndex:i] coordinates];
        points[i] = MKMapPointForCoordinate(coordinate);
    }
    
    //create MKMapRect from array of MKMapPoint
    MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];
    //convert MKCoordinateRegion from MKMapRect
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    //add padding so pins aren't scrunched on the edges
    region.span.latitudeDelta  *= ANNOTATION_REGION_PAD_FACTOR;
    region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
    //but padding can't be bigger than the world
    if( region.span.latitudeDelta > MAX_DEGREES_ARC ) { region.span.latitudeDelta  = MAX_DEGREES_ARC; }
    if( region.span.longitudeDelta > MAX_DEGREES_ARC ){ region.span.longitudeDelta = MAX_DEGREES_ARC; }
    
    //and don't zoom in stupid-close on small samples
    if( region.span.latitudeDelta  < MINIMUM_ZOOM_ARC ) { region.span.latitudeDelta  = MINIMUM_ZOOM_ARC; }
    if( region.span.longitudeDelta < MINIMUM_ZOOM_ARC ) { region.span.longitudeDelta = MINIMUM_ZOOM_ARC; }
    //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
    if( count == 1 )
    {
        region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
    }
    [self.mapView setRegion:region animated:NO];
    
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{

    // Remove all previous annotations.
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    //add annotations
    for(int i=0; i<[usersToTrack count]; i++){
        Pin * point= [[Pin alloc] init];
        point.udid = [[usersToTrack objectAtIndex:i] udid];
        point.coordinate = [[usersToTrack objectAtIndex:i] coordinates];
        point.title = [[usersToTrack objectAtIndex:i] username];
        point.shouldZoom = YES;
        NSLog(@"pin %@ (%f, %f)",point.title, point.coordinate.latitude,point.coordinate.longitude);
        point.subtitle = @"I'm here!!!";
        [self.mapView addAnnotation:point];
    }
    
    //zoom all
    [self zoomMapViewToFitAnnotations];
    
    
    
}


//**************************************************************************************

- (IBAction)refresh:(id)sender {
    
    [self refresh];

}

//**************************************************************************************

-(void) refresh{
    
    [self SetLocation];
    [self GetAllLocations];
    [self showPins];
}

//**************************************************************************************

- (void) SetLocation {
    
    NSLog(@"%@set/%@/%@", self.user.uri, self.user.username, self.user.udid );
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@set/%@/%@/%f&%f", self.user.uri, self.user.username, self.user.udid, self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude]]];
    NSLog(@"set %@", request.URL);
    
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
         if (!error) {
             NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
             NSLog(@"set requestReply: %@", requestReply);
         } else {
             NSLog(@"error : %@", error.description);
//             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error Connecting to Server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//             [alertView show];
         }
    }] resume];
    
    

}

//**************************************************************************************

- (void) GetAllLocations {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@getall/%@", self.user.uri, self.user.udid]]];
        NSLog(@"get %@", request.URL);
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            // Success
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSError *jsonError;
                NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
               // NSLog(@"json count = %lu", (unsigned long)[jsonArray count]);
                if (jsonError) { NSLog(@"Error Parsing JSON");
                } else {
                    usersToTrack = [[NSMutableArray alloc] init];
                    for(NSDictionary *item in jsonArray){
                        UserInfo *userinfo = [[UserInfo alloc] init];
                        userinfo.coordinates = CLLocationCoordinate2DMake([[item objectForKey:@"latitude"] floatValue], [[item objectForKey:@"longitude"] floatValue]);
                        userinfo.udid = [item objectForKey:@"udid"];
                        userinfo.username = [item objectForKey:@"username"];
                        //NSLog(@"name: %@ ID: %@ (%f, %f)",userinfo.username, userinfo.device, userinfo.coordinates.latitude, userinfo.coordinates.longitude);
                        [usersToTrack addObject:userinfo];
                    }
                    [self zoomMapViewToFitAnnotations];
                }
            }  else { //Web server is returning an error
            }
        } else {
            NSLog(@"error : %@", error.description);  //Error Connecting to Server
        }
    }] resume];
 
}

//**************************************************************************************

- (void) CreatePair:(NSString *) udid1 and:(NSString *) udid2{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@create/%@&%@", self.user.uri, udid1, udid2]]];
    NSLog(@"set %@", request.URL);
    
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"set requestReply: %@", requestReply);
        } else {
            NSLog(@"error : %@", error.description);
            //             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error Connecting to Server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //             [alertView show];
        }
    }] resume];
 
}

//**************************************************************************************

- (void) RemovePair:(NSString *) udid1 and:(NSString *) udid2{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@remove/%@&%@", self.user.uri, udid1, udid2]]];
    NSLog(@"set %@", request.URL);
    
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"set requestReply: %@", requestReply);
        } else {
            NSLog(@"error : %@", error.description);
            //             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error Connecting to Server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //             [alertView show];
        }
    }] resume];
    
}

//**************************************************************************************

- (void) GetLocation {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@get/%@", self.user.uri, self.user.udid]]];
    NSLog(@"get %@", request.URL);
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            // Success
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSError *jsonError;
                NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                // NSLog(@"json count = %lu", (unsigned long)[jsonArray count]);
                if (jsonError) { NSLog(@"Error Parsing JSON");
                } else {
                    usersToTrack = [[NSMutableArray alloc] init];
                    for(NSDictionary *item in jsonArray){
                        UserInfo *userinfo = [[UserInfo alloc] init];
                        userinfo.coordinates = CLLocationCoordinate2DMake([[item objectForKey:@"latitude"] floatValue], [[item objectForKey:@"longitude"] floatValue]);
                        userinfo.udid = [item objectForKey:@"udid"];
                        userinfo.username = [item objectForKey:@"username"];
                        //NSLog(@"name: %@ ID: %@ (%f, %f)",userinfo.username, userinfo.device, userinfo.coordinates.latitude, userinfo.coordinates.longitude);
                        [usersToTrack addObject:userinfo];
                    }
                    [self zoomMapViewToFitAnnotations];
                }
            }  else { //Web server is returning an error
            }
        } else {
            NSLog(@"error : %@", error.description);  //Error Connecting to Server
        }
    }] resume];
    
}


//**************************************************************************************

- (IBAction)dropPost:(UIGestureRecognizer *)recognizer {
    
    UILongPressGestureRecognizer *recognize = (UILongPressGestureRecognizer *)recognizer;
    if(recognize.state == UIGestureRecognizerStateBegan){
       NSLog(@"LONG TAPPED ");
    }
}




#pragma mark Delegate Methods
//**************************************************************************************
//**************************************************************************************

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[Pin class]])
    {
        NSLog(@"Clicked a=%@", ((Pin *)annotation).udid);
        [self RemovePair:self.user.udid and:((Pin *)annotation).udid];
        
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete User?" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"DELETE", nil];
    [alertView show];
}

//**************************************************************************************
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[Pin class]])
    {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.canShowCallout = YES;
            pinView.calloutOffset = CGPointMake(-7, 0);
            
            // Add a detail disclosure button to the callout.
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinView.rightCalloutAccessoryView = rightButton;
            
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

//**************************************************************************************

- (IBAction)createPair:(id)sender {
    
    [self CreatePair:self.user.udid and:@"whatever"];
    [self CreatePair:self.user.udid and:@"someguy"];
    [self zoomMapViewToFitAnnotations];
}

//  SEARCH MAP
//***********************************************************************************************
//***********************************************************************************************

- (IBAction)searchButton:(id)sender {
    
//    [self.searchController.searchBar isHidden]? [self.searchController.searchBar setHidden:NO]:[self.searchController.searchBar setHidden:YES];

    UIButton* searchButton = (UIButton*)sender;
    if([self.searchController.searchBar isHidden]){
        [searchButton setTitle:@"Hide Search" forState:UIControlStateNormal];
        [self.searchController.searchBar setHidden:NO];
    }
    else{
        [searchButton setTitle:@"Search Map" forState:UIControlStateNormal];
        [self.searchController.searchBar setHidden:YES];
    }
}


//**************************************************************************************


#pragma mark - Search Methods

-(void) setupSearchController {
    
    // The TableViewController used to display the results of a search
    UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    searchResultsController.automaticallyAdjustsScrollViewInsets = NO; // Remove table view insets
    searchResultsController.tableView.dataSource = self;
    searchResultsController.tableView.delegate = self;
    
    // Initialize our UISearchController
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    
}

-(void) setupSearchBar {
    
    // Set search bar dimension and position
    CGRect searchBarFrame = self.searchController.searchBar.frame;
    CGRect viewFrame = self.view.frame;
    self.searchController.searchBar.frame = CGRectMake(searchBarFrame.origin.x,
                                                       searchBarFrame.origin.y,
                                                       viewFrame.size.width,
                                                       44.0);
    
    // Add SearchController's search bar to our view and bring it to front
    [self.mapView addSubview:self.searchController.searchBar];
    [self.mapView bringSubviewToFront:self.searchController.searchBar];
    [self.searchController.searchBar setHidden:YES];
    
}

- (void)searchQuery:(NSString *)query {
    // Cancel any previous searches.
    [self.localSearch cancel];
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = query;
    request.region = self.mapView.region;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    [self.localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (error != nil) {
            [[[UIAlertView alloc] initWithTitle:@"Map Error"
                                        message:[error description]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            return;
        }
        			if ([response.mapItems count] == 0) {
        				[[[UIAlertView alloc] initWithTitle:@"No Results"
        											message:nil
        										   delegate:nil
        								  cancelButtonTitle:@"OK"
        								  otherButtonTitles:nil] show];
        				return;
        			}
        
        self.results = response;
        
        [[(UITableViewController *)self.searchController.searchResultsController tableView] reloadData];
    }];
}

-(void)willPresentSearchController:(UISearchController *)aSearchController {
    
    aSearchController.searchBar.bounds = CGRectInset(aSearchController.searchBar.frame, 0.0f, 0.0f);
    
    // Set the position of the result's table view below the status bar and search bar
    // Use of instance variable to do it only once, otherwise it goes down at every search request
    if (CGRectIsEmpty(_searchTableViewRect)) {
        CGRect tableViewFrame = ((UITableViewController *)aSearchController.searchResultsController).tableView
        .frame;
        tableViewFrame.origin.y = tableViewFrame.origin.y + 64; //status bar (20) + nav bar (44)
        tableViewFrame.size.height =  tableViewFrame.size.height;
        
        _searchTableViewRect = tableViewFrame;
    }
    
    [((UITableViewController *)aSearchController.searchResultsController).tableView setFrame:_searchTableViewRect];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (![searchText isEqualToString:@""]) {
        [self searchQuery:searchText];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    [self searchQuery:aSearchBar.text];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.results.mapItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *IDENTIFIER = @"SearchResultsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
    }
    
    MKMapItem *item = self.results.mapItems[indexPath.row];
    
    cell.textLabel.text = item.placemark.name;
    cell.detailTextLabel.text = item.placemark.addressDictionary[@"Street"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Hide search controller
    [self.searchController setActive:NO];
    
    MKMapItem *item = self.results.mapItems[indexPath.row];
    
//    NSLog(@"Selected \"%@\"", item.placemark.name);
    
//    [self.mapView addAnnotation:item.placemark];
//    [self.mapView selectAnnotation:item.placemark animated:YES];
    
    [self.mapView setCenterCoordinate:item.placemark.location.coordinate animated:YES];
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone];
    
}
@end



