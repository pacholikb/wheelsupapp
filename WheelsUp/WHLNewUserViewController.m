//
//  WHLNewUserViewController.m
//  WheelsUp
//
//  Created by Broc Pacholik  on 2014-01-11.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "WHLNewUserViewController.h"
#import "WHLNetworkManager.h"
#import <Parse/Parse.h>

@interface WHLNewUserViewController ()

@end

@implementation WHLNewUserViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[WHLNetworkManager sharedInstance] setBackgroundGradient:self.view];
}

- (IBAction)signupButton:(id)sender {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    NSString *email = self.emailField.text;
    
    if ([username length] == 0 || [password length] == 0 || [email length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"Make sure you fill out all the fields!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        
        [alertView show];
    }
    else {
        PFUser *newUser = [PFUser user];
        newUser.username = username;
        newUser.password = password;
        newUser.email = email;
        
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                                    message:[error.userInfo
                                                                             objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
            else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            
        }];
        
    }
 
}
@end
