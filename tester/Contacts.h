//
//  Contacts.h
//  Zing
//
//  Created by Kostas on 8/21/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import "ContactsCell.h"
#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "UserInfo.h"

@interface Contacts : UITableViewController <MFMessageComposeViewControllerDelegate>

//@property (nonatomic, assign) NSInteger numberOfPeople;
//@property (nonatomic, strong) NSArray *allPeople;

@property (strong, nonatomic) UserInfo *user; //user info

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end
