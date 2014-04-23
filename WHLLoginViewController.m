//
//  WHLLoginViewController.m
//  WheelsUp
//
//  Created by Broc Pacholik  on 2014-01-11.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "WHLProfileViewController.h"
#import "WHLFBProfileViewController.h"
#import "WHLLoginViewController.h"
#import "WHLNetworkManager.h"
#import <Parse/Parse.h>
#import "REMenu.h"

@interface WHLLoginViewController ()

@end

@implementation WHLLoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    [self setTitle : @"Login"];
    
    [[WHLNetworkManager sharedInstance] setBackgroundGradient:self.view];
    
    (_facebookLoginImage.image = [UIImage imageNamed:@"homebg(320x568).png"]);

    WHLMenuViewController *nav = (WHLMenuViewController *)self.navigationController;
    [nav.menu setItems:@[ nav.searchItem, nav.recentItem, nav.discoveryItem ]];
    

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:tapGesture];
    
    _activityIndicator.hidden = YES;
    
    self.navigationItem.leftBarButtonItem = [ [ UIBarButtonItem alloc ] initWithTitle : @"Menu" style : UIBarButtonItemStyleBordered target : self.navigationController action : @selector( toggleMenu ) ] ;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)hideKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)loginButtonTouchHandler:(id)sender {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    _activityIndicator.hidden = NO;
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        _activityIndicator.hidden = YES; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                
            } else {
               NSLog(@"%@",error);
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [self performSegueWithIdentifier:@"showFBProfile" sender:nil];
        } else {
            NSLog(@"User with facebook logged in!");
            [self performSegueWithIdentifier:@"showFBProfile" sender:nil];
        }
    }];
    
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}
@end
