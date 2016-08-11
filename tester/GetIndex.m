//
//  GetIndex.m
//  Zing
//
//  Created by Kostas on 7/28/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import "GetIndex.h"
#import "SWRevealViewController.h"

@implementation GetIndex

{
    NSMutableArray *contacts;
    UserInfo *userInfo;
    UIActivityIndicatorView *spinner;
}

//**************************************************************************************
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    //initialize user info object
    self.user = [UserInfo user];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableWithNotification:) name:@"GetIndex" object:nil];

    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];

    
    contacts = [[NSMutableArray alloc] init];

    contacts = [[GlobalData shared] GetIndex:self.user.udid];

    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];

}

//******************************************************************
- (void)refreshTableWithNotification:(NSNotification *)notification
{
    [spinner stopAnimating];
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetIndex" object:nil];

}




//******************************************************************
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.tableView reloadData];

}

//******************************************************************
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //We are now visible
    [self.tableView reloadData];
}
//**************************************************************************************
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//******************************************************************
-(void) refreshData{

    //contacts = [[GlobalData shared] GetIndex:self.user.udid];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
   
}

//**************************************************************************************

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [contacts count];
}

//*******************************

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

//**************************************************************************************
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CustomTableCell";
    IndexCell *cell = (IndexCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    
    if (cell == nil) {
        cell = [[IndexCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Location *selectedPerson = [contacts objectAtIndex:indexPath.row];

    cell.title.text = selectedPerson.username;
    cell.subtitle.text = @"";
    
//    BOOL zoomValue = [[NSUserDefaults standardUserDefaults] boolForKey:[selectedPerson udid]];
//    if([selectedPerson.username isEqualToString:[self.user.username stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]) zoomValue=false;
//    
//    [cell.title setEnabled:(zoomValue)];
//    [cell setUserInteractionEnabled:(zoomValue)];
    
    return cell;
}
//**************************************************************************************
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Location *selectedPerson = contacts[indexPath.row];
    if([selectedPerson.udid isEqualToString:self.user.udid]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can't connect with yourself" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else{
        [[GlobalData shared] CreatePair:self.user.udid and:selectedPerson.udid];
    }
   // [self sendAPNS:selectedPerson];

}

//**************************************************************************************

- (void)sendAPNS:(Location *)myContact {

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    NSString *username = myContact.username;
    NSString *eusername = [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *message =  [NSString stringWithFormat:@"%@ wants to zing with you", myContact.username];
    NSString *emessage = [message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSString *uri = URI;
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@notification/%@&%@&%@&request",  uri, eusername, myContact.udid, emessage ]]];
    NSLog(@"notification %@", request.URL);
    
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"set requestReply: %@", requestReply);
        } else {
            NSLog(@"error : %@", error.description);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error Connecting to Server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }] resume];
    
}



@end





//    dispatch_queue_t jsonQueue = dispatch_queue_create("com.jaboston.jsonQueue", NULL);
//    dispatch_async(jsonQueue, ^{
//        contacts = [[GlobalData shared] GetIndex:self.user.udid];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"1111 count = %lu",(unsigned long)[contacts count]);
//        });
//    });
//
//    NSLog(@"1111 count = %lu",(unsigned long)[contacts count]);

//    dispatch_group_t group = dispatch_group_create();
//
//    dispatch_group_async([[GlobalData shared] group],dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
//        // block1
//        NSLog(@"Block1");
//        contacts = [[GlobalData shared] GetIndex:self.user.udid];
//        [NSThread sleepForTimeInterval:5.0];
//        NSLog(@"Block1 End");
//    });
//
//
//    dispatch_group_notify([[GlobalData shared] group],dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
//        // block3
//        NSLog(@"Block3");
//        NSLog(@"1111 count = %lu",(unsigned long)[contacts count]);
//    });
//
//

//    dispatch_async(dispatch_get_main_queue(), ^{
//        contacts = [[GlobalData shared] GetIndex:self.user.udid];
//        [self.tableView reloadData];
//    });

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        contacts = [[GlobalData shared] GetIndex:self.user.udid];
//
//        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
// });
//
//    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:contacts waitUntilDone:YES];

//        dispatch_group_notify([[GlobalData shared] group], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//              NSLog(@"1111 count = %lu",(unsigned long)[contacts count]);
//             [self.tableView reloadData];
//        });

//    dispatch_group_t group = dispatch_group_create();
//
//    // pair a dispatch_group_enter for each dispatch_group_leave
//    dispatch_group_enter(group);     // pair 1 enter
//    [self computeInBackground:1 completion:^{
//        NSLog(@"1 done");
//        dispatch_group_leave(group); // pair 1 leave
//    }];
//
//    // Next, setup the code to execute after all the paired enter/leave calls.
//    //
//    // Option 1: Get a notification on a block that will be scheduled on the specified queue:
//    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        NSLog(@"finally!");
//        NSLog(@"1111 count = %lu",(unsigned long)[contacts count]);
//    });
//
//    [[GlobalData shared] group] = dispatch_group_create();


/*
 dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
 dispatch_group_t group = dispatch_group_create();
 
 // Add a task to the group
 dispatch_group_async(group, queue, ^{
 contacts = [[GlobalData shared] GetIndex:self.user.udid];
 });
 
 
 // Add a handler function for when the entire group completes
 // It's possible that this will happen immediately if the other methods have already finished
 //    dispatch_group_notify(group, queue, ^{
 //          NSLog(@"1111 count = %lu",(unsigned long)[contacts count]);
 //         [self.tableView reloadData];
 //    });
 
 dispatch_group_wait(group,DISPATCH_TIME_FOREVER);
 
 NSLog(@"1111 count = %lu",(unsigned long)[contacts count]);
 [self.tableView reloadData];
 
 
 //    NSLog(@"count = %lu",(unsigned long)[contacts count]);
 //    for(int i=0; i<contacts.count; i++)
 //        NSLog(@"userNAME = %@",[[contacts objectAtIndex:i] username]);
 
 // **************************************************************************************
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 
 SWRevealViewController *revealViewController = self.revealViewController;
 if ( revealViewController )
 {
 [self.sidebarButton setTarget: self.revealViewController];
 [self.sidebarButton setAction: @selector( revealToggle: )];
 [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
 }
 
 //initialize user info object
 self.user = [UserInfo user];
 
 contacts = [[NSMutableArray alloc] init];
 
 [self asynchronousTaskWithCompletion:^(BOOL exists){
 NSLog(@"It finished %i", exists);
 [self.tableView reloadData];
 NSLog(@"2222 count = %lu",(unsigned long)[contacts count]);
 }];
 
 NSLog(@"4444 count = %lu",(unsigned long)[contacts count]);
 
 
 // Initialize the refresh control.
 self.refreshControl = [[UIRefreshControl alloc] init];
 self.refreshControl.backgroundColor = [UIColor whiteColor];
 self.refreshControl.tintColor = [UIColor blackColor];
 [self.refreshControl addTarget:self
 action:@selector(refreshData)
 forControlEvents:UIControlEventValueChanged];
 
 
 
 }
 
 - (void)asynchronousTaskWithCompletion:(void(^)(BOOL exists))completion
 {
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 
 BOOL done = YES;
 // Some long running task you want on another thread
 contacts = [[GlobalData shared] GetIndex:self.user.udid];
 NSLog(@"0000 count = %lu",(unsigned long)[contacts count]);
 if(contacts.count ==0)
 done = NO;
 dispatch_async(dispatch_get_main_queue(), ^{
 
 completion(done);
 NSLog(@"1111 count = %lu",(unsigned long)[contacts count]);
 
 });
 });
 }
*/
