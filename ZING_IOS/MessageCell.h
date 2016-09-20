//
//  MessageCell.h
//  Zing
//
//  Created by imkostas on 9/16/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageView; //displays message image
@property (strong, nonatomic) IBOutlet UILabel *title; //displays message username
@property (strong, nonatomic) IBOutlet UILabel *subTitle; //displays message date

@end
