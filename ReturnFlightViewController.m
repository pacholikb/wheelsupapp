//
//  ReturnFlightViewController.m
//  WheelsUp
//
//  Created by Konrad Przyludzki on 08.04.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "ReturnFlightViewController.h"

@interface ReturnFlightViewController ()

@end

@implementation ReturnFlightViewController

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
	// Do any additional setup after loading the view.
    _calendarView = [[RDVCalendarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
    [_calendarView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_calendarView setSeparatorStyle:RDVCalendarViewDayCellSeparatorTypeHorizontal];
    [_calendarView setBackgroundColor:[UIColor whiteColor]];
    [_calendarView setDelegate:self];
    _calendarView.selectedDate = [NSDate date];
    
    [self.view addSubview:_calendarView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)saveAction:(id)sender {
    NSString *localFormat = [NSDateFormatter dateFormatFromTemplate:@"MMM dd yyyy" options:0 locale:[NSLocale currentLocale]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = localFormat;
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    dateFormatter2.dateFormat = @"YYYY-MM-d";
    
    NSString *date = [dateFormatter stringFromDate:_calendarView.selectedDate];
    _parent.returnDateString = [dateFormatter2 stringFromDate:_calendarView.selectedDate];
    _parent.isOneWay = NO;
    [_parent.returnFlightBtn setTitle:[NSString stringWithFormat:@"Return On %@",date] forState:UIControlStateNormal];
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}
- (IBAction)oneWayAction:(id)sender {
    _parent.isOneWay = YES;
    [_parent.returnFlightBtn setTitle:@"One Way" forState:UIControlStateNormal];
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

@end
