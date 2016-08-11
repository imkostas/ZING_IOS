//
//  IndexCell.m
//  Zing
//
//  Created by Kostas on 8/9/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import "IndexCell.h"

@implementation IndexCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
