//
//  WHLLoginViewController.m
//  WheelsUp
//
//  Created by Broc Pacholik  on 2014-01-11.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "WHLProfileViewController.h"
#import "WHLLoginViewController.h"
#import <Parse/Parse.h>
#import "REMenu.h"

@interface WHLLoginViewController ()

@end

@implementation WHLLoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    [self setTitle : @"Login"];
    
    self.navigationItem.leftBarButtonItem = [ [ UIBarButtonItem alloc ] initWithTitle : @"Menu" style : UIBarButtonItemStyleBordered target : self.navigationController action : @selector( toggleMenu ) ] ;
    
    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
        [self performSegueWithIdentifier:@"showFBProfile" sender:self];
    else if([PFUser currentUser])
        [self performSegueWithIdentifier:@"showProfile" sender:self];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:tapGesture];
    
    _activityIndicator.hidden = YES;
    
    self.navigationItem.leftBarButtonItem = [ [ UIBarButtonItem alloc ] initWithTitle : @"Menu" style : UIBarButtonItemStyleBordered target : self.navigationController action : @selector( toggleMenu ) ] ;
}

- (void)hideKeyboard:(id)sender
{
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];
}
    
- (IBAction)login:(id)sender {
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([username length] == 0 || [password length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"Make sure you fill out all the fields!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        
        [alertView show];
    }
    else {
        [_activityIndicator startAnimating];
        _activityIndicator.hidden = NO;
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                                    message:[error.userInfo
                                                                             objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
            else {
                NSLog(@"Logged in successfuly");
                [self performSegueWithIdentifier:@"showProfile" sender:nil];
            }
            _activityIndicator.hidden = YES;
        }];
    }
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
