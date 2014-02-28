//
//  WHLRecentViewController.h
//  WheelsUp
//
//  Created by Broc Pacholik  on 2014-01-09.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WHLMenuItemViewController.h"
#import "WHLMenuViewController.h"
#import "Trip.h"


@interface WHLRecentViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong) NSArray *flights;
@property (strong) Trip *selectedTrip;

@end
