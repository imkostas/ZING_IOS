//
//  Settings.m
//  Zing
//
//  Created by imkostas on 9/9/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import "Settings.h"
#import "GlobalData.h" 

@interface Settings ()

@end


@implementation Settings

@synthesize usernameTextField;
@synthesize askMeSwitch;
@synthesize accuracySwitch;
@synthesize unitsSwitch;

NSString *username;
BOOL askMe;
BOOL accuracy;
BOOL units;

- (void)viewDidLoad {
    
    [super viewDidLoad];

    
    // Do any additional setup after loading the view.
    username    = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    askMe       = [[NSUserDefaults standardUserDefaults] boolForKey:@"askMe"];
    accuracy    = [[NSUserDefaults standardUserDefaults] boolForKey:@"accuracy"];
    units       = [[NSUserDefaults standardUserDefaults] boolForKey:@"units"];
    
    [usernameTextField setText:username]; 
    [askMeSwitch    setOn:askMe];
    [accuracySwitch setOn:accuracy];
    [unitsSwitch    setOn:units];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)cancel:(id)sender
{
    [self.delegate      settingsDidCancel:self];
    
    // keep as is
    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] setBool:askMe forKey:@"askMe"];
    [[NSUserDefaults standardUserDefaults] setBool:accuracy forKey:@"accuracy"];
    [[NSUserDefaults standardUserDefaults] setBool:units forKey:@"units"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
   
}
- (IBAction)done:(id)sender
{
    [self.delegate settingsDidSave:self];
    
    // update
    [[NSUserDefaults standardUserDefaults] setObject:usernameTextField.text forKey:@"username"];

    [GlobalData shared].askMe = askMe;
    [[NSUserDefaults standardUserDefaults] setBool:[askMeSwitch isOn] forKey:@"askMe"];
    [GlobalData shared].accuracy = accuracy;
    [[NSUserDefaults standardUserDefaults] setBool:[accuracySwitch isOn] forKey:@"accuracy"];
    [GlobalData shared].units = units;
    [[NSUserDefaults standardUserDefaults] setBool:[unitsSwitch isOn] forKey:@"units"];
    NSLog(@"1111   %d", [[NSUserDefaults standardUserDefaults] boolForKey:@"units"]);
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(IBAction)changeName:(id)sender{
    
    [[NSUserDefaults standardUserDefaults] setObject:usernameTextField.text forKey:@"username"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (IBAction)askMe:(id)sender{
    
    [[NSUserDefaults standardUserDefaults] setBool:[askMeSwitch isOn] forKey:@"askMe"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
- (IBAction)accuracy:(id)sender{
    
    [[NSUserDefaults standardUserDefaults] setBool:[accuracySwitch isOn] forKey:@"accuracy"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
}

- (IBAction)units:(id)sender{
    
    [[NSUserDefaults standardUserDefaults] setBool:[unitsSwitch isOn] forKey:@"units"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
}



@end
