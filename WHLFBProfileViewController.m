//
//  WHLFBProfileViewController.m
//  WheelsUp
//
//  Created by Broc Pacholik  on 2014-01-12.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "WHLFBProfileViewController.h"
#import "WHLMenuViewController.h"
#import "WHLLoginViewController.h"
#import <Parse/Parse.h>
#import "REMenu.h"

@interface WHLFBProfileViewController ()

@end

@implementation WHLFBProfileViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Profile";
    
    WHLMenuViewController *nav = (WHLMenuViewController *)self.navigationController;
    [nav.menu setItems:@[ nav.searchItem, nav.recentItem, nav.discoveryItem ]];
    
    // If the user is already logged in, display any previously cached values before we get the latest from Facebook.
    if ([PFUser currentUser]) {
        [self updateProfile];
    }
    
    // Send request to Facebook
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            
            NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:7];
            
            if (facebookID) {
                userProfile[@"facebookId"] = facebookID;
            }
            
            if (userData[@"name"]) {
                userProfile[@"name"] = userData[@"name"];
            }
            
            if (userData[@"location"][@"name"]) {
                userProfile[@"location"] = userData[@"location"][@"name"];
            }
            
            if (userData[@"gender"]) {
                userProfile[@"gender"] = userData[@"gender"];
            }
            
            if (userData[@"birthday"]) {
                userProfile[@"birthday"] = userData[@"birthday"];
            }
            
            if (userData[@"relationship_status"]) {
                userProfile[@"relationship"] = userData[@"relationship_status"];
            }
            
            if ([pictureURL absoluteString]) {
                userProfile[@"pictureURL"] = [pictureURL absoluteString];
            }
            
            [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
            [[PFUser currentUser] saveInBackground];
            
            [self updateProfile];
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
            [self logoutAction:nil];
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
	
    self.navigationItem.leftBarButtonItem = [ [ UIBarButtonItem alloc ] initWithTitle : @"Menu" style : UIBarButtonItemStyleBordered target : self.navigationController action : @selector( toggleMenu ) ] ;
    
}

- (IBAction)facebookShare:(id)sender {
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil message:@"Check this out" title:@"WheelsUp" parameters:nil handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
        if (error) {
            // Case A: Error launching the dialog or sending request.
            NSLog(@"Error sending request.");
        } else {
            if (result == FBWebDialogResultDialogNotCompleted) {
                // Case B: User clicked the "x" icon
                NSLog(@"User canceled request.");
            } else {
                NSLog(@"Request Sent.");
            }
        }
    }];
    
}

#pragma mark - NSURLConnectionDataDelegate

/* Callback delegate methods used for downloading the user's profile picture */

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // As chuncks of the image are received, we build our data file
    [self.imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // All data has been downloaded, now we can set the image in the header image view
    self.headerImageView.image = [UIImage imageWithData:self.imageData];
    
    // Add a nice corner radius to the image
    self.headerImageView.layer.cornerRadius = 8.0f;
    self.headerImageView.layer.masksToBounds = YES;
}

//
//#pragma mark - UITableViewDataSource
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    // Return the number of rows in the section.
//    return self.rowTitleArray.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    if (cell == nil) {
//        // Create the cell and add the labels
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, 120.0f, 44.0f)];
//        titleLabel.tag = 1; // We use the tag to set it later
//        titleLabel.textAlignment = NSTextAlignmentRight;
//        titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
//        titleLabel.backgroundColor = [UIColor clearColor];
//        
//        UILabel *dataLabel = [[UILabel alloc] initWithFrame:CGRectMake( 130.0f, 0.0f, 165.0f, 44.0f)];
//        dataLabel.tag = 2; // We use the tag to set it later
//        dataLabel.font = [UIFont systemFontOfSize:15.0f];
//        dataLabel.backgroundColor = [UIColor clearColor];
//        
//        [cell.contentView addSubview:titleLabel];
//        [cell.contentView addSubview:dataLabel];
//    }
//    
//    // Cannot select these cells
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    
//    // Access labels in the cell using the tag #
//    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
//    UILabel *dataLabel = (UILabel *)[cell viewWithTag:2];
//    
//    // Display the data in the table
//    titleLabel.text = [self.rowTitleArray objectAtIndex:indexPath.row];
//    dataLabel.text = [self.rowDataArray objectAtIndex:indexPath.row];
//    
//    return cell;
//}


#pragma mark - ()
- (IBAction)logoutAction:(id)sender {
    [PFUser logOut];
    
    // Return to login view controller
    WHLLoginViewController* viewController = [ self.storyboard instantiateViewControllerWithIdentifier : @"WHLLoginViewController" ];
    [ self.navigationController setViewControllers : @[ viewController ] animated : YES ] ;
}

// Set received values if they are not nil and reload the table
- (void)updateProfile {
    if ([[PFUser currentUser] objectForKey:@"profile"][@"location"]) {
        [self.rowDataArray replaceObjectAtIndex:0 withObject:[[PFUser currentUser] objectForKey:@"profile"][@"location"]];
    }
    
    if ([[PFUser currentUser] objectForKey:@"profile"][@"gender"]) {
        [self.rowDataArray replaceObjectAtIndex:1 withObject:[[PFUser currentUser] objectForKey:@"profile"][@"gender"]];
    }
    
    if ([[PFUser currentUser] objectForKey:@"profile"][@"birthday"]) {
        [self.rowDataArray replaceObjectAtIndex:2 withObject:[[PFUser currentUser] objectForKey:@"profile"][@"birthday"]];
    }
    
    if ([[PFUser currentUser] objectForKey:@"profile"][@"relationship"]) {
        [self.rowDataArray replaceObjectAtIndex:3 withObject:[[PFUser currentUser] objectForKey:@"profile"][@"relationship"]];
    }
    
    
    // Set the name in the header view label
    if ([[PFUser currentUser] objectForKey:@"profile"][@"name"]) {
        self.headerNameLabel.text = [[PFUser currentUser] objectForKey:@"profile"][@"name"];
    }
    
    // Set the location in the header view label
    if ([[PFUser currentUser] objectForKey:@"profile"][@"location"]) {
        self.headeruserLocation.text = [[PFUser currentUser] objectForKey:@"profile"][@"location"];
    }

    
    // Download the user's facebook profile picture
    self.imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
    
    if ([[PFUser currentUser] objectForKey:@"profile"][@"pictureURL"]) {
        NSURL *pictureURL = [NSURL URLWithString:[[PFUser currentUser] objectForKey:@"profile"][@"pictureURL"]];
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
                                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                              timeoutInterval:2.0f];
        // Run network request asynchronously
        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        if (!urlConnection) {
            NSLog(@"Failed to download picture");
        }
    }
}




@end
