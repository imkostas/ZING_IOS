//
//  Messages.h
//  Zing
//
//  Created by imkostas on 9/15/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

@interface Messages : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UserInfo *user; //user info

@property (strong, nonatomic) IBOutlet UITableView *tableView; //table view for holding message contents


@property (strong, nonatomic) IBOutlet UILabel *divider;
@property (strong, nonatomic) IBOutlet UIView *messageView; //view for styling message
@property (strong, nonatomic) IBOutlet UITextField *messageTextfield; //for entering message to send
@property (strong, nonatomic) IBOutlet UIButton *sendMessageBtn; //sends message

@end

