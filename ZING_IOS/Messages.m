//
//  Message.m
//  Zing
//
//  Created by imkostas on 9/9/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import "Messages.h"
#import "MessageCell.h"
#import "GlobalData.h"


@interface Messages (){
    NSMutableArray *messages; //mutable array to store chat messages
    NSTimer *timer; //timer to fetch messages

    UIRefreshControl *refreshControl; //refresh controll used when updating table view
}

@end



@implementation Messages

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if(self.user==nil)
        self.user = [UserInfo user];


    messages = [[NSMutableArray alloc] init];
    
    //initializing table view delegate, data source, and separator style
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //tap gesture recognizer added to tableview to dismiss keyboard
    UITapGestureRecognizer *tappedView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTableView:)];
    [self.tableView addGestureRecognizer:tappedView];
    
    //adding callback method to textfield to check when editing changes
    [self.messageTextfield addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    
    //keyboard callbacks
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(liftViewWhenKeybordAppears:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(returnViewToInitialPosition:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(returnViewToInitialPosition:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];

    //initializing messages array
    messages = [[NSMutableArray alloc] init];
    
    
    //initialize timer if a current deal chatroom since old chatrooms won't have new incomming messages
 
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(refreshData) userInfo:nil repeats:YES];
    
     [self refreshData];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor whiteColor];
    refreshControl.tintColor = [UIColor blackColor];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// ******************************************************************
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:(BOOL)animated];
    
    //remove notification observer for data (will be initialized next time screen is loaded)
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GetMessages" object:nil];

}


// ******************************************************************
-(void) getUserMessages:(NSNotification *) notification {
    
    [self.tableView reloadData];
    [refreshControl endRefreshing];

}

-(void) refreshData {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUserMessages:) name:@"GetMessages" object:nil];
    
    NSString *sender = [[NSUserDefaults standardUserDefaults] objectForKey:@"appID"];
    messages = [[GlobalData shared] GetMessages:sender];
    
}


- (void)textFieldDidChange {
    
    //if length is 0 user can't send message, else use can send message
    if(self.messageTextfield.text.length == 0){
        
        [self.sendMessageBtn setEnabled:NO];
        
    } else {
        
        [self.sendMessageBtn setEnabled:YES];
        
    }
    
}

- (void)didTapTableView:(UIGestureRecognizer*)recognizer {
    
    //hide keyboard if active
    [self.messageTextfield resignFirstResponder];
    
}

- (void)keyboardFrameChanged:(NSNotification*)notification {
    
    //show keyboard
    [self scrollViewForKeyboard:notification up:YES];
    
}

- (void)liftViewWhenKeybordAppears:(NSNotification*)notification {
    
    //show keyboard
    [self scrollViewForKeyboard:notification up:YES];
    
}

- (void)returnViewToInitialPosition:(NSNotification*)notification {
    
    //keyboard will hide
    [self scrollViewForKeyboard:notification up:NO];
    
}

- (void)scrollViewForKeyboard:(NSNotification*)notification up:(BOOL)up {
    
    NSDictionary* userInfo = [notification userInfo];
    
    //get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    
    //start of animations
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    // When the iPad is rotated, the keyboard's frame is still given as if it were in portrait mode,
    // so the "height" given is actually the keyboard's width, etc.etc...
    // We use -convertRect: here to find out really where the keyboard is, from the perspective
    // of this ViewController's view
    CGRect correctKeyboardFrame = [[self view] convertRect:keyboardFrame fromView:nil];
    
    //change messageView y position based on keyboard status
    [self.messageView setFrame:CGRectMake(self.messageView.frame.origin.x,
                                          (self.view.bounds.size.height - self.messageView.frame.size.height) - (correctKeyboardFrame.size.height * (up?1:0)),
                                          self.messageView.frame.size.width, self.messageView.frame.size.height)];
    
    //change tableView content inset based on keyboard status
    [self.tableView setContentInset:UIEdgeInsetsMake(10, 0, (correctKeyboardFrame.size.height * (up?1:0)), 0)];
    
    [UIView commitAnimations];
    
}

- (IBAction)cancelView:(id)sender {
    
    //remove observers from notification center
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //kill timer
    [timer invalidate];
    timer = nil;
    
    //pop view controller
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction) sendMessage:(id)sender {

    if([self.messageTextfield.text isEqualToString:@""])return;
    
    NSString *message = self.messageTextfield.text;
    for(int i=0; i<self.user.pairs.count; i++){
        NSString *recipientAppID = [[self.user.pairs objectAtIndex:i] appID];
        if([recipientAppID isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"appID"]])continue;
        
        [[GlobalData shared] sendMessage: message to:recipientAppID];
        [[GlobalData shared] sendNotification:message to:recipientAppID ofType:@"Message"];

       // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"zing://com.thememedesign.zing?token=12345&domain=foo.com"]];
    }
    
    self.messageTextfield.text = @"";
    [self refreshData];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [messages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//       UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    NSString *cellIdentifier =@"MessageCell";
//    
    MessageCell *cell = (MessageCell *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    Message *incoming_message = [[Message alloc] init];
    incoming_message = [messages objectAtIndex:indexPath.row];
    NSLog(@"incoming_message = %@", incoming_message.message);
    
//    NSLog(@"%@", incoming_message.message);
    // Configure the cell...
    if (cell == nil) {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        //cell.textLabel.text = incoming_message.message;
    }
    
    cell.textLabel.text = incoming_message.message;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSString *subtitle = [NSString stringWithFormat:@"Sent on %@",incoming_message.time_sent];
    cell.detailTextLabel.text = subtitle;
   // cell.detailTextLabel.text
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}



#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
