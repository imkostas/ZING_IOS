//
//  Map.h
//  Zing
//
//  Created by Kostas on 8/21/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Pin.h"
#import "UserInfo.h"
#import "User.h"
#import "Pair.h"
#import "GlobalData.h"



@interface Map : UIViewController <	UISearchBarDelegate,
                                    UISearchControllerDelegate,
                                    CLLocationManagerDelegate,
                                    UITableViewDataSource,
                                    UITableViewDelegate,
                                    UIScrollViewDelegate,
                                    MKMapViewDelegate,
                                    PushControlDelegate,
                                    MFMessageComposeViewControllerDelegate,
                                    UIGestureRecognizerDelegate> {
    
    
    
@private
    CGRect _searchTableViewRect;
    
}


@property CLLocation *myCurrentLocation;


@property (strong, nonatomic) IBOutlet MKMapView *mapView; //map view for showing pins

//@property (strong, nonatomic) IBOutlet UISearchBar *ibSearchBar;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) MKLocalSearch *localSearch;
@property (strong, nonatomic) MKLocalSearchResponse *results;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;


@property (nonatomic) UserInfo *user; //user info

//location manager to update and get user location
//@property (nonatomic, strong) CLLocationManager *locationManager;

//tracking
@property (nonatomic, strong) MKPointAnnotation *trackingPoint;
@property (nonatomic, strong) MKAnnotationView *trackingPin;

@end

