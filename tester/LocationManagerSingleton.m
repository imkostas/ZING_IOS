//  LocationManagerSingleton.m
//
//

#import "LocationManagerSingleton.h"
#import "GlobalData.h"
#import "Location.h"

@interface LocationManagerSingleton()

@end

@implementation LocationManagerSingleton

+(LocationManagerSingleton *)sharedLocationInstance
{
    static LocationManagerSingleton *myLocation = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myLocation = [[self alloc] init];
    });
    return myLocation;
}

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        _myLocationManager = [[CLLocationManager alloc] init];
        _myLocationManager.delegate = self;
        _myLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _myLocationManager.distanceFilter = 30;
    }
    if(self.user==nil)
        self.user = [UserInfo user];

    return self;
}


- (void)locationManager: (CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{

    for (CLLocation *location in locations)
    {
        if(location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000)
        {
            [self.myLocationManager stopUpdatingLocation];
            break;
        }
    }
    
    NSNumber *latitude = [NSNumber numberWithDouble:self.myLocationManager.location.coordinate.latitude];
    [[NSUserDefaults standardUserDefaults] setObject:latitude forKey:@"latitude"];
    NSNumber *longitude = [NSNumber numberWithDouble:self.myLocationManager.location.coordinate.longitude];
    [[NSUserDefaults standardUserDefaults] setObject:longitude forKey:@"longitude"];

    [[NSUserDefaults standardUserDefaults] synchronize];
    [[GlobalData shared] SetLocation:self.myLocationManager.location];
    
    NSLog(@"%@ is at (%.2f, %.2f)",[[NSUserDefaults standardUserDefaults] objectForKey:@"username"], [[[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"] floatValue], [[[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"] floatValue]);

   // dispatch_async(dispatch_get_main_queue(),^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserLocation" object:nil];               //});


    

}

//// **************************************************************************************
//- (void) getAPIData:(CLLocation *)location
//{
//    CLLocation *userLocation = self.myLocationManager.location;
//
//}


-(void) sendBackgroundLocationToServer:(CLLocation *)location
{
    // REMEMBER. We are running in the background if this is being executed.
    // We can't assume normal network access.
    // bgTask is defined as an instance variable of type UIBackgroundTaskIdentifier
    
    // Note that the expiration handler block simply ends the task. It is important that we always
    // end tasks that we have started.
    
    //TELL the operating system in advance that we are doing a background task that should be allowed to run to completion
    
    //Check if our iOS version supports multitasking
    if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])
    {
        //Check if device supports mulitasking
        if ([[UIDevice currentDevice] isMultitaskingSupported])
        {
            UIBackgroundTaskIdentifier bgTask;
            
            bgTask = [[UIApplication sharedApplication]
                      beginBackgroundTaskWithExpirationHandler:
                      ^{
                          [[UIApplication sharedApplication] endBackgroundTask:bgTask];
                           }];
                          
                            // ANY CODE WE PUT HERE IS OUR BACKGROUND TASK
                          
                            // For example, I can do a series of SYNCHRONOUS network methods (we're in the background, there is
                            // no UI to block so synchronous is the correct approach here).
                            [[GlobalData shared] SetLocation:self.myLocationManager.location];
            
                            NSLog(@"IN BACKGROUND SEND SET ");
            [[GlobalData shared] sendAPNS:self.user.username withUDID:self.user.udid withMessage:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] andIdentification:@"silent"]; ////////////


                            // Start the long-running task and return immediately.
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                              
                              // Do the work associated with the task.
                              NSLog(@"IN BACKGROUND SETTING LOCATION MANAGER");
                              
                              _myLocationManager.distanceFilter = 100;
                              _myLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
                              [_myLocationManager startMonitoringSignificantLocationChanges];
                              [_myLocationManager startUpdatingLocation];
                              
                             // [[GlobalData shared] sendA]
                              

                              
                              // Synchronize the cleanup call on the main thread in case
                              // the expiration handler is fired at the same time.
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  
                                  if (bgTask != UIBackgroundTaskInvalid)
                                  {
                                      [[UIApplication sharedApplication] endBackgroundTask:bgTask];
//                                      bgTask = UIBackgroundTaskInvalid;
                                  }
                              });
                              
                          });
                          
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    BOOL isInBackground = NO;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
    {
        isInBackground = YES;
    }

    
    if ( fabs([newLocation.timestamp timeIntervalSinceDate: [NSDate date]]) < 30) {
       // self.lastLocation = newLocation;
        
        [[GlobalData shared] SetLocation:self.myLocationManager.location];
    }
    
    if (isInBackground)
    {
        [self sendBackgroundLocationToServer:newLocation];
    }
    
}

- (void) startMonitoringSignificantLocationChanges
{
    [self.myLocationManager startMonitoringSignificantLocationChanges];
}
- (void) stopMonitoringSignificantLocationChanges
{
    [self.myLocationManager stopMonitoringSignificantLocationChanges];
}
-(void) stopUpdatingLocation{
    [self.myLocationManager stopUpdatingLocation];
}
-(void) startUpdatingLocation{
    [self.myLocationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(nonnull NSError *)error
{
    NSLog(@"LocationManager error is %@", error);
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enable Location Services" message:@"To use Zing, location services must be enabled within Settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alertView show];
    }
    dispatch_async(dispatch_get_main_queue(),^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ErrorLocationManager" object:nil];               });

}

- (BOOL) enableLocationServices {
    
    if ([CLLocationManager locationServicesEnabled]) {
        self.myLocationManager.distanceFilter = 10;
        self.myLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.myLocationManager startUpdatingLocation];
        return YES;
    } else {
        return NO;
    }
}


- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    NSString *message = @"You must enable Location Services for this app in order to use it.";
    NSString *button = @"Ok";
    NSString *title;
    
    if (status == kCLAuthorizationStatusDenied) {
        title = @"Location Services Disabled";
        [[[UIAlertView alloc] initWithTitle:title
                                    message:message
                                   delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:button, nil] show];
    } else if(status == kCLAuthorizationStatusRestricted) {
        title = @"Location Services Restricted";
        [[[UIAlertView alloc] initWithTitle:title
                                    message:message
                                   delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:button, nil] show];
    } else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // Note: kCLAuthorizationStatusAuthorizedWhenInUse depends on the request...Authorization
        // (Always or WhenInUse)
        if ([self enableLocationServices]) {
            NSLog(@"Location Services enabled.");
        } else {
            NSLog(@"Couldn't enable Location Services. Please enable them in Settings > Privacy > Location Services.");
            title = @"Couldn't enable Location Services. Please enable them in Settings > Privacy > Location Services.";
            [[[UIAlertView alloc] initWithTitle:title
                                        message:message
                                       delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:button, nil] show];
        }
    } else if (status == kCLAuthorizationStatusNotDetermined) {
        NSLog(@"Error : Authorization status not determined.");
        [self.myLocationManager requestWhenInUseAuthorization];
    }
}


@end
