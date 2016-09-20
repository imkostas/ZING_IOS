//
//  SearchCell.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2016 Zing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ContactsCell : UITableViewCell

//cell for displaying previously searched locations or search results based on search string
@property (strong, nonatomic) IBOutlet UILabel *name; //displays main address
@property (strong, nonatomic) IBOutlet UILabel *phone; //displays city, region, country
@property (nonatomic, weak) IBOutlet UIImageView *photo;
@end
