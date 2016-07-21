//
//  UserInfo.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2015 Organic Parking, Inc. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

//synthesize user variables
@synthesize pushDelegate;

@synthesize appID;

@synthesize uri;
@synthesize img_uri;
@synthesize apiKey;
@synthesize geocoding_uri;


@synthesize showTutorial;

@synthesize username;
@synthesize email;
@synthesize phone;
@synthesize profileImage;
@synthesize coordinates;
@synthesize userSpeed;
@synthesize udid;
@synthesize deviceType;

@synthesize chatCanSendMessage;
@synthesize chatType;
@synthesize chatID;
@synthesize chatUsername;

@synthesize userImages;


@synthesize shouldRefreshMapPins;
@synthesize shouldPauseRefreshMapPins;

@synthesize connectedWIthOtherUser;

@synthesize showTerms;

@synthesize shouldCenterMap;

@synthesize searches;

//initializes user singleton
+ (UserInfo *)user {
    
    static UserInfo *user = nil;
    
    @synchronized(self){
        
        if(!user){
            
            user = [[UserInfo alloc] init];
            
        }
        
    }
    
    return user;
    
}



//delegate will send remote push notification here for the push delegate to run on its active view controller
- (void)receivedNotification:(NSDictionary *)notification withType:(NSString *)type {
    
    //if delegate
    if(self.pushDelegate){
        
        //send notification to active view
        [self.pushDelegate handlePushNotification:notification withType:type];
        
    }
    
}

//initialize user
- (id)init {
    
    self = [super init];
    
    if(self){
        
        //Apple App ID
        appID = @"957856476";
        

        
        //Server request paths
        uri = @"http://www.midpointz.com:8080/";
        img_uri = @"https://api.organicparking.com/user_profile_images/";
        apiKey = @"KGyINqtiXfEMP5qYVEJ0Cj.61XHplL0gb6eQB6TWp9JsLndxmdMDLW";
        geocoding_uri = @"https://maps.googleapis.com/maps/api/geocode/json?address=";
        
        //initialize user profile info
        username = [[[UIDevice currentDevice] name] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
                email = @"";
        profileImage = nil;
        userSpeed = 0.0f;
        udid = @"";
        deviceType = 1;
        
        userImages = [[NSCache alloc] init];
        
        //indicates if map should be refreshed
        shouldRefreshMapPins = false;
        shouldPauseRefreshMapPins = NO;
        
        //se if you are connected to another user
        connectedWIthOtherUser = YES;
        
        //indicates if map should center on searched location - initialize search arrays
        shouldCenterMap = false;
        searches = [[NSMutableArray alloc] init];
        
    }
    
    return self;
    
}

@end