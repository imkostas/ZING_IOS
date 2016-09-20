//
//  Pin.h
//  Custom Pin
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2016 Zing, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface Pin : MKPointAnnotation


//cell for displaying previously searched locations or search results based on search string
@property (strong, nonatomic) NSString *name; //displays main address
@property (strong, nonatomic) NSString *distance; //displays city, region, country
@property (nonatomic) CLLocationCoordinate2D coordinates;
@property (nonatomic, strong) NSString *udid;
@property (nonatomic, strong) NSString *appID;
@property (nonatomic) BOOL shouldZoom;
@property (nonatomic, strong) UIImage *circleImage;  //pin image
@property (strong, nonatomic) NSString *nameInitial; //displays name's initial on pin

@end
