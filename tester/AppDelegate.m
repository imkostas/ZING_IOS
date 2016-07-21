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
    
    //initialize user info object
    self.user = [UserInfo user];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        
    } else {
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        
    }
    
//    NSHost *host;
//    
//    NSLog(@"%@",[[UIDevice currentDevice] name]);
//    NSLog(@"user == %@",[[[NSHost currentHost] names] objectAtIndex:0]);
//
//
//    NSArray *nameArray = [[NSHost currentHost] names];
//    NSString *user = [nameArray objectAtIndex:0];
    
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
}

//**************************************************************************************//

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

//**************************************************************************************//

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

//**************************************************************************************//

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
    NSLog(@"self.user.device = %@", self.user.udid);
    
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    
    NSLog(@"Failed to register for remote notifications: %@", [error description]);
    
    //storing device as nil in user info
    self.user.udid = @"";
    
    //notify user they should enable push notifications
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enable Location Services" message:@"To use King, push notifications services must be enabled within Settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView show];
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    NSLog(@"didReceiveLocalNotification");
    
    //local notification - testing functionality, might use later
    if(application.applicationState == UIApplicationStateActive){
        
        //indicate push has been received
        [self.user receivedNotification:notification.userInfo withType:[NSString stringWithFormat:@"%@", [notification.userInfo objectForKey:@"type"]]];
        
    }
    
    
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)info {
    
    NSLog(@"%@", info);
    NSLog(@"didReceiveRemoteNotification");
    
    //if application is active, show specific alert/message
    if(application.applicationState == UIApplicationStateActive){
        
        //push types
        if([[[info objectForKey:@"info"] valueForKeyPath:@"type"] isEqualToString:@"canceledDeal"]){
            
            //indicate push has been received
            [self.user receivedNotification:info withType:@"canceledDeal"];
            
        } else if([[[info objectForKey:@"info"] valueForKeyPath:@"type"] isEqualToString:@"autoDeletedPost"]) {
            
            //indicate push has been received
            [self.user receivedNotification:info withType:@"autoDeletedPost"];
            
        } else if([[[info objectForKey:@"info"] valueForKeyPath:@"type"] isEqualToString:@"finalizedDeal"]) {
            
            //indicate push has been received
            [self.user receivedNotification:info withType:@"finalizedDeal"];
            
        } else if([[[info objectForKey:@"info"] valueForKeyPath:@"type"] isEqualToString:@"postRequested"]) {
            
            //indicate push has been received
            [self.user receivedNotification:info withType:@"postRequested"];
            
        } else if([[[info objectForKey:@"info"] valueForKeyPath:@"type"] isEqualToString:@"respondedToRequest"]) {
            
            //indicate push has been received
            [self.user receivedNotification:info withType:@"respondedToRequest"];
            
        } else if([[[info objectForKey:@"info"] valueForKeyPath:@"type"] isEqualToString:@"missedMessage"]) {
            
            //indicate push has been received
            [self.user receivedNotification:info withType:@"missedMessage"];
            
        }
        
    }
    
    else if(application.applicationState == UIApplicationStateBackground) {
        
        NSLog(@"Creating local notification");
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.timeZone = [NSTimeZone localTimeZone];
        notification.alertBody = NSLocalizedString([[info objectForKey:@"aps"] valueForKey:@"alert"], nil);
        notification.alertAction = NSLocalizedString(@"Take Action", nil);
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.applicationIconBadgeNumber = 1;
        NSDictionary *infoDict = [NSDictionary dictionaryWithObject:[[info objectForKey:@"info"] valueForKeyPath:@"type"] forKey:@"type"];
        notification.userInfo = infoDict;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        
    } else if (application.applicationState == UIApplicationStateInactive) {
        
        NSLog(@"App Inactive");
        
    }
    
}



@end
