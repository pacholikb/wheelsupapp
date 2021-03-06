//
//  WHLSearchResultsViewController.h
//  WheelsUp
//
//  Created by Konrad Przyludzki on 18.02.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "WHLSearchViewController.h"
#import "Flight.h"
#import "Weather.h"
#import "Trip.h"
#import "Event.h"
#import "SearchModel.h"

@class WHLSearchViewController;

@interface WHLSearchResultsViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate ,UIScrollViewDelegate, MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong) NSArray *flights;

@property (strong, nonatomic) IBOutlet UILabel *weatherLabelHeader;
@property (strong, nonatomic) IBOutlet UILabel *dayLabelFirst;
@property (strong, nonatomic) IBOutlet UILabel *dayLabelSecond;
@property (strong, nonatomic) IBOutlet UILabel *dayLabelThird;
@property (strong, nonatomic) IBOutlet UILabel *tempLabelFirst;
@property (strong, nonatomic) IBOutlet UILabel *tempLabelSecond;
@property (strong, nonatomic) IBOutlet UILabel *tempLabelThird;
@property (strong, nonatomic) IBOutlet UIImageView *weatherIconFirst;
@property (strong, nonatomic) IBOutlet UIImageView *weatherIconSecond;
@property (strong, nonatomic) IBOutlet UIImageView *weatherIconThird;
@property (strong, nonatomic) IBOutlet UILabel *conditionsLabelFirst;
@property (strong, nonatomic) IBOutlet UILabel *conditionsLabelSecond;
@property (strong, nonatomic) IBOutlet UILabel *conditionsLabelThird;
@property (strong, nonatomic) IBOutlet UITableView *eventsTableView;
@property (strong) NSArray *eventsArray;
@property (nonatomic, strong) NSDateFormatter* dateFormatterOutput;

@property (strong) NSArray *weatherArray;
@property (strong) Flight *selectedFlight;

@property (strong) WHLSearchViewController* delegate;

@property (strong) Trip *trip;
@property (strong) NSString *departureCityName;
@property (strong) NSString *arrivalCityName;

@property (strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) MKPolyline *routeLine;
@property (nonatomic, strong) MKPolylineView *routeLineView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIView *dropDownView;

@property (strong, nonatomic) IBOutlet UILabel *noEventsLabel;
@property (strong, nonatomic) IBOutlet UILabel *noWeatherLabel;

@property (assign) BOOL pageControlBeingUsed;
 
@end
