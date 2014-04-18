//
//  WhenViewController.m
//  WheelsUp
//
//  Created by Konrad Przyludzki on 14.04.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "WhenViewController.h"

@interface WhenViewController ()

@end

@implementation WhenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _calendarView = [[RDVCalendarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
    [_calendarView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_calendarView setSeparatorStyle:RDVCalendarViewDayCellSeparatorTypeHorizontal];
    [_calendarView setBackgroundColor:[UIColor whiteColor]];
    [_calendarView setDelegate:self];
    
    [self.view addSubview:_calendarView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveAction:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY-MM-d";
    
    _parent.departureDateString = [dateFormatter stringFromDate:_calendarView.selectedDate];
    _parent.isDataChanged = YES;
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}



@end
