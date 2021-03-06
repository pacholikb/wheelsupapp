//
//  ReturnFlightViewController.h
//  WheelsUp
//
//  Created by Konrad Przyludzki on 08.04.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WHLSearchViewController.h"
#import "MZFormSheetController.h"
#import "RDVCalendarView.h"

@interface ReturnFlightViewController : UIViewController <RDVCalendarViewDelegate>

@property (strong, nonatomic) WHLSearchViewController *parent;
@property (strong, nonatomic) RDVCalendarView *calendarView;

@end
