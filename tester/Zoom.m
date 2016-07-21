//
//  Search.m
//  Parking
//
//  Last modified by Kostas Terzidis on 08/10/15.
//  Copyright (c) 2016 Zing, Inc. All rights reserved.
//

#import "Zoom.h"

@interface Zoom () <UISearchDisplayDelegate, UISearchBarDelegate>{
    
    NSArray *searchResultPlaces; //array for storing search results
    
    NSString *addressTitle; //used for saving parsed query results
    NSString *addressSubtitle; //used for saving parsed query results
    
}

@end

@implementation Zoom

{
    Address *address;
    
    NSMutableArray *addresses;
    NSArray *searchResults;
    
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *results;

}

@synthesize searchBar;

#define TOP_BAR_HEIGHT 65.0



- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //initialize user info
    self.user = [UserInfo user];
    [self.searchDisplayController setDelegate:self];
    searchBar.delegate = self;
    [searchBar setHidden:YES];

    
    
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}





- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //only one section is needed
    return 1;
    
}


-(void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    
        // Cancel any previous searches.
        [localSearch cancel];
        
        // Perform a new search.
        MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
        request.naturalLanguageQuery = searchBar.text;
//        request.region = self.mapView.region;
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        localSearch = [[MKLocalSearch alloc] initWithRequest:request];
        
        [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            if (error != nil) {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Map Error",nil)
                                            message:[error localizedDescription]
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
                return;
            }
            
            if ([response.mapItems count] == 0) {
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Results",nil)
                                            message:nil
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
                return;
            }
            
            results = response;
            
            [self.searchDisplayController.searchResultsTableView reloadData];
        }];
    }


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //height for custom cell
	return 55;
    
}



//*******************************

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomTableCell";
    ZoomCell *cell = (ZoomCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[ZoomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Display recipe in the table cell
    address = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        address = [searchResults objectAtIndex:indexPath.row];
    } else {
        address = [addresses objectAtIndex:indexPath.row];
    }
    
    cell.name.text = address.address;
    cell.distance.text = address.area;
  
    MKMapItem *item = results.mapItems[indexPath.row];
    
    cell.name.text = item.name;
    cell.distance.text = item.placemark.addressDictionary[@"Street"];

    return cell;
}

//*******************************

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    address = [addresses objectAtIndex:indexPath.row];
    
//    [self.searchDisplayController setActive:NO animated:YES];
//    
//    MKMapItem *item = results.mapItems[indexPath.row];
//    [self.mapView addAnnotation:item.placemark];
//    [self.mapView selectAnnotation:item.placemark animated:YES];
//    
//    [self.mapView setCenterCoordinate:item.placemark.location.coordinate animated:YES];
//    
//    [self.mapView setUserTrackingMode:MKUserTrackingModeNone];

}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //if search bar length equal to 0, allow to delete since it is previous search history data
    if(self.searchBar.text.length == 0){
        
        return true;
        
    }
    
    return false;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [results.mapItems count];
}





@end
