//
//  Map.m
//  Zing
//
//  Created by Kostas on 8/21/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import "Map.h"
#import "LocationManager.h"



@interface Map () <UISearchDisplayDelegate, UISearchBarDelegate>{
    
    UserInfo *userinfo;
    
    
}

- (void) setupSearchController;
- (void) setupSearchBar;
- (void) searchQuery:(NSString *)query;

@end

@implementation Map{
    
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *results;
    
}

@synthesize searchController;
@synthesize localSearch;
@synthesize results;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if(self.user==nil)
        self.user = [UserInfo user];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllLocations) name:@"SetLocation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserLocation) name:@"GetAllLocations" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(error) name:@"error" object:nil];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserLocation) name:@"updateUserLocation" object:nil];
    
    // Set up location operators
    self.user.coordinates = [[LocationManager sharedManager] myLocation];
    
    // Setup map
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.showsUserLocation = YES;
    [self.mapView setUserInteractionEnabled:YES];
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    
    self.user.pushDelegate = self;
    
    // Set up search operators
    [self setupSearchController];
    [self setupSearchBar];
    
    //  NSTimer *tdata = [NSTimer scheduledTimerWithTimeInterval: 10.0  target: self  selector:@selector(refreshMap)  userInfo: nil repeats:YES];
    //  [t invalidate];
    //  t = nil;
    
    //  NOT NEEDED?????
    User *me = [[User alloc] init];
    me.username = self.user.username;
    me.udid = self.user.udid;
    me.coordinates = self.user.coordinates;
    [self.user.pairs addObject:me];  //add yourself as the first in list
    
    [self refreshMap];
    
}

// ******************************************************************
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshMap];
    
}

// ********************
-(void) setLocation{
    
    CLLocation *clocation = [[CLLocation alloc] initWithLatitude:[[LocationManager sharedManager] myLocation].latitude longitude:[[LocationManager sharedManager] myLocation].longitude];
    [[GlobalData shared] SetLocation:clocation];
    
}

// ********************
-(void) getAllLocations{
    
    self.user.pairs = [[GlobalData shared] GetAllLocations:self.user.udid];
    
    
}

// **************************************************************************************

-(void)refreshMap {
    
    [self setLocation];
    [self getAllLocations];
    
}

// *****************************
-(void) error{
    
    //    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You seem not to be connected to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    [alertView show];
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
    
    
    [self refreshMap];
    
    [self zoomMapViewToFitAnnotations];
    for(int i=0; i<self.user.pairs.count; i++){
        [[GlobalData shared] sendAPNS: self.user.username withUDID:[[self.user.pairs objectAtIndex:i] udid] withMessage:@"hi" andIdentification:@"silent"];
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
        // NSLog(@"ONLY ONE PIN");
    }
    [self.mapView setRegion:region animated:YES];
    
}

//**************************************************************************************//
- (void)updateUserLocation
{
    
    //NSLog(@"updateUserLocation");
    // Remove all previous annotations.
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    // Add annotations again based on updated data
    for(int i=0; i<[self.user.pairs count]; i++){
        if([[NSUserDefaults standardUserDefaults] boolForKey:[[self.user.pairs objectAtIndex:i] udid]] == 0)
            continue;
        Pin * point= [[Pin alloc] init];
        point.udid = [[self.user.pairs objectAtIndex:i] udid];
        point.coordinate = [[self.user.pairs objectAtIndex:i] coordinates];
        point.title = [[[self.user.pairs objectAtIndex:i] username] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        point.name = [[[self.user.pairs objectAtIndex:i] username] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        point.shouldZoom = YES;
        // Calculate distance to yourself
        CLLocationCoordinate2D pointACoordinate = [[self.user.pairs objectAtIndex:i] coordinates];
        CLLocation *pointALocation = [[CLLocation alloc] initWithLatitude:pointACoordinate.latitude longitude:pointACoordinate.longitude];
        CLLocationCoordinate2D pointBCoordinate = [[LocationManager sharedManager] myLocation];
        CLLocation *pointBLocation = [[CLLocation alloc] initWithLatitude:pointBCoordinate.latitude longitude:pointBCoordinate.longitude];
        double distanceMeters = [pointALocation distanceFromLocation:pointBLocation];
        double distanceMiles = (distanceMeters / 1609.344);
        double distanceFeet = (distanceMeters * 3.28084);
        NSNumberFormatter * formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:2];
        NSString *distanceFeetComma =  [formatter stringFromNumber:[NSNumber numberWithFloat:distanceFeet]];
        if(distanceMeters>1610.)  //if less than a mile
            point.subtitle = [NSString stringWithFormat:@"%.2f miles or %.2f km", distanceMiles, distanceMeters/1000.];
        else
            point.subtitle = [NSString stringWithFormat:@"%@ ft or %.2f m", distanceFeetComma, distanceMeters];
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
    if ([annotation isKindOfClass:[Pin class]]){
        udidToDelete = ((Pin *)annotation).udid;
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"UNPAIR USER?" message:@"You can always pair again later" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
    [alertView show];
}

// ****************************************************************
NSString *udidToDelete;
// ****************************************************************
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Cancel"])
    {
        [self refreshMap];
    }
    else if([title isEqualToString:@"YES"])
    {
        //add code here for when you hit delete
        [[GlobalData shared] RemovePair:self.user.udid and:udidToDelete];
        [[GlobalData shared] sendAPNS: self.user.username withUDID: udidToDelete withMessage:[NSString stringWithFormat:@"%@ has unpaired you", self.user.username] andIdentification:@"RemovePair"];
        [self refreshMap];
    }
}


//**************************************************************************************
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView *pinView = nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[Pin class]])
    {
        Pin *a = (Pin *)annotation;
        // Try to dequeue an existing pin view first.
        pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
        pinView = [self createPin:pinView withAnnotation:a];
        
        return pinView;
    }
    return nil;
}


// *********************************************************************************************
-(MKPinAnnotationView *) createPin: (MKPinAnnotationView *)pinView withAnnotation: (Pin *)a{
    
    CGSize size = [[[NSAttributedString alloc] initWithString:@"1" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Medium" size:25]}] boundingRectWithSize:CGSizeMake(230.0f, 999.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    int width = (size.width < 25) ? 34 : size.width + 20;
    int shadowWidth = (size.width < 25) ? 33 : size.width + 24;
    
    UIImageView *pinShadow;
    UIImageView *pinStemShadow;
    
    if (!pinView)
    {
        // If an existing pin view was not available, create one.
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:a reuseIdentifier:@"pin"];
        
        pinShadow = [[UIImageView alloc]init];
        pinShadow.frame = CGRectMake((pinView.bounds.origin.x + pinView.bounds.size.width)/2 - shadowWidth/2 + 4, pinView.bounds.origin.y + 3, shadowWidth, 33);
        pinShadow.image = [[UIImage imageNamed:@"PinShadow2"] resizableImageWithCapInsets:UIEdgeInsetsMake(23.0f, 23.0f, 23.0f, 23.0f) resizingMode:UIImageResizingModeStretch];
        
        pinStemShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PinStemShadow2"]];
        pinStemShadow.frame = CGRectMake((pinView.bounds.origin.x + pinView.bounds.size.width)/2 - 8, pinView.bounds.origin.y + 32, 9, 9);
    }
    pinView.canShowCallout = YES;
    pinView.calloutOffset = CGPointMake(-7, 0);
    
    // Add a detail disclosure button to the callout.
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pinView.rightCalloutAccessoryView = rightButton;
    
    UIImageView *pinStem = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"pin_stem"]];
    pinStem.frame = CGRectMake((pinView.bounds.origin.x + pinView.bounds.size.width)/2 - 9.5,
                               pinView.bounds.origin.y + 18, 4, 24);
    
    UIImageView *pinCircle = [[UIImageView alloc] initWithFrame:CGRectMake((pinView.bounds.origin.x + pinView.bounds.size.width)/2 - width/2 - 7, pinView.bounds.origin.y - 5, width, 34)];
    
    //set label view
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18, 16, 26, 26)];
    label.frame = CGRectMake(pinView.bounds.origin.x + (pinView.bounds.size.width/2) - width/2+1 , pinView.bounds.origin.y, size.width, label.frame.size.height);
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"AvenirNext-Medium" size:24];
    label.text = [[a.title substringToIndex:1] uppercaseString];
    //NSLog(@"----- %@ %@ %@", annotation.title, a.title, a.name);
    
    
    pinCircle.image = [[UIImage imageNamed:@"pin_circle_blue"] resizableImageWithCapInsets:UIEdgeInsetsMake(17.0f, 17.0f, 17.0f, 17.0f) resizingMode:UIImageResizingModeStretch];
    
    [pinView addSubview:pinShadow];
    [pinView addSubview:pinStemShadow];
    [pinView addSubview:pinStem];
    [pinView addSubview:pinCircle];
    [pinView addSubview:label];
    
    return pinView;
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

// ***************************************************

- (IBAction)chatButton:(id)sender {
    
    //    [self.searchController.searchBar isHidden]? [self.searchController.searchBar setHidden:NO]:[self.searchController.searchBar setHidden:YES];
    
    NSArray *recipients = [NSArray arrayWithObject:@"57ED0C07BD0081A7F07650B749AC200338C61F3A254D13D9B0F7CBE2066B000C"];
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipients];
    [messageController setBody:@"message to be sent"];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
    
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
        {
            NSLog(@"CANCELED");
            break;
        }
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            NSLog(@"SENT");
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    NSString *theMessage = [[[notification objectForKey:@"aps"] objectForKey:@"alert"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *title;
    
    if([type isEqualToString:@"RemovePair"]){
        title = @"Removed Pair";
    } else if([type isEqualToString:@"CreatePair"]){
        title = @"Create Pair";
    }else if([type isEqualToString:@"request"]){
        title = @"Requested Pair";
    }  else if([type isEqualToString:@"yes"]){
        
        
    } else if([type isEqualToString:@"no"]){
        
    } else if([type isEqualToString:@"postRequested"] || [type isEqualToString:@"respondedToRequest"]){
        
    }
    
    UIAlertView *newAlertVw = [[UIAlertView alloc] initWithTitle:title message:theMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [newAlertVw show];
    
    [self refreshMap];
    
}

@end