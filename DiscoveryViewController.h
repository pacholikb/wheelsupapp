//
//  DiscoveryViewController.h
//  WheelsUp
//
//  Created by Konrad Przyludzki on 15.04.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REMenu.h"
#import "BlogPost.h"
#import "WHLNetworkManager.h"

@interface DiscoveryViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
