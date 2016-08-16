//
//  GlobalData.h
//  Zing
//
//  Created by Kostas on 7/30/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"
#import "Location.h"
#import "Pair.h"
#import <MessageUI/MessageUI.h>

@interface GlobalData : NSObject {
    NSString *message; // global variable
    dispatch_group_t group;

}

@property (nonatomic, retain) NSString *message;
@property (nonatomic, strong) dispatch_group_t group;


+ (GlobalData*)shared;

// global function
- (void) myFunc;
- (Location *) GetLocation: (NSString *)udid;
- (void) SetLocation: (CLLocation *)location;
- (void) CreatePair:(NSString *) udid1 and:(NSString *) udid2;
- (void) RemovePair:(NSString *) udid1 and:(NSString *) udid2;
- (NSMutableArray *) GetAllLocations:(NSString *)udid;
- (NSMutableArray *) GetIndex:(NSString *)udid;
- (void)sendAPNS:(NSString *)username withUDID: (NSString*)udid withMessage:(NSString *)theMessage andIdentification: (NSString *)identification;

@end
