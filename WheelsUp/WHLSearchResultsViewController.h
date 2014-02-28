//
//  WHLSearchResultsViewController.h
//  WheelsUp
//
//  Created by Konrad Przyludzki on 18.02.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Flight.h"
#import "Weather.h"
#import "Trip.h"
#import "SearchModel.h"

@interface WHLSearchResultsViewController : UITableViewController

@property (strong) NSArray *flights;

@property (strong) NSArray *weatherArray;
@property (strong) Flight *selectedFlight;

@property (strong) Trip *trip;
@property (strong) NSString *departureCityName;
@property (strong) NSString *arrivalCityName;

@property (strong) NSDateFormatter *dateFormatter;
 
@end
