//
//  AppDelegate.h
//  tester
//
//  Created by Kostas on 6/28/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "UserInfo.h"
#import <AddressBookUI/AddressBookUI.h>
#import "GlobalData.h"
#import "LocationManager.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (strong, nonatomic) UserInfo *user; //user info

@property (strong,nonatomic) LocationManager * shareModel;

@end

