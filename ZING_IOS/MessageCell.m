//
//  MessageCell.m
//  Zing
//
//  Created by imkostas on 9/16/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell

@synthesize imageView;

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    [self.imageView setFrame:CGRectMake(20, 15, 50, 50)];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
