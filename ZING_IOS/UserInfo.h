//
//  UserInfo.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2016 Zing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "Definitions.h"
#import "LocationManager.h"

@protocol PushControlDelegate

//delegate method
- (void)handlePushNotification:(NSDictionary *)notification withType:(NSString *)type;

@end 

@interface UserInfo : NSObject <UIAlertViewDelegate>

//delegate to handle incoming push notifications
@property (nonatomic, strong) id <PushControlDelegate> pushDelegate;

//app keys/IDs
@property (nonatomic, strong) NSString *appStoreID;

//global back-end paths
@property (nonatomic, strong) NSString *uri;
@property (nonatomic, strong) NSString *img_uri;
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *geocoding_uri;


//Log in variables
@property (nonatomic) BOOL showTutorial;

//user account info
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) UIImage *profileImage;
@property (nonatomic) CLLocationCoordinate2D coordinates;
@property (nonatomic) float userSpeed;
@property (nonatomic, strong) NSString *udid;
@property (nonatomic, strong) NSString *deviceID;
@property (nonatomic) unsigned int deviceType;
@property (nonatomic, strong) NSString *appID;

//user chat info
@property (nonatomic) BOOL chatCanSendMessage;
@property (nonatomic) unsigned int chatType;
@property (nonatomic) unsigned int chatID;
@property (nonatomic, strong) NSString *chatUsername;

//user images
@property (nonatomic, strong) NSCache *userImages;

//boolean to update map pins
@property (nonatomic) BOOL shouldRefreshMapPins;
@property (nonatomic) BOOL shouldPauseRefreshMapPins;

//boolean to display deal response view
@property (nonatomic) BOOL connectedWIthOtherUser;

//boolean to center map after search
@property (nonatomic) BOOL shouldCenterMap;
@property (readwrite, assign) BOOL isZoomed;
@property (nonatomic, strong) NSMutableArray *searches;

@property (nonatomic, strong) NSMutableArray *pairs;

@property (nonatomic) BOOL showTerms;

//class and instance methods
+ (UserInfo *)user;
- (void)receivedNotification:(NSDictionary *)notification withType:(NSString *)type;

@end
