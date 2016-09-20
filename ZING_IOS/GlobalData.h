//
//  GlobalData.h
//  Zing
//
//  Created by Kostas on 7/30/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"
#import "User.h"
#import "Pair.h"
#import "Message.h"
#import <MessageUI/MessageUI.h> 

@interface GlobalData : NSObject {
    NSString *message; // global variable
    dispatch_group_t group;

}

@property (nonatomic, retain) NSString *message;
@property (nonatomic, strong) dispatch_group_t group;
@property (readwrite, assign) BOOL askMe;
@property (readwrite, assign) BOOL accuracy;
@property (readwrite, assign) BOOL units;

+ (GlobalData*)shared;

// global function
- (void) myFunc;
- (User *) GetLocation: (NSString *)udid;
- (void) SetLocation: (CLLocation *)location;
- (void) CreatePair:(NSString *) udid1 and:(NSString *) udid2;
- (void) RemovePair:(NSString *) udid1 and:(NSString *) udid2;
- (NSMutableArray *) GetAllLocations:(NSString *)udid;
- (NSMutableArray *) GetIndex:(NSString *)udid;
- (void) SetPastLocation: (CLLocation *)location;
- (void)sendNotification:(NSString *)theMessage to: (NSString*)recipient ofType: (NSString *)type;
- (void)sendMessage:(NSString *)theMessage to:(NSString *)recipient;
- (NSMutableArray *) GetMessages:(NSString *)sender;

@end
