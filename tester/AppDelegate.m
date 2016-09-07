//
//  AppDelegate.m
//  tester
//
//  Created by Kostas on 6/28/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    self.shareModel = [LocationManager sharedManager];
    self.shareModel.afterResume = NO;
    
    [self.shareModel addApplicationStatusToPList:@"didFinishLaunchingWithOptions"];
    
    UIAlertView * alert;
    
    //We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
    if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied) {
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh"
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    } else if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted) {
        
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"The functions of this app are limited because the Background App Refresh is disabled."
                                         delegate:nil
                                cancelButtonTitle:@"Ok"
                                otherButtonTitles:nil, nil];
        [alert show];
        
    } else {
        
        // When there is a significant changes of the location,
        // The key UIApplicationLaunchOptionsLocationKey will be returned from didFinishLaunchingWithOptions
        // When the app is receiving the key, it must reinitiate the locationManager and get
        // the latest location updates
        
        // This UIApplicationLaunchOptionsLocationKey key enables the location update even when
        // the app has been killed/terminated (Not in th background) by iOS or the user.
        
        //NSLog(@"UIApplicationLaunchOptionsLocationKey : %@" , [launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]);
        if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
            
            // This "afterResume" flag is just to show that he receiving location updates
            // are actually from the key "UIApplicationLaunchOptionsLocationKey"
            self.shareModel.afterResume = YES;
            
            [self.shareModel startMonitoringLocation];
            [self.shareModel addResumeLocationToPList];
        }
    }

    
    
    
    
    
    
    
    //initialize user info object (Singleton)
    self.user = [UserInfo user];
    
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        
    } else {
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        
    }
    
    
    //clear application's badges...but should do elsewhere
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;


    //NSLog(@"currentDevice = %@", [UIDevice currentDevice].identifierForVendor.UUIDString);
    
    return YES;
}



//**************************************************************************************//

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

//**************************************************************************************//

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
    [self.shareModel restartMonitoringLocation];
    [self.shareModel addApplicationStatusToPList:@"applicationDidEnterBackground"];
    
    NSLog(@"entered background Mode");
   ////////// [[GlobalData shared] sendAPNS:self.user.udid withMessage:@"backgroundMode"]; ////////////

    
}

//**************************************************************************************//

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
     NSLog(@"application Did Become Active");
}

//**************************************************************************************//

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    
    [self.shareModel addApplicationStatusToPList:@"applicationDidBecomeActive"];
    
    //Remove the "afterResume" Flag after the app is active again.
    self.shareModel.afterResume = NO;
    
    [self.shareModel startMonitoringLocation];

    
    //clear application's badges...but should do elsewhere//test IOS
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
}

//**************************************************************************************//

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self.shareModel addApplicationStatusToPList:@"applicationWillTerminate"];
}

#pragma mark Push notifications
//**************************************************************************************//
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
    [application registerForRemoteNotifications];
    
}

//**************************************************************************************//

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    
    //format device token
    // NSLog(@"deviceToken: %@", deviceToken);
    NSMutableString *tokenString = [NSMutableString stringWithString:[[deviceToken description] uppercaseString]];
    [tokenString replaceOccurrencesOfString:@"<" withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];
    [tokenString replaceOccurrencesOfString:@">" withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];
    [tokenString replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];
    
    //save device token in user info
    self.user.udid = tokenString;
    [[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:@"udid"];
    NSLog(@"name = %@ device = %@", [[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                    [[NSUserDefaults standardUserDefaults] objectForKey:@"udid"]);
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *username = [[[UIDevice currentDevice] name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    self.user.username = username;
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] synchronize];


}
//**************************************************************************************//
- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    
    NSLog(@"Failed to register for remote notifications: %@", [error description]);
    
    //storing device as nil in user info
    self.user.udid = @"";
    
    //notify user they should enable push notifications
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enable Location Services" message:@"To use Zing, push notifications services must be enabled within Settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView show];
    
}
//**************************************************************************************//
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    NSLog(@"didReceiveLocalNotification");
    
//    //local notification - testing functionality, might use later
//    if(application.applicationState == UIApplicationStateActive){
//        
//        //indicate push has been received
//        [self.user receivedNotification:notification.userInfo withType:[NSString stringWithFormat:@"%@", [notification.userInfo objectForKey:@"id"]]];
//    }
    
}

// **************************************************************************************

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)info {
    
    NSLog(@"%@", info);
    NSLog(@"didReceiveRemoteNotification %ld %ld", (long)[UIApplication sharedApplication].applicationState,
          (long)UIApplicationStateInactive);
    
    //if application is active, show specific alert/message
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){

        //push types
        if([[info objectForKey:@"id"]  isEqualToString:@"request"]){
             [self.user receivedNotification:info withType:@"request"];
        } else if([[info objectForKey:@"id"]  isEqualToString:@"yes"]) {
             [self.user receivedNotification:info withType:@"yes"];
        } else if([[info objectForKey:@"id"]  isEqualToString:@"no"]) {
             [self.user receivedNotification:info withType:@"no"];
        } else if([[info objectForKey:@"id"]  isEqualToString:@"RemovePair"]) {
            [self.user receivedNotification:info withType:@"RemovePair"];
        } else if([[info objectForKey:@"id"]  isEqualToString:@"CreatePair"]) {
            [self.user receivedNotification:info withType:@"CreatePair"];
        }
        else if([[info objectForKey:@"id"]  isEqualToString:@"silent"]) {
            //SILENT
            NSLog(@"SILENT");
        }
    }

    else if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        
        NSLog(@"UIApplicationStateBackground");
        
        if([[info objectForKey:@"id"]  isEqualToString:@"silent"]) {
            
            //SILENT
            NSLog(@"BACK SILENT");
            
        }
        else{
        
        NSLog(@"Creating local notification");
//        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.timeZone = [NSTimeZone localTimeZone];
        notification.alertBody = NSLocalizedString([info objectForKey:@"alert"] , nil);
        notification.alertAction = NSLocalizedString(@"Take Action", nil);
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.applicationIconBadgeNumber++;
        NSDictionary *infoDict = [NSDictionary dictionaryWithObject:[info objectForKey:@"id"] forKey:@"id"];
        notification.userInfo = infoDict;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        
        }
        
    } else if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        
        NSLog(@"App Inactive");
    }
    
}






- (void)batteryStateDidChange:(NSNotification *)notification
{
    

}


@end
