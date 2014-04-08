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
    
    NSString *date = [dateFormatter stringFromDate:_datePicker.date];
    _parent.returnDateString = [dateFormatter2 stringFromDate:_datePicker.date];
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
