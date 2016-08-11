//
//  Location.h
//  Zing
//
//  Created by Kostas on 7/30/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Location : NSObject

@property (nonatomic, strong) NSString *username; // name of user
@property (nonatomic, strong) NSString *udid; // device token
@property (nonatomic) CLLocationCoordinate2D coordinates;  //coords

@end
