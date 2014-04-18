//
//  WhenViewController.h
//  WheelsUp
//
//  Created by Konrad Przyludzki on 14.04.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZFormSheetController.h"
#import "WHLSearchViewController.h"
#import "RDVCalendarView.h"

@interface WhenViewController : UIViewController <RDVCalendarViewDelegate>

@property (strong, nonatomic) WHLSearchViewController *parent;

@property (strong, nonatomic) RDVCalendarView *calendarView;

@end
