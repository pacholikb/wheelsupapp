//
//  WHLFlightDetailsViewController.h
//  WheelsUp
//
//  Created by Konrad Przyludzki on 04.03.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WHLSearchViewController.h"
#import "Flight.h"
#import "Flurry.h"

@interface WHLFlightDetailsViewController : UITableViewController <UIActivityItemSource>

@property (nonatomic, strong) Flight *flight;
@property (nonatomic, strong) NSArray *outbounds;
@property (nonatomic, strong) NSArray *inbounds;
@property (nonatomic, strong) NSDateFormatter* dateFormatter;
@property (nonatomic, strong) NSDateFormatter* dateFormatterOutput;
@property (nonatomic, strong) NSString* location;

@property (strong) WHLSearchViewController *delegate;

@end
