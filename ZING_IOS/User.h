//
//  User.h
//  Zing
//
//  Created by imkostas on 9/3/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface User : NSObject



@property (nonatomic, strong) NSString *username; // name of user
@property (nonatomic, strong) NSString *udid; // device id
@property (nonatomic, strong) NSString *appID; // app token
@property (nonatomic) CLLocationCoordinate2D coordinates;  //coords
@property (nonatomic,retain) NSDate *time;  // time

@end

