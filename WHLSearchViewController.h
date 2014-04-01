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
#import "City.h"
#import "DropDownListView.h"
#import "MDCFocusView.h"
#import "MDCSpotlightView.h"

@interface WHLSearchViewController : UIViewController <CLLocationManagerDelegate, UITextFieldDelegate, kDropDownListViewDelegate>

typedef enum {
    anywhere,
    somewhereHot,
    place
} SearchMode;

@property (strong, nonatomic) IBOutlet UITextField *fromTF;
@property (strong, nonatomic) IBOutlet UIButton *passangersBtn;
@property (strong) NSString *fromCode;
@property (strong) NSString *toCode;

@property (strong, nonatomic) IBOutlet UIButton *searchButton;

@property (strong, nonatomic) Trip *trip;
@property (strong) NSArray *flights;

@property (strong) DropDownListView * Dropobj;
@property (strong) NSArray *dropdownOptions;

@property (assign) NSInteger maxPrice;
@property (assign) NSInteger adultsCount;
@property (assign) NSInteger childrenCount;
@property (strong) NSString *numberOfStops;

@property (assign) BOOL isFirstUse;
@property (assign) BOOL isLocationButtonClicked;
@property (assign) BOOL canCancelSearch;
@property (assign) BOOL isSearchCancelled;
@property (strong) NSTimer *cancelTimer;

@property (strong) MDCFocusView *focusView;

@property (strong, nonatomic) IBOutlet UIButton *showHideFiltersButton;
@property (assign) BOOL isFiltersViewVisible;
@property (strong, nonatomic) IBOutlet UIView *filtersView;
@property (strong, nonatomic) IBOutlet UITextField *maxPriceTF;
@property (strong, nonatomic) IBOutlet UIButton *whereButton;

@property (nonatomic, assign) SearchMode searchMode;

@end
