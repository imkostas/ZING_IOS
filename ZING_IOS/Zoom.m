//
//  Search.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2016 Zing, Inc. All rights reserved.
//

#import "Zoom.h"


@interface Zoom () {
   
    BOOL switchStatus;
    BOOL gotAllLocations;
    BOOL gotIndex;
    UIActivityIndicatorView *spinner;
}

@end

@implementation Zoom {
    
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    /////////////////////////test
    
//    NSLog(@"[GlobalData shared].units = %d", [GlobalData shared].units );
    
    NSMutableDictionary *savedProfile;
    NSArray *locationArray;
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", docDir, @"LocationArray.plist"];
    
    savedProfile = [[NSMutableDictionary alloc] initWithContentsOfFile:fullPath];
    
    if (savedProfile)
    {
        //Sort
        locationArray = [[savedProfile objectForKey:@"LocationArray"] sortedArrayUsingDescriptors:@[ [[NSSortDescriptor alloc] initWithKey:@"Time" ascending:0]]];
        NSMutableArray *temp = @[].mutableCopy;
        for (NSDictionary *dic in locationArray)
        {
            if ([dic objectForKey:@"Accuracy"]) [temp addObject:dic];
        }
        locationArray = temp;
    }
    
    //NSLog(@"count = %lu", (unsigned long)locationArray.count);
    for(int i=0; i<locationArray.count; i++){
        NSDictionary *dic = [locationArray objectAtIndex:i];
        NSString *appState = [NSString stringWithFormat:@"App State : %@",  [dic[@"AppState"] stringByReplacingOccurrencesOfString:@"UIApplicationState" withString:@""] ];
        NSDate *date = dic[@"Time"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm";
        NSString *time = [dateFormatter stringFromDate:date];
        
        if ([dic objectForKey:@"Accuracy"])
        {
            NSString *accuracy = [NSString stringWithFormat:@"Accuracy : %@",dic[@"Accuracy"]];
            NSString *location = [NSString stringWithFormat:@"Location : %.06f , %.06f",[dic[@"Latitude"] floatValue],[dic[@"Longitude"] floatValue]];
            NSString *addFromResum = [NSString stringWithFormat:@"Add From Resume : %@",[[dic objectForKey:@"AddFromResume"] boolValue] ? @"YES" : @"NO"];
            
            NSLog(@"%@\n%@\n%@\n%@\n%@",appState,addFromResum,accuracy,location,time);
        }
        else if ([dic objectForKey:@"Resume"])
        {
            NSLog(@"%@\n%@\n%@\n\n",appState,dic[@"Resume"],time);
        }
        else
        {
            NSLog(@"%@\n%@\n%@\n\n",appState,dic[@"applicationStatus"],time);
        }
        
    }
    
    ////////////////////////////test

    
    //initialize user info
    self.user = [UserInfo user];
    

   
    
    // Get data from the server
   // [self setEditing:YES animated:YES];
    [self refreshData];

    //initialize Spinner
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];

    // Initialize the refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];

}

// ******************************************************************
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
}

// ******************************************************************
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

// ******************************************************************
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:(BOOL)animated];
    
    //remove notification observer for data (will be initialized next time screen is loaded)
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetAllLocations" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetIndex" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CreatePair" object:nil];
    

}
// ******************************************************************
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

// ******************************************************************
-(void) getUsersToTrack {

        [spinner stopAnimating];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    
}
// ******************************************************************
-(void) refreshData {
    
    //notifcation to keep track of when data is loaded
    gotIndex        = false;
    gotAllLocations = false;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUsersToTrack) name:@"GetAllLocations" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUsersToTrack) name:@"GetIndex" object:nil];
    
    // The most important: init and read the data
    self.user.pairs = [[GlobalData shared] GetAllLocations:self.user.udid];
    self.index = [[NSMutableArray alloc] init];
    self.index = [[GlobalData shared] GetIndex:self.user.udid];
    
}

// *****************************
-(void) refreshPairs{
    
  //  [self refreshData];
}

// ****************************************************************** RESET
- (IBAction)buttonPressed:(UIButton *)sender
{
    for(int i=0; i<[self.user.pairs count]; i++)
        switchStatus = [[NSUserDefaults standardUserDefaults] boolForKey:[[self.user.pairs objectAtIndex:i] udid]];
    [self.tableView reloadData];
}

// ******************************************************************
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //only one section is needed
    return 1;
    
}

// ******************************************************************
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //height for custom cell
	return 55;
    
}

//******************************************************************
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.index count];
}



// ******************************************************************
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CustomTableCell";
    ZoomCell *cell = (ZoomCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[ZoomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
  
    User *selectedPerson = [[User alloc] init];
    selectedPerson = [self.index objectAtIndex:indexPath.row];

    BOOL active = false;
    for(int i=0; i<self.user.pairs.count; i++)
        if([[selectedPerson udid] isEqualToString:[[self.user.pairs objectAtIndex:i] udid]])
            active=true;
    
     if([[selectedPerson udid] isEqualToString:self.user.udid])
         active=true;

    if(!active){
        //Candidate names
        cell.name.textColor = [UIColor lightGrayColor];
        cell.name.text = selectedPerson.username;
        cell.distance.text = @"Click here to pair up";
        [cell.isZoomedSwitch setHidden:true];
    }
    else{
        //Name
        //cell.name.textColor = [UIColor blackColor];
        cell.name.text = selectedPerson.username; //stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //Distance
        CLLocationCoordinate2D pointACoordinate = [selectedPerson coordinates];
       // NSLog(@"%f" , [selectedPerson coordinates].latitude);
        CLLocation *pointALocation = [[CLLocation alloc] initWithLatitude:pointACoordinate.latitude longitude:pointACoordinate.longitude];
        CLLocationCoordinate2D pointBCoordinate = [[LocationManager sharedManager] myLocation];
        CLLocation *pointBLocation = [[CLLocation alloc] initWithLatitude:pointBCoordinate.latitude longitude:pointBCoordinate.longitude];
        double distanceMeters = [pointALocation distanceFromLocation:pointBLocation];
        double distanceMiles = (distanceMeters / 1609.344);
        double distanceFeet = (distanceMeters * 3.28084);
        if(indexPath.row>0){
            if(distanceMeters>1610.)
                if([[NSUserDefaults standardUserDefaults] boolForKey:@"units"])
                  cell.distance.text = [NSString stringWithFormat:@"%.2f km", distanceMeters/1000.];
                else
                  cell.distance.text = [NSString stringWithFormat:@"%.2f miles", distanceMiles];
            else
                if([[NSUserDefaults standardUserDefaults] boolForKey:@"units"])
                  cell.distance.text = [NSString stringWithFormat:@"%.2f m", distanceMeters];
                else
                  cell.distance.text = [NSString stringWithFormat:@"%.2f ft", distanceFeet];
            [cell.isZoomedSwitch setHidden:false];
        }
        //Zoom button
        BOOL zoomValue = [[NSUserDefaults standardUserDefaults] boolForKey:[[self.index objectAtIndex:indexPath.row] udid]];
        [cell.isZoomedSwitch setOn: zoomValue];
        [cell.isZoomedSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    }

    return cell;
}

// *******************************<<<<<<<<<<<<<<<
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ZoomCell *cell = (ZoomCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.isZoomedSwitch setOn:!cell.isZoomedSwitch.on animated:YES];
    
    User *user = [[User alloc] init];
    user = [self.index objectAtIndex:indexPath.row];

        
    if([cell.isZoomedSwitch isHidden])
    {
        
        if([user.udid isEqualToString:self.user.udid]){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can't connect with yourself" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        else{
            NSLog(@"ASK ME = %d", [GlobalData shared].askMe);
         //   if([GlobalData shared].askMe)
           [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUsersToTrack) name:@"CreatePair" object:nil];
                [[GlobalData shared] CreatePair:self.user.udid and:user.udid];
         //   else
         //       [[GlobalData shared] sendNotification:[NSString stringWithFormat:@"%@ wants to pair with you", self.user.username] to:user.appID ofType:@"CreatePair"];
            //[self refreshData];
        }

    }
    else{
        if(cell.isZoomedSwitch.isOn){
//            [[GlobalData shared] CreatePair:self.user.udid and:location.udid];
//            [self refreshData];
        }
        else{
//            [[GlobalData shared] RemovePair:self.user.udid and:location.udid];
//            [self refreshData];
        }
        
        [self switchChanged:cell.isZoomedSwitch];
        [[NSUserDefaults standardUserDefaults] setBool:switchStatus forKey:user.udid];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }


}

// *******************************
-(void) switchChanged:(id)sender {
    UISwitch* switcher = (UISwitch*)sender;
    switchStatus = switcher.on;
}



// ******************************************************************
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    ZoomCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if([selectedCell.isZoomedSwitch isHidden])
        return false;
    else
        return true;
    
}

// ****************************************************************
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        self.indexPathToBeDeleted = indexPath;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UNPAIR USER?"
                                                        message:@"You can always pair again later"
                                                       delegate:self
                                              cancelButtonTitle:@"NO"
                                              otherButtonTitles:@"YES", nil];
        [alert show];
    }

}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Set NSString for button display text here.
    NSString *newTitle = @"UNPAIR";
    return newTitle;
    
}

// ****************************************************************
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"NO"])
    {
        [self.tableView reloadData];
    }
    else if([title isEqualToString:@"YES"])
    {
        //add code here for when you hit delete
        User *user = [[User alloc] init];
        user = [self.index objectAtIndex:self.indexPathToBeDeleted.row];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removePair) name:@"RemovePair" object:nil];
        [[GlobalData shared] RemovePair:self.user.udid and:user.udid];
        [[GlobalData shared] sendNotification:[NSString stringWithFormat:@"%@ has unpaired you", self.user.username] to:user.appID ofType:@"RemovePair"];
        // delete cell
        [self.index removeObjectAtIndex:[self.indexPathToBeDeleted row]];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.indexPathToBeDeleted] withRowAnimation:UITableViewRowAnimationFade];
        
        
    }
}

-(void) removePair {
    
    [self refreshData];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self.index exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];

}

@end


//    Location *location = [[Location alloc] init];
//
//    location = [self.user.pairs objectAtIndex:indexPath.row];
//    cell.name.text = [location.username stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];  //]NSASCIIStringEncoding];
//                    CLLocationCoordinate2D pointACoordinate = [location coordinates];
//                    CLLocation *pointALocation = [[CLLocation alloc] initWithLatitude:pointACoordinate.latitude longitude:pointACoordinate.longitude];
//                    CLLocationCoordinate2D pointBCoordinate = self.user.coordinates;
//                    CLLocation *pointBLocation = [[CLLocation alloc] initWithLatitude:pointBCoordinate.latitude longitude:pointBCoordinate.longitude];
//                    double distanceMeters = [pointALocation distanceFromLocation:pointBLocation];
//                    double distanceMiles = (distanceMeters / 1609.344);
//                    double distanceFeet = (distanceMeters * 3.28084);
//    if(indexPath.row>0){
//        if(distanceMeters>1610.)
//            cell.distance.text = [NSString stringWithFormat:@"%.2f miles/%.2f km", distanceMiles, distanceMeters/1000.];
//        else
//            cell.distance.text = [NSString stringWithFormat:@"%.2f ft or %.2f m", distanceFeet, distanceMeters];
//    }
//        BOOL zoomValue = [[NSUserDefaults standardUserDefaults] boolForKey:[[self.user.pairs objectAtIndex:indexPath.row] udid]];
//        [cell.isZoomedSwitch setOn: zoomValue];
//
//    [cell.isZoomedSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];




//    [self switchChanged:cell.isZoomedSwitch];
//    [[NSUserDefaults standardUserDefaults] setBool:value forKey:location.udid];
//    NSLog(@"%lu username = %@ value = %i", indexPath.row, [self.user username], value);
//    [[NSUserDefaults standardUserDefaults] synchronize];
//CHeck if user selects all zooms off
//    int noZooms = 0;
//    for(int i=0; i<self.user.pairs.count; i++)
//        if([[NSUserDefaults standardUserDefaults] boolForKey:[[self.user.pairs objectAtIndex:i] udid]]==1)
//            noZooms++;
//    if(noZooms==0){
//        value = true;
//        [[NSUserDefaults standardUserDefaults] setBool:value forKey:location.udid];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        [cell.isZoomedSwitch setOn:value animated:YES];
//        return;
//    }

