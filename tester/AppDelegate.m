//
//  AppDelegate.m
//  tester
//
//  Created by Kostas on 6/28/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import "AppDelegate.h"
#import "LocationManagerSingleton.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    //initialize user info object (Singleton)
    self.user = [UserInfo user];
    
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        
        UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        
    } else {
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        
    }
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        
        
        [[LocationManagerSingleton sharedLocationInstance].myLocationManager startMonitoringSignificantLocationChanges];
        
    }else{
    /////////////////////////////
    [[LocationManagerSingleton sharedLocationInstance]setDelegate:self];
    [[LocationManagerSingleton sharedLocationInstance].myLocationManager startUpdatingLocation];
    /////////////////////////////
    }
    
    


    
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
    
    [[LocationManagerSingleton sharedLocationInstance].myLocationManager stopUpdatingLocation];
    [[LocationManagerSingleton sharedLocationInstance].myLocationManager startMonitoringSignificantLocationChanges];
    NSLog(@"entered background Mode");
   ////////// [[GlobalData shared] sendAPNS:self.user.udid withMessage:@"backgroundMode"]; ////////////

    
}

//**************************************************************************************//

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[LocationManagerSingleton sharedLocationInstance].myLocationManager stopMonitoringSignificantLocationChanges];
    [[LocationManagerSingleton sharedLocationInstance].myLocationManager startUpdatingLocation];
    NSLog(@"application Did Become Active");
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
    
    //local notification - testing functionality, might use later
    if(application.applicationState == UIApplicationStateActive){
        
        //indicate push has been received
        [self.user receivedNotification:notification.userInfo withType:[NSString stringWithFormat:@"%@", [notification.userInfo objectForKey:@"id"]]];
        
    }
    
}



// **************************************************************************************

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)info {
    
    NSLog(@"%@", info);
    NSLog(@"didReceiveRemoteNotification");
    
    //if application is active, show specific alert/message
    if(application.applicationState == UIApplicationStateActive){

        //push types
        if([[info objectForKey:@"id"]  isEqualToString:@"request"]){
            
            //Can we connect? Please?
             [self.user receivedNotification:info withType:@"request"];
        
        } else if([[info objectForKey:@"id"]  isEqualToString:@"yes"]) {
            
            //YES
             [self.user receivedNotification:info withType:@"yes"];
            
            
        } else if([[info objectForKey:@"id"]  isEqualToString:@"no"]) {
            
            //NO
             [self.user receivedNotification:info withType:@"no"];
            
        }else if([[info objectForKey:@"id"]  isEqualToString:@"silent"]) {
            
            //SILENT
            NSLog(@"SILENT");
            
            
        }
    }

    else if(application.applicationState == UIApplicationStateBackground) {
        
        NSLog(@"UIApplicationStateBackground");
        
        if([[info objectForKey:@"id"]  isEqualToString:@"silent"]) {
            
            //SILENT
            NSLog(@"BACK SILENT");
            
        }
        else{
        
        NSLog(@"Creating local notification");
//        
//        UILocalNotification *notification = [[UILocalNotification alloc] init];
//        notification.timeZone = [NSTimeZone localTimeZone];
//        notification.alertBody = NSLocalizedString([info objectForKey:@"alert"] , nil);
//        notification.alertAction = NSLocalizedString(@"Take Action", nil);
//        notification.soundName = UILocalNotificationDefaultSoundName;
//        notification.applicationIconBadgeNumber = 1;
//        NSDictionary *infoDict = [NSDictionary dictionaryWithObject:[info objectForKey:@"id"] forKey:@"id"];
//        notification.userInfo = infoDict;
//        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            
        }
        
    } else if (application.applicationState == UIApplicationStateInactive) {
        
        NSLog(@"App Inactive");
    }
    
}


// **************************************************************************************

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if([[alertView buttonTitleAtIndex:buttonIndex]isEqual:@"ZING"]) {  //YES
        [self sendAPNS:self.user for:@"yes"];
    }
    else if([[alertView buttonTitleAtIndex:buttonIndex]isEqual:@"NOT NOW"]) {  //NO
        [self sendAPNS:self.user for:@"no"];
    }
    else if([[alertView buttonTitleAtIndex:buttonIndex]isEqual:@"GOOD"]) {  //
        ;
    }
    else if([[alertView buttonTitleAtIndex:buttonIndex]isEqual:@"OH WELL"]) {  //
        ;
    }
    
}


//**************************************************************************************

- (void)sendAPNS:(UserInfo*)myContact for:(NSString *)id{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    

    NSString *emessage;
    NSString *eusername = [myContact.username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if([id isEqualToString:@"yes"]){
        emessage = [[NSString stringWithFormat:@"%@ allows to zing with you", [myContact.username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    else if([id isEqualToString:@"no"]){
         emessage = [[NSString stringWithFormat:@"%@ allows to zing with you", [myContact.username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
    }
    else{
        emessage = @"";
    }
//    NSString *username = myContact.username;
//    NSString *eusername = [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    
//    NSString *message =  [NSString stringWithFormat:@"%@ wants to zing with you", myContact.username];
//    NSString *emessage = [message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@notification/%@&%@&%@&request",  self.user.uri, eusername, myContact.udid, emessage ]]];
    NSLog(@"notification %@", request.URL);
    
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"set requestReply: %@", requestReply);
        } else {
            NSLog(@"error : %@", error.description);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error Connecting to Server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }] resume];
    
}


- (void)batteryStateDidChange:(NSNotification *)notification
{
    

}


@end
