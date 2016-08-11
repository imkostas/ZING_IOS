//
//  Search.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2016 Zing, Inc. All rights reserved.
//

#import "Zoom.h"
#import "SWRevealViewController.h"

@interface Zoom () {
   
    BOOL value;
    NSMutableDictionary *zdic;
    UIActivityIndicatorView *spinner;
}

@end

@implementation Zoom

{
    
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    //initialize user info
    self.user = [UserInfo user];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUsersToTrack) name:@"GetAllLocations" object:nil];

    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];

    self.user.pairs = [[GlobalData shared] GetAllLocations:self.user.udid];

    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(getUsersToTrack)
                  forControlEvents:UIControlEventValueChanged];

}

//******************************************************************
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

//******************************************************************
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

//******************************************************************
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:(BOOL)animated];

}
//******************************************************************
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}


//******************************************************************
-(void) getUsersToTrack{
    
 //   self.user.pairs = [[GlobalData shared] GetAllLocations:self.user.udid];

    [spinner stopAnimating];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetAllLocations" object:nil];
    
    
}

//******************************************************************
- (IBAction)buttonPressed:(UIButton *)sender
{
    for(int i=0; i<[self.user.pairs count]; i++)
        value = [[NSUserDefaults standardUserDefaults] boolForKey:[[self.user.pairs objectAtIndex:i] udid]];
    [self.tableView reloadData];
}

//******************************************************************
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //only one section is needed
    return 1;
    
}

//******************************************************************
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //height for custom cell
	return 55;
    
}


//******************************************************************
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CustomTableCell";
    ZoomCell *cell = (ZoomCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[ZoomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Display user in the table cell
    Location *location = [[Location alloc] init];
    
    location = [self.user.pairs objectAtIndex:indexPath.row];
    cell.name.text = [location.username stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];  //]NSASCIIStringEncoding];
                    CLLocationCoordinate2D pointACoordinate = [location coordinates];
                    CLLocation *pointALocation = [[CLLocation alloc] initWithLatitude:pointACoordinate.latitude longitude:pointACoordinate.longitude];
                    CLLocationCoordinate2D pointBCoordinate = self.user.coordinates;
                    CLLocation *pointBLocation = [[CLLocation alloc] initWithLatitude:pointBCoordinate.latitude longitude:pointBCoordinate.longitude];
                    double distanceMeters = [pointALocation distanceFromLocation:pointBLocation];
                    double distanceMiles = (distanceMeters / 1609.344);
                    double distanceFeet = (distanceMeters * 3.28084);
    if(indexPath.row>0){
        if(distanceMeters>1610.)
            cell.distance.text = [NSString stringWithFormat:@"%.2f miles/%.2f km", distanceMiles, distanceMeters/1000.];
        else
            cell.distance.text = [NSString stringWithFormat:@"%.2f ft or %.2f m", distanceFeet, distanceMeters];
    }
        BOOL zoomValue = [[NSUserDefaults standardUserDefaults] boolForKey:[[self.user.pairs objectAtIndex:indexPath.row] udid]];
        [cell.isZoomedSwitch setOn: zoomValue];
    
    [cell.isZoomedSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];

    return cell;
}

//*******************************<<<<<<<<<<<<<<<
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ZoomCell *cell = (ZoomCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.isZoomedSwitch setOn:!cell.isZoomedSwitch.on animated:YES];
    
    Location *location = [[Location alloc] init];
    location = [self.user.pairs objectAtIndex:indexPath.row];
    [self switchChanged:cell.isZoomedSwitch];
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:location.udid];
//    NSLog(@"%lu username = %@ value = %i", indexPath.row, [self.user username], value);
    [[NSUserDefaults standardUserDefaults] synchronize];
    //CHeck if user selects all zooms off
    int noZooms = 0;
    for(int i=0; i<self.user.pairs.count; i++)
        if([[NSUserDefaults standardUserDefaults] boolForKey:[[self.user.pairs objectAtIndex:i] udid]]==1)
            noZooms++;
    if(noZooms==0){
        value = true;
        [[NSUserDefaults standardUserDefaults] setBool:value forKey:location.udid];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [cell.isZoomedSwitch setOn:value animated:YES];
        return;
    }


}

//*******************************
-(void) switchChanged:(id)sender {
    UISwitch* switcher = (UISwitch*)sender;
    value = switcher.on;
}



//******************************************************************
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return false;
    
}

//******************************************************************
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.user.pairs count];
}





@end
