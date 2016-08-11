//
//  Search.h
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2016 Zing, Inc. All rights reserved.
//


#import "ContactsCell.h"
#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "UserInfo.h"

@interface ContactsVC : UITableViewController <MFMessageComposeViewControllerDelegate>

//@property (nonatomic, assign) NSInteger numberOfPeople;
//@property (nonatomic, strong) NSArray *allPeople;

@property (strong, nonatomic) UserInfo *user; //user info

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end
