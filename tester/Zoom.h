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

@interface Zoom : UITableViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

//search view contents
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar; //search bar for entering search location
@property (strong, nonatomic) IBOutlet UIButton *cancelSearchBtn; //dismisses search view

//view variables
@property (nonatomic, strong) UserInfo *user; //user info

@end
