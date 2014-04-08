//
//  WHLFlightDetailsViewController.h
//  WheelsUp
//
//  Created by Konrad Przyludzki on 04.03.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Flight.h"

@interface WHLFlightDetailsViewController : UITableViewController

@property (nonatomic, strong) Flight *flight;
@property (nonatomic, strong) NSArray *outbounds;
@property (nonatomic, strong) NSArray *inbounds;
@property (nonatomic, strong) NSDateFormatter* dateFormatter;
@property (nonatomic, strong) NSDateFormatter* dateFormatterOutput;
@property (nonatomic, strong) NSString* location;

@end
