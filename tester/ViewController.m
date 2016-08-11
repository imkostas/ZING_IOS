//
//  ViewController.m
//  tester
//
//  Created by Kostas on 6/28/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import "ViewController.h"
#import "SWRevealViewController.h"



@interface ViewController () <UISearchDisplayDelegate, UISearchBarDelegate>{
    
    BOOL updatedLocation;
    UserInfo *userinfo;
    
}

- (void) setupSearchController;
- (void) setupSearchBar;
- (void) searchQuery:(NSString *)query;

@end

@implementation ViewController{
    
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *results;
    
}

@synthesize searchController;
@synthesize localSearch;
@synthesize results;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
   // NSLog(@"DID LOAD");
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }

    if(self.user==nil)
        self.user = [UserInfo user];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllLocations) name:@"SetLocation" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserLocation) name:@"GetAllLocations" object:nil];

     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(error) name:@"error" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserLocation) name:@"updateUserLocation" object:nil];

    ///////////////////////////////////////////
    self.locationManagerSingleton = [LocationManagerSingleton sharedLocationInstance];
    self.user.coordinates = [LocationManagerSingleton sharedLocationInstance].myLocationManager.location.coordinate;
    self.myCurrentLocation = [LocationManagerSingleton sharedLocationInstance].myLocationManager.location;
    
    [[LocationManagerSingleton sharedLocationInstance].myLocationManager startUpdatingLocation];
    
    //////////////////////////////////////////////////

    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.showsUserLocation = YES;
    [self.mapView setUserInteractionEnabled:YES];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    
    self.user.pushDelegate = self;

    // Set up location operators
/////    [self setupLocationManager];
    
    // Set up search operators
    [self setupSearchController];
    [self setupSearchBar];

    updatedLocation = false;
    

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"refresh" object:nil];
    
//    NSTimer *tdata = [NSTimer scheduledTimerWithTimeInterval: 10.0  target: self  selector:@selector(refreshData)  userInfo: nil repeats:YES];
    //[t invalidate];
    // t = nil;
 
//    NSTimer *tmap = [NSTimer scheduledTimerWithTimeInterval: 5.0
//                                                      target: self
//                                                    selector:@selector(refreshMap:)
//                                                    userInfo: nil repeats:YES];

    Location *location = [[Location alloc] init];
    location.username = self.user.username;
    location.udid = self.user.udid;
    location.coordinates = self.user.coordinates;
    [self.user.pairs addObject:location];  //add yourself as the first in list

    [self refreshData];

}

// ********************
-(void) setLocation{
    
    CLLocation *clocation = [[CLLocation alloc] initWithLatitude:self.user.coordinates.latitude longitude:self.user.coordinates.longitude];
    [[GlobalData shared] SetLocation:clocation];

}

// ********************
-(void) getAllLocations{
    
    self.user.pairs = [[GlobalData shared] GetAllLocations:self.user.udid];


}

// **************************************************************************************

-(void)refreshData {

    [self setLocation];
    [self getAllLocations];

}

// *****************************
-(void) error{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You seem not to be connected to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
   // [alertView show];
//    [self.view addSubview:alertView];
//    [UIView animateWithDuration:0.25 animations:^{[alertView setAlpha:1.0f];}];
  
}

// **************************************************************************************

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}







//**************************************************************************************

- (IBAction)refresh:(id)sender {
    
    
    [self refreshData];
    
    [self zoomMapViewToFitAnnotations];
    for(int i=0; i<self.user.pairs.count; i++){
        [[GlobalData shared] sendAPNS: [[self.user.pairs objectAtIndex:i] udid] withMessage:@"hi" andIdentification:@"silent"];
        NSLog(@"%@",[[self.user.pairs objectAtIndex:i] udid]);
    }

}


//**************************************************************************************
#define MINIMUM_ZOOM_ARC 0.014 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.15
#define MAX_DEGREES_ARC 360
//size the mapView region to fit its annotations
- (void)zoomMapViewToFitAnnotations{
    
    NSArray *annotations = self.mapView.annotations;
    unsigned long count = [self.mapView.annotations count];
    if ( count == 0) { return; } //bail if no annotations
    
    MKMapPoint points[count]; //C array of MKMapPoint struct
    for( int i=0; i<count; i++ ) //load points C array by converting coordinates to points
    {
        CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
        points[i] = MKMapPointForCoordinate(coordinate);
        // NSLog(@"%i %f, %f", i, coordinate.latitude, coordinate.longitude);
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
        NSLog(@"ONLY ONE PIN");
    }
    [self.mapView setRegion:region animated:YES];
    
}

//**************************************************************************************//
- (void)updateUserLocation
{
    
    // Remove all previous annotations.
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    //add annotations
    for(int i=0; i<[self.user.pairs count]; i++){
        if([[NSUserDefaults standardUserDefaults] boolForKey:[[self.user.pairs objectAtIndex:i] udid]] == 0)
            continue;
        Pin * point= [[Pin alloc] init];
        point.udid = [[self.user.pairs objectAtIndex:i] udid];
        point.coordinate = [[self.user.pairs objectAtIndex:i] coordinates];
        point.title = [[[self.user.pairs objectAtIndex:i] username] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        point.shouldZoom = YES;
        // Calculate distance to yourself
        CLLocationCoordinate2D pointACoordinate = [[self.user.pairs objectAtIndex:i] coordinates];
        CLLocation *pointALocation = [[CLLocation alloc] initWithLatitude:pointACoordinate.latitude longitude:pointACoordinate.longitude];
        CLLocationCoordinate2D pointBCoordinate = [[self.user.pairs objectAtIndex:0] coordinates];
        CLLocation *pointBLocation = [[CLLocation alloc] initWithLatitude:pointBCoordinate.latitude longitude:pointBCoordinate.longitude];
        double distanceMeters = [pointALocation distanceFromLocation:pointBLocation];
        double distanceMiles = (distanceMeters / 1609.344);
        double distanceFeet = (distanceMeters * 3.28084);
        if(distanceMeters>1610.)  //if less than a mile
            point.subtitle = [NSString stringWithFormat:@"%.2f miles or %.2f km", distanceMiles, distanceMeters/1000.];
        else
            point.subtitle = [NSString stringWithFormat:@"%.2f ft or %.2f m", distanceFeet, distanceMeters];
        if(i==0)continue;  //no pin on yourself
        [self.mapView addAnnotation:point];
        point = nil;
    }
    
    [self zoomMapViewToFitAnnotations];
    
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
        //NSLog(@"Clicked a=%@", ((Pin *)annotation).udid);
        [[GlobalData shared] RemovePair:self.user.udid and:((Pin *)annotation).udid];
        
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

















//  SEARCH MAP
//***********************************************************************************************
//***********************************************************************************************

- (IBAction)searchButton:(id)sender {
    
    if([self.searchController.searchBar isHidden]){
        [self.searchController.searchBar setHidden:NO];
    }
    else{
        [self.searchController.searchBar setHidden:YES];
    }
}

- (IBAction)chatButton:(id)sender {
    
    //    [self.searchController.searchBar isHidden]? [self.searchController.searchBar setHidden:NO]:[self.searchController.searchBar setHidden:YES];
    
    }


//**************************************************************************************
//  SEARCH
// ***************************************
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
// ***************************************
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
// ***************************************
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
// ***************************************
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
// ***************************************
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (![searchText isEqualToString:@""]) {
        [self searchQuery:searchText];
    }
}
// ***************************************
- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    [self searchQuery:aSearchBar.text];
}
// ***************************************
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.results.mapItems count];
}
// ***************************************
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
// ***************************************
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

// ************************************************************************************************

-(void)getPathDirections:(CLLocationCoordinate2D)source withDestination:(CLLocationCoordinate2D)destination{
    
    MKPlacemark *placemarkSrc = [[MKPlacemark alloc] initWithCoordinate:source addressDictionary:nil];
    MKMapItem *mapItemSrc = [[MKMapItem alloc] initWithPlacemark:placemarkSrc];
    MKPlacemark *placemarkDest = [[MKPlacemark alloc] initWithCoordinate:destination addressDictionary:nil];
    MKMapItem *mapItemDest = [[MKMapItem alloc] initWithPlacemark:placemarkDest];
    [mapItemSrc setName:@"name1"];
    [mapItemDest setName:@"name2"];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    [request setSource:mapItemSrc];
    [request setDestination:mapItemDest];
    [request setTransportType:MKDirectionsTransportTypeAutomobile];
    request.requestsAlternateRoutes = NO;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             // Handle Error
         } else {
             [_mapView removeOverlays:_mapView.overlays];
             [self showRoute:response];
         }
     }];
    
}

-(void) showRoute:(MKDirectionsResponse *) response {
    
}


//method to display custom HUD for all server requests
- (void)handlePushNotification:(NSDictionary *)notification withType:(NSString *)type {
    
    NSLog(@"handlePushNotification");
    
    if([type isEqualToString:@"Local Notification"]){
        
        
        
    } else if([type isEqualToString:@"request"]){
        
        NSLog(@"request");
        //[self customAlert:[NSString stringWithFormat:@"%@", [[notification objectForKey:@"aps"] valueForKey:@"alert"]] withDone:@"Ok" withColor:NO withTag:0];
        UIAlertView *newAlertVw = [[UIAlertView alloc] initWithTitle:@"INFO" message:@"hi" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [newAlertVw show];
        
    } else if([type isEqualToString:@"yes"]){
        
       // [self customAlert:[NSString stringWithFormat:@"%@", [[notification objectForKey:@"aps"] valueForKey:@"alert"]] withDone:@"Ok" withColor:NO withTag:0];
        
      //  [self hideCurrentView];
      //  NSLog(@"View should have been hidden");
      //  [self refreshMapPins];
        
    } else if([type isEqualToString:@"no"]){
        
       // [self customAlert:[NSString stringWithFormat:@"%@", [[notification objectForKey:@"aps"] valueForKey:@"alert"]] withDone:@"Ok" withColor:NO withTag:0];
        
    } else if([type isEqualToString:@"postRequested"] || [type isEqualToString:@"respondedToRequest"]){
        
      //  [self refreshMapPins];
        
    }
    
}

@end




//       NSLog(@"count 1 = %lu", count);
//convert NSArray of id <MKAnnotation> into an MKCoordinateRegion that can be used to set the map size
//can't use NSArray with MKMapPoint because MKMapPoint is not an id
//    count=0;
//    for(int i=0; i<[usersToTrack count]; i++)
//        if([[NSUserDefaults standardUserDefaults] boolForKey:[[usersToTrack objectAtIndex:i] udid]] == 1)
//            count++;
//        NSLog(@"count 2 = %lu", count);
//
//    if ( count == 0) { return; } //bail if no annotations
//    MKMapPoint points[count]; //C array of MKMapPoint struct
//    for( int i=0; i<count; i++ ) //load points C array by converting coordinates to points
//    {
//      //  CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
//        CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
//        if ([(id <MKAnnotation>)[annotations objectAtIndex:i] isKindOfClass:[Pin class]])
//            NSLog(@"Clicked a=%@", ((Pin *)(id <MKAnnotation>)[annotations objectAtIndex:i]).udid);
//        if([[NSUserDefaults standardUserDefaults] boolForKey:[[usersToTrack objectAtIndex:i] udid]] == 1){
//            points[i] = MKMapPointForCoordinate(coordinate);
//            NSLog(@"%i %f, %f", i, coordinate.latitude, coordinate.longitude);
//        }

//    }
//        NSLog(@"1111");
//        NSMutableArray *zoomPins;
//        zoomPins = [[NSMutableArray alloc] init];
//        for( int i=0; i<count; i++ ){
//            Pin * pointx = [[Pin alloc] init];
//            pointx = ((Pin *)(id <MKAnnotation>)[annotations objectAtIndex:i]);
//           // if([[NSUserDefaults standardUserDefaults] boolForKey:[pointx udid]] == 1)
//                [zoomPins addObject:pointx];
//            }
//
//        NSLog(@"2222");
//        if(zoomPins.count==0)return;
//        count = zoomPins.count;
//        MKMapPoint points[count];
//        for( int i=0; i<count; i++ ){
//            points[i] = MKMapPointForCoordinate([[zoomPins objectAtIndex:i] coordinates]);
//             NSLog(@"%i %f, %f", i, [[zoomPins objectAtIndex:i] coordinates].latitude, [[zoomPins objectAtIndex:i] coordinates].longitude);
//        }



//**************************************************************************************
/*
 #define MINIMUM_ZOOM_ARC 0.014 //approximately 1 miles (1 degree of arc ~= 69 miles)
 #define ANNOTATION_REGION_PAD_FACTOR 1.15
 #define MAX_DEGREES_ARC 360
 //size the mapView region to fit its annotations
 - (void)zoomMapViewToFitAnnotations{
 
 //    NSArray *annotations = self.mapView.annotations;
 //    unsigned long count = [self.mapView.annotations count];
 //    if ( count == 0) { return; } //bail if no annotations
 
 //    unsigned long count = [usersToTrack count];
 //    if ( count == 0) { return; } //bail if no annotations
 //
 //    count = 0;
 unsigned long count = 0;
 for(int i=0; i<[usersToTrack count]; i++)
 if([[NSUserDefaults standardUserDefaults] boolForKey:[[usersToTrack objectAtIndex:i] udid]] == 1)
 count++;
 NSLog(@"number of points to focus on = %lu", count);
 
 if ( count == 0) { return; } //bail if no annotations
 
 //    CLLocationCoordinate2D *points = malloc([mutablePoints count] * sizeof(CLLocationCoordinate2D));
 //    for(int i = 0; i < [mutablePoints count]; i++) {
 //        [[mutablePoints objectAtIndex:i] getValue:(points + i)];
 //    }
 
 MKMapPoint points[count]; //C array of MKMapPoint struct
 for( int i=0; i<count; i++ ) {//load points C array by converting coordinates to points
 //CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
 if([[NSUserDefaults standardUserDefaults] boolForKey:[[usersToTrack objectAtIndex:i] udid]] == 1){
 UserInfo *user = [[UserInfo alloc] init];
 user = [usersToTrack objectAtIndex:i];
 CLLocationCoordinate2D coordinate = user.coordinates;
 points[i] = MKMapPointForCoordinate(coordinate);
 user = nil;
 }
 }
 
 
 //    NSMutableArray *mpoints;
 //    if(!mpoints) mpoints = [[NSMutableArray alloc] init];
 //    for(int i=0; i<[usersToTrack count]; i++){
 //        if([[NSUserDefaults standardUserDefaults] boolForKey:[[usersToTrack objectAtIndex:i] udid]] == 1)
 //            [mpoints addObject: [NSValue valueWithMKCoordinate:[[usersToTrack objectAtIndex:i] coordinates]]];
 //    }
 //    unsigned long count = mpoints.count;
 //
 //    NSArr points = [mpoints copy];
 
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
 [self.mapView setRegion:region animated:YES];
 
 }
 
 
 
 
 
 NSString *rawText = @"One Broadway, Cambridge, MA";
 NSString *encodedText = [rawText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
 NSLog(@"Encoded text: %@", encodedText);
 NSString *decodedText = [encodedText stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
 NSLog(@"Original text: %@", decodedText);
 
 
 
 */

/*
 // **************************************************************************************
 - (void) updateUserLocation:(NSMutableArray *)locations
 {
 //NSLog(@"updateUserLocation");
 // Remove all previous annotations.
 [self.mapView removeAnnotations:self.mapView.annotations];
 
 NSLog(@"update : count = %lu",(unsigned long)[locations count]);
 //add annotations
 for(int i=0; i<[locations count]; i++){
 if([[NSUserDefaults standardUserDefaults] boolForKey:[[locations objectAtIndex:i] udid]] == 0)
 continue;
 Pin * point= [[Pin alloc] init];
 point.udid = [[locations objectAtIndex:i] udid];
 point.coordinate = [[locations objectAtIndex:i] coordinates];
 point.title = [[[locations objectAtIndex:i] username] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
 point.shouldZoom = YES;
 // Calculate distance to yourself
 CLLocationCoordinate2D pointACoordinate = [[locations objectAtIndex:i] coordinates];
 CLLocation *pointALocation = [[CLLocation alloc] initWithLatitude:pointACoordinate.latitude longitude:pointACoordinate.longitude];
 CLLocationCoordinate2D pointBCoordinate = [[locations objectAtIndex:0] coordinates];
 CLLocation *pointBLocation = [[CLLocation alloc] initWithLatitude:pointBCoordinate.latitude longitude:pointBCoordinate.longitude];
 double distanceMeters = [pointALocation distanceFromLocation:pointBLocation];
 double distanceMiles = (distanceMeters / 1609.344);
 double distanceFeet = (distanceMeters * 3.28084);
 if(distanceMeters>1610.)  //if less than a mile
 point.subtitle = [NSString stringWithFormat:@"%.2f miles or %.2f km", distanceMiles, distanceMeters/1000.];
 else
 point.subtitle = [NSString stringWithFormat:@"%.2f ft or %.2f m", distanceFeet, distanceMeters];
 if(i==0)continue;  //no pin on yourself
 [self.mapView addAnnotation:point];
 point = nil;
 }
 
 //zoom all
 [self zoomMapViewToFitAnnotations];
 
 }
 */

//// **************************************************************************************
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//}
//
//// **************************************************************************************
//- (void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:(BOOL)animated];
//}
//
//// **************************************************************************************
//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//
//    //We are now visible
////    [self refreshData];
//}
//
//// **************************************************************************************
//- (void)viewWillAppear:(BOOL)animated
//{
//  //  [[LocationManagerSingleton sharedLocationInstance].myLocationManager startUpdatingLocation];
//}



// **************************************************************************************
//- (void) getAPIData:(CLLocation *)location
//{
//    CLLocation *userLocation = [[LocationManagerSingleton sharedLocationInstance].myLocationManager location];
//}
//////////////////////////////////////

//Location Manager
//**************************************************************************************
//**************************************************************************************




/*
 
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
 
 
 // **************************************************************************************
 
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
 self.user.coordinates = self.locationManager.location.coordinate;
 } else {
 NSLog(@"Couldn't enable Location Services. Please enable them in Settings > Privacy > Location Services.");
 }
 } else if (status == kCLAuthorizationStatusNotDetermined) {
 NSLog(@"Error : Authorization status not determined.");
 [self.locationManager requestWhenInUseAuthorization];
 }
 }
 
 // **************************************************************************************
 
 - (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
 
 CLLocation * newLocation = [locations lastObject];
 
 if(!updatedLocation && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
 [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) &&
 newLocation.horizontalAccuracy <= 65.0f &&
 newLocation.coordinate.latitude != 0.0 &&
 newLocation.coordinate.longitude != 0.0){
 
 updatedLocation = false;
 
 CLLocationCoordinate2D coordinate;
 coordinate.latitude = newLocation.coordinate.latitude;
 coordinate.longitude = newLocation.coordinate.longitude;
 MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, METERS_PER_MILE, METERS_PER_MILE);
 
 [self.mapView setRegion:viewRegion animated:NO];
 self.mapView.showsUserLocation = YES;
 
 }
 
 }
 
 // **************************************************************************************
 
 - (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
 
 [self.user setUserSpeed:0.0f];
 
 }
 
 //if user has disabled location services, show alert
 // **************************************************************************************
 
 - (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
 
 if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enable Location Services" message:@"To use King, location services must be enabled within Settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
 [alertView show];
 }
 }
 */
// **************************************************************************************
// **************************************************************************************
//- (void)showPins
//{
//
//    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
//
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enable Location Services" message:@"To use Zing, location services must be enabled within Settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//        [alertView show];
//
//    } else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
//              [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
//
//        [self zoomMapViewToFitAnnotations];
//    }
//}
