//
//  GetIndex.h
//  Zing
//
//  Created by Kostas on 7/28/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"
#import "GlobalData.h"
#import "IndexCell.h"

@interface GetIndex : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UserInfo *user; //user info
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end
