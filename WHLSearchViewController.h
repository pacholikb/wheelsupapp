//
//  WHLSearchViewController.h
//  WheelsUp
//
//  Created by Broc Pacholik  on 2014-01-09.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "WHLMenuItemViewController.h"
#import "WHLMenuViewController.h"
#import "WHLSearchResultsViewController.h"
#import "SearchModel.h"
#import "Flight.h"
#import "Trip.h"
#import "DropDownListView.h"

@interface WHLSearchViewController : UIViewController <CLLocationManagerDelegate, UITextFieldDelegate, kDropDownListViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *fromTF;
@property (strong, nonatomic) IBOutlet UITextField *toTF;
@property (strong) NSString *fromCode;
@property (strong) NSString *toCode;

@property (strong, nonatomic) IBOutlet UIButton *searchButton;

@property (strong, nonatomic) Trip *trip;
@property (strong) NSArray *flights;

@property (strong) DropDownListView * Dropobj;
@property (strong) NSArray *dropdownOptions;
@property (assign) BOOL dropdownTo;

@property (assign) NSInteger maxPrice;
@property (assign) NSInteger adultsCount;
@property (assign) NSInteger childrenCount;
@property (strong) NSString *numberOfStops;

@end
