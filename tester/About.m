//
//  About.m
//  Zing
//
//  Created by Kostas on 8/2/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import "About.h"
#import "SWRevealViewController.h"

@interface About ()

@end

@implementation About

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"News";
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
