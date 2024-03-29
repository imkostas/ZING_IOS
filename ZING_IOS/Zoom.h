//
//  Search.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2016 Zing, Inc. All rights reserved.
//

#import "UserInfo.h"
#import "Address.h"
#import "ZoomCell.h"
#import "Map.h"
#import "User.h"

@interface Zoom : UITableViewController <UITableViewDelegate, UITableViewDataSource>


//view variables
@property (nonatomic, strong) UserInfo *user; //user info

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property (strong, nonatomic) NSIndexPath *indexPathToBeDeleted;
@property (nonatomic, strong) NSMutableArray *index;
@end
