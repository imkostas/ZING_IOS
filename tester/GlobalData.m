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


static GlobalData *shared = nil;

+ (GlobalData*)shared {
    if (shared == nil) {
        shared = [[super allocWithZone:NULL] init];
        
        // initialize your variables here
        shared.message = @"Default Global Message";
        shared.group = dispatch_group_create();

        
        NSLog(@"shared.message = %@",shared.message);
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

- (Location *) GetLocation: (NSString *)udid {
    
    Location *location = [[Location alloc] init];
    
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
                if (jsonError) { NSLog(@"Error Parsing JSON");
                } else {
                    location.username = [dictionary objectForKey:@"username"];
                    location.udid = [dictionary objectForKey:@"udid"];
                    location.coordinates = CLLocationCoordinate2DMake([[dictionary objectForKey:@"latitude"] floatValue], [[dictionary objectForKey:@"longitude"] floatValue]);
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

    return location;
}





//**************************************************************************************

- (void) SetLocation: (CLLocation *)location {
    
    if(!CLLocationCoordinate2DIsValid(location.coordinate ))return;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *uri = URI;
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    NSString *udid = [[NSUserDefaults standardUserDefaults] valueForKey:@"udid"];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@set/%@/%@/%f&%f", uri, username, udid, location.coordinate.latitude, location.coordinate.longitude]]];
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
                    NSLog(@"Error Parsing JSON");
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"error" object:nil userInfo:nil];
                } else {
                    Location *userLocation = [[Location alloc] init];
                    userLocation.username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
                    userLocation.udid = [[NSUserDefaults standardUserDefaults] objectForKey:@"udid"];
                    userLocation.coordinates =  CLLocationCoordinate2DMake([[[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"] floatValue], [[[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"] floatValue]);
                    [locations addObject:userLocation];  //First one is always the user
                    for(NSDictionary *item in jsonArray){
                        Location *location = [[Location alloc] init];
                        
                        location.username = [item objectForKey:@"username"];
                        location.udid = [item objectForKey:@"udid"];
                        location.coordinates = CLLocationCoordinate2DMake([[item objectForKey:@"latitude"] floatValue], [[item objectForKey:@"longitude"] floatValue]);
                        [locations addObject:location];
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
        
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GetAllLocations" object:nil];               });
        
    }] resume];
    
    return locations;
}


//**************************************************************************************

- (NSMutableArray *) GetIndex:(NSString *)udid {
    
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    
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
                if (jsonError) { NSLog(@"Error Parsing JSON");
                } else {
                    for(NSDictionary *item in jsonArray){
                        Location *location = [[Location alloc] init];
                        location.username = [item objectForKey:@"username"];
                        location.udid = [item objectForKey:@"udid"];
                        [locations addObject:location];
                    }
                }
            }  else { //Web server is returning an error
            }
        } else {
            NSLog(@"error : %@", error.description);  //Error Connecting to Server
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You seem not to be connected to the server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GetIndex" object:nil];               });
        
    }] resume];

    return locations;
}


//**************************************************************************************

- (void)sendAPNS:(NSString*)udid withMessage:(NSString *)theMessage andIdentification: (NSString *)identification {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *eusername = [@"user_x" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *emessage = [theMessage stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *uri = URI;
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@notification/%@&%@&%@&%@",  uri, eusername, udid, emessage, identification ]]];
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
        
        dispatch_async(dispatch_get_main_queue(),^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SendAPNS" object:nil];               });

    }] resume];

}


//**************************************************************************************

- (void)sendSMS:(NSString*)phone withMessage:(NSString *)theMessage {
  
    if([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        // Create message VC
        messageController.messageComposeDelegate = self; // Set delegate to current instance
        
        NSMutableArray *recipients = [[NSMutableArray alloc] init]; // Create an array to hold the recipients
        [recipients addObject:phone]; // Append example phone number to array
        messageController.recipients = recipients; // Set the recipients of the message to the created array
        messageController.body = theMessage; // Set initial text to example message
        
        dispatch_async(dispatch_get_main_queue(), ^{ // Present VC when possible
//            [self presentViewController:messageController animated:YES completion:NULL];
        });
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SendSMS" object:nil userInfo:nil];

}

// **************************************************************************************

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
 //   [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
