//
//  Settings.h
//  Zing
//
//  Created by imkostas on 9/9/16.
//  Copyright © 2016 Kostas Terzidis. All rights reserved.
//

#import <UIKit/UIKit.h> 


@class Settings;

@protocol SettingsDelegate <NSObject>
- (void)settingsDidCancel:(Settings *)controller;
- (void)settingsDidSave:(Settings *)controller;
@end

@interface Settings : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField; //for entering username textfield
@property (strong, nonatomic) IBOutlet UISwitch *askMeSwitch;  //Ask me before pairing
@property (strong, nonatomic) IBOutlet UISwitch *accuracySwitch;  //accuracy
@property (strong, nonatomic) IBOutlet UISwitch *unitsSwitch;  //units

@property (nonatomic, weak) id <SettingsDelegate> delegate;

- (IBAction)changeName:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)askMe:(id)sender;
- (IBAction)accuracy:(id)sender;
- (IBAction)units:(id)sender;

@end