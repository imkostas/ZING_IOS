//
//  GlobalData.m
//  Zing
//
//  Created by Kostas on 7/30/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import "GlobalData.h"

@implementation GlobalData
@synthesize message;
@synthesize group;
@synthesize askMe;
@synthesize accuracy;
@synthesize units;

static GlobalData *shared = nil; 

+ (GlobalData*)shared {
    if (shared == nil) {
        shared = [[super allocWithZone:NULL] init];
        
        // initialize your variables here
        shared.message = @"Default Global Message";
        shared.group = dispatch_group_create();

        //NSLog(@"shared.message = %@",shared.message);
    }
    return shared;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self)
    {
        if (shared == nil)
        {
            shared = [super allocWithZone:zone];
            return shared;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

// ***********************************
- (void)myFunc {
    self.message = @"Some Random Text";
    NSLog(@"self.message = %@",self.message);
}

//**************************************************************************************

- (User *) GetLocation: (NSString *)udid {
    
    User *user = [[User alloc] init];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *uri = URI;
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@get/%@", uri, udid]]];
    //NSLog(@"GetLocation %@", request.URL);
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            // Success
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSError *jsonError;
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if (jsonError) { NSLog(@"GET : Error Parsing JSON");
                } else {
                    user.username = [dictionary objectForKey:@"username"];
                    user.udid = [dictionary objectForKey:@"udid"];
                    user.appID = [dictionary objectForKey:@"appID"];
                    user.coordinates = CLLocationCoordinate2DMake([[dictionary objectForKey:@"latitude"] floatValue], [[dictionary objectForKey:@"longitude"] floatValue]);
                    //NSLog(@"%@ (%.2f, %2f)",self.user.username, location.coordinates.latitude, location.coordinates.longitude);  //verify
                }
            }  else { //Web server is returning an error
                NSLog(@"error : %@", error.description);  //Error Connecting to Web Server
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Web server is returning an error" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        } else {
            NSLog(@"error : %@", error.description);  //Error Connecting to Server
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You seem not to be connected to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
        }
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GetLocation" object:nil];               });
    }] resume];

    return user;
}





//**************************************************************************************

- (void) SetLocation: (CLLocation *)location {
    
    if(!CLLocationCoordinate2DIsValid(location.coordinate ))return;
    if(location.coordinate.latitude==0. && location.coordinate.longitude==0)return;  // avoid coast of Africa
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *uri = URI;
    NSString *username = [[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *appID = [[NSUserDefaults standardUserDefaults] valueForKey:@"appID"];
    NSString *udid = [UIDevice currentDevice].identifierForVendor.UUIDString;
    // Get current datetime
    NSDate *currentDateTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    NSString *dateInString = [dateFormatter stringFromDate:currentDateTime];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@set/%@/%@/%@/%f&%f&%@", uri, username, appID, udid, location.coordinate.latitude, location.coordinate.longitude, dateInString]]];
    NSLog(@"SetLocation %@", request.URL);
    
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            //NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            //NSLog(@"set requestReply: %@", requestReply);
        } else {
            NSLog(@"error : %@", error.description);
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You seem not to be connected to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alertView show];
        }
        
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SetLocation" object:nil];               });
        
    }] resume];
    
    
}





//**************************************************************************************

- (void) CreatePair:(NSString *) udid1 and:(NSString *) udid2{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *uri = URI;
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@create/%@&%@", uri, udid1, udid2]]];
    NSLog(@"CreatePair %@", request.URL);
    
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"create requestReply: %@", requestReply);
        } else {
            NSLog(@"error : %@", error.description);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error Connecting to Server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CreatePair" object:nil];               });
    }] resume];
 
    
}

//**************************************************************************************

- (void) RemovePair:(NSString *) udid1 and:(NSString *) udid2{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *uri = URI;
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@remove/%@&%@", uri, udid1, udid2]]];
    NSLog(@"RemovePair %@", request.URL);
    
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
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RemovePair" object:nil];               });

    }] resume];

    
}


//**************************************************************************************

- (NSMutableArray *) GetAllLocations:(NSString *)udid  {
    
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    NSMutableArray *myArray = [[NSMutableArray alloc] init] ;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *uri = URI;
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@getall/%@", uri, udid]]];
    //NSLog(@"get %@", request.URL);
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            // Success
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSError *jsonError;
                NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                if (jsonError) {
                    NSLog(@"GET ALL : Error Parsing JSON");
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"error" object:nil userInfo:nil];
                } else {
                    for(NSDictionary *item in jsonArray){
                        User *user = [[User alloc] init];
                        user.username = [[item objectForKey:@"username"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
                        user.udid = [item objectForKey:@"udid"];
                        user.appID = [item objectForKey:@"appID"];
                        user.coordinates = CLLocationCoordinate2DMake([[item objectForKey:@"latitude"] floatValue], [[item objectForKey:@"longitude"] floatValue]);
                        [locations addObject:user];
                    }
                }
            }  else { //Web server is returning an error
                NSLog(@"error : %@", error.description);  //Error Connecting to Web Server
                [[NSNotificationCenter defaultCenter] postNotificationName:@"error" object:nil userInfo:nil];
            }
        } else {
            NSLog(@"error : %@", error.description);  //Error Connecting to Server
            [[NSNotificationCenter defaultCenter] postNotificationName:@"error" object:nil userInfo:nil];
        }
        
        //Order index so that the first object is the current user
        for(int i=0; i<locations.count; i++)
            if([[[locations objectAtIndex:i] udid] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"udid"]])
                [myArray addObject:[locations objectAtIndex:i]];
        for(int i=0; i<locations.count; i++){
            if([[[locations objectAtIndex:i] udid] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"udid"]])continue;
            else
                [myArray addObject:[locations objectAtIndex:i]];
        }
        
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GetAllLocations" object:nil];               });
        
    }] resume];
    
    return locations;
}


//**************************************************************************************

- (NSMutableArray *) GetIndex:(NSString *)udid {
    
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    NSMutableArray *myArray = [[NSMutableArray alloc] init] ;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *uri = URI;
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@getindex", uri]]];
    NSLog(@"GetIndex %@", request.URL);
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            // Success
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSError *jsonError;
                NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                if (jsonError) { NSLog(@"GET INDEX : Error Parsing JSON");
                } else {
                    for(NSDictionary *item in jsonArray){
                        User *user = [[User alloc] init];
                        user.username = [item objectForKey:@"username"];
                        user.appID = [item objectForKey:@"appID"];
                        user.udid = [item objectForKey:@"udid"];
                        user.coordinates = CLLocationCoordinate2DMake([[item objectForKey:@"latitude"] floatValue], [[item objectForKey:@"longitude"] floatValue]);
                        [locations addObject:user];
                    }
                }
            }  else { //Web server is returning an error
            }
        } else {
            NSLog(@"error : %@", error.description);  //Error Connecting to Server
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You seem not to be connected to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        
        //Order index so that the first object is the current user
        for(int i=0; i<locations.count; i++)
            if([[[locations objectAtIndex:i] udid] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"udid"]])
                [myArray addObject:[locations objectAtIndex:i]];
        for(int i=0; i<locations.count; i++){
            if([[[locations objectAtIndex:i] udid] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"udid"]])continue;
            else
                [myArray addObject:[locations objectAtIndex:i]];
        }
        
        // Send a notification that data was read
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GetIndex" object:nil];               });
        
       
        
    }] resume];

    return myArray;
}


//**************************************************************************************

- (void)sendNotification:(NSString *)theMessage to: (NSString*)recipient ofType: (NSString *)type {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *sender = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    sender = [sender stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];    // encode
    
    recipient = [recipient stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];  //encode
    
    theMessage = [theMessage stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *uri = URI;
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@sendNotification/%@&%@&%@",  uri, recipient, theMessage, type ]]];
    NSLog(@"sendNotification %@", request.URL);
    
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"sendNotification requestReply: %@", requestReply);
        } else {
            NSLog(@"error : %@", error.description);
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error Connecting to Server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sendNotification" object:nil];               });
        
    }] resume];
    
}

//**************************************************************************************



- (void)sendMessage:(NSString *)theMessage to:(NSString *)recipient {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *sender = [[NSUserDefaults standardUserDefaults] stringForKey:@"appID"];
//    sender = [sender stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];    // encode
    
    recipient = [recipient stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];  //encode
    
    theMessage = [theMessage stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDate *currentDateTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    NSString *dateInString = [dateFormatter stringFromDate:currentDateTime];
 
    NSString *uri = URI;
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@sendMessage/%@&%@&%@&%@&%f&%f",  uri, sender, recipient, dateInString, theMessage, [[LocationManager sharedManager] myLocation].longitude, [[LocationManager sharedManager] myLocation].latitude  ]]];
    NSLog(@"sendMessage %@", request.URL);
    
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
        
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SendMessage" object:nil];               });
        
    }] resume];
    
}


//**************************************************************************************

- (NSMutableArray *) GetMessages:(NSString *)sender {
    
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    NSMutableArray *time_grouped_messages = [[NSMutableArray alloc] init] ;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *uri = URI;
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@getMessages/%@", uri, sender]]];
    NSLog(@"GetMessages %@", request.URL);
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            // Success
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSError *jsonError;
                NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                if (jsonError) { NSLog(@"GET MESSAGES : Error Parsing JSON");
                } else {
                    for(NSDictionary *item in jsonArray){
                        Message *incoming_message = [[Message alloc] init];
                        incoming_message.post_ID = [item objectForKey:@"post_ID"];
                        incoming_message.sender = [item objectForKey:@"sender"];
                        incoming_message.recipient = [item objectForKey:@"recipient"];
                        incoming_message.time_sent = [item objectForKey:@"time_sent"];
                        incoming_message.message = [item objectForKey:@"message"];
                        incoming_message.message_read = [[item objectForKey:@"message_read"] boolValue];
                        incoming_message.notified = [[item objectForKey:@"notified"] boolValue];
                        incoming_message.coordinates = CLLocationCoordinate2DMake([[item objectForKey:@"latitude"] floatValue], [[item objectForKey:@"longitude"] floatValue]);
                        [messages addObject:incoming_message];
                    }
                }
            }  else { //Web server is returning an error
            }
        } else {
            NSLog(@"error : %@", error.description);  //Error Connecting to Server
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You seem not to be connected to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        
        //Get rid of duplicate messages (i.e. a message was send to two people.  Keep only one based on same time)
        [time_grouped_messages addObject:[messages objectAtIndex:0]];
        for(int i=1; i<messages.count; i++){
            if([[[messages objectAtIndex:i] time_sent] compare:[[messages objectAtIndex:(i-1)] time_sent]] == NSOrderedSame)
                continue;
            else
                [time_grouped_messages addObject:[messages objectAtIndex:i]];

        }
        
        // Send a notification that data was read
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GetMessages" object:nil];              });     
    
    }] resume];
    
    return time_grouped_messages;
}






//**************************************************************************************

- (void) SetPastLocation: (CLLocation *)location {
    
    if(!CLLocationCoordinate2DIsValid(location.coordinate ))return;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *uri = URI;
    NSString *udid = [UIDevice currentDevice].identifierForVendor.UUIDString;
    // Get current datetime
    NSDate *currentDateTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    NSString *dateInString = [dateFormatter stringFromDate:currentDateTime];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@setPastLocation/%@/%f&%f&%@", uri, udid, location.coordinate.latitude, location.coordinate.longitude, dateInString]]];
    NSLog(@"SetPastLocation %@", request.URL);
    
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            //NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            //NSLog(@"set requestReply: %@", requestReply);
        } else {
            NSLog(@"error : %@", error.description);
            //            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You seem not to be connected to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //            [alertView show];
        }
        
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SetPastLocation" object:nil];               });
        
    }] resume];
    
    
}


//// **************************************************************************************
//
//- (void)sendSMS:(NSString*)phone withMessage:(NSString *)theMessage {
//  
//    if([MFMessageComposeViewController canSendText]) {
//        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
//        // Create message VC
//        messageController.messageComposeDelegate = self; // Set delegate to current instance
//        
//        NSMutableArray *recipients = [[NSMutableArray alloc] init]; // Create an array to hold the recipients
//        [recipients addObject:phone]; // Append example phone number to array
//        messageController.recipients = recipients; // Set the recipients of the message to the created array
//        messageController.body = theMessage; // Set initial text to example message
//        
//        dispatch_async(dispatch_get_main_queue(), ^{ // Present VC when possible
////            [self presentViewController:messageController animated:YES completion:NULL];
//        });
//    }
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"SendSMS" object:nil userInfo:nil];
//
//}
//
//// **************************************************************************************
//
//- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
// //   [self dismissViewControllerAnimated:YES completion:NULL];
//}


@end
