//
//  SearchCell.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2016 Zing, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZoomCell : UITableViewCell

//cell for displaying previously searched locations or search results based on search string
@property (strong, nonatomic) IBOutlet UILabel *name; //displays main address
@property (strong, nonatomic) IBOutlet UILabel *distance; //displays city, region, country
@property (strong, nonatomic) IBOutlet UISwitch *isZoomed;  //Is that person zoomed in?

@end
