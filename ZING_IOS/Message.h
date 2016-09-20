//
//  Message.h
//  Zing
//
//  Created by imkostas on 9/9/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import <UIKit/UIKit.h> 
#import <MapKit/MapKit.h>

@interface Message : NSObject

@property (nonatomic, strong) NSString *post_ID; //
@property (nonatomic, strong) NSString *sender; //
@property (nonatomic, strong) NSString *recipient; //
@property (nonatomic,retain) NSDate *time_sent;  //
@property (nonatomic, strong) NSString *message; //
@property (nonatomic) BOOL message_read;
@property (nonatomic,retain) NSDate *time_read;  //
@property (nonatomic) BOOL notified;
@property (nonatomic) CLLocationCoordinate2D coordinates;  //

@end
