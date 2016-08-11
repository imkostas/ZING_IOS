//  LocationManagerSingleton.h
//
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "UserInfo.h"

@protocol  LocationManagerSingletonDelegate

- (void)locationManagerSingletonDidUpdateLocation:(CLLocation *)location;

@end

@interface LocationManagerSingleton : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *myLocationManager;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) UserInfo *user;

@property (weak, nonatomic) id delegate;

+(LocationManagerSingleton *)sharedLocationInstance;

@end

