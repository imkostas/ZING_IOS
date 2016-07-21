//
//  ViewController.h
//  tester
//
//  Created by Kostas on 6/28/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Pin.h"
#import "UserInfo.h"

@interface ViewController : UIViewController <	UISearchBarDelegate,
                                                UISearchControllerDelegate,
                                                CLLocationManagerDelegate,
                                                UITableViewDataSource,
                                                UITableViewDelegate,
                                                UIScrollViewDelegate,
                                                MKMapViewDelegate,
                                                UIGestureRecognizerDelegate>
{

@private
CGRect _searchTableViewRect;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView; //map view for showing pins
//@property (strong, nonatomic) IBOutlet UISearchBar *ibSearchBar;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) MKLocalSearch *localSearch;
@property (strong, nonatomic) MKLocalSearchResponse *results;

@property (nonatomic) UserInfo *user; //user info

//location manager to update and get user location
@property (nonatomic, strong) CLLocationManager *locationManager;

//tracking
@property (nonatomic, strong) MKPointAnnotation *trackingPoint;
@property (nonatomic, strong) MKAnnotationView *trackingPin;

@end

