//
//  WHLLoginViewController.h
//  WheelsUp
//
//  Created by Broc Pacholik  on 2014-01-11.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <Parse/Parse.h>

@interface WHLLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)login:(id)sender;
- (IBAction)signUp:(id)sender;

- (IBAction)loginButtonTouchHandler:(id)sender;
@end
