//
//  Definitions.h
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2016 Zing, Inc. All rights reserved.
//

#ifndef Parking_definitions_h
#define Parking_definitions_h

//Handle versioning
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

//Organic Parking Colors
#define OP_LIGHT_GRAY_COLOR [UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1.0]
#define OP_BLUE_COLOR [UIColor colorWithRed:40/255.0f green:212/255.0f blue:202/255.0f alpha:1.0]
#define OP_PINK_COLOR [UIColor colorWithRed:255/255.0f green:70/255.0f blue:98/255.0f alpha:1.0]

#define TOP_BAR_HEIGHT 65.0


#define iPad    UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
//#define MAX_WIDTH         (iPad ? 640 : 320.0)
//#define VIEW_HIDDEN_RIGHT (iPad ? -640 : -320.0)
//#define VIEW_WIDTH (iPad ? 640 : 320.0)


#define MAX_WIDTH 320.0

#define DEFAULT_ANIMATION_SPEED 0.25

//Definitions for menu slide
#define VIEW_HIDDEN_RIGHT -320
#define VIEW_WIDTH 320
#define ACCORDION_WIDH ([[UIScreen mainScreen] bounds].size.width - 48)
#define PADDING 20.0

//#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
//#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

//Definitions for map defaults
#define LAT_DELTA 0.1
#define LON_DELTA 0.1
#define METERS_PER_MILE 300

//Default animation speed
#define ANIMATION_SPEED 0.2

//shift amounts when pin selected
#define SHIFT_MAP_CENTER_4 -5.0
#define SHIFT_MAP_CENTER_5 -10.2
#define SHIFT_MAP_CENTER_6 200.0
#define SHIFT_MAP_CENTER_6P 20.0

//shift amounts when user location selected
#define SHIFT_POST_AMOUNT_4 -100.0
#define SHIFT_POST_AMOUNT_5 -11.1
#define SHIFT_POST_AMOUNT_6 -6.5
#define SHIFT_POST_AMOUNT_6P -5.5

#define STATUS_LIMIT 3
#define POST_NEEDS_RATING 4
#define REQUEST_NEEDS_RATING 3
#define REQUEST_ACCEPTED 1
#define ACKNOWLEDGED_ACCEPTANCE 2
#define ACKNOWLEDGED_DENIAL 0
#define REQUEST_DENIED 6
#define REQUESTER_CANCELED 7
#define POSTER_CANCELED 8
#define PAYMENT_SENT 1

#define TOP_BAR_HEIGHT 65.0

#define POST_IN_SWAP 134.0
#define POST_NO_SWAP 140.0

typedef enum code{
    NO_MESSAGE,
    MISSING_VEHICLE,
    MISSING_FUNDING_SOURCE,
    MISSING_PAYMENT_METHOD,
    EXPIRED_PAYMENT_METHOD,
    RATE_NOW,
    RATE_LATER,
    ADD_ACCOUNT,
    CHANGE_ACCOUNT
} Codes;

//Notifications
#define TYPING_DISABLED_WHILE_DRIVING @"Typing is disabled while driving. Please try again when stopped."

#define URI  @"http://www.midpointz.com:8080/";

#endif
