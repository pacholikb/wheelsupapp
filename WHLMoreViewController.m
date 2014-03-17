//
//  WHLMoreViewController.m
//  WheelsUp
//
//  Created by Konrad Przyludzki on 10.03.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "WHLMoreViewController.h"

@interface WHLMoreViewController ()

@end

@implementation WHLMoreViewController

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
    
    [_stopsSC addTarget:self action:@selector(stopsChanged:) forControlEvents:UIControlEventValueChanged];
    [_stopsSC setSelectedSegmentIndex:2];
    
    if(_parent.numberOfStops == nil)
        [_stopsSC setSelectedSegmentIndex:3];
    else if([_parent.numberOfStops isEqualToString:@"none"])
        [_stopsSC setSelectedSegmentIndex:0];
    else if([_parent.numberOfStops isEqualToString:@"one"])
        [_stopsSC setSelectedSegmentIndex:1];
    else if([_parent.numberOfStops isEqualToString:@"two_plus"])
        [_stopsSC setSelectedSegmentIndex:2];
    
    if(_parent.maxPrice > 0)
        _maxPriceTF.text = [NSString stringWithFormat:@"%d",_parent.maxPrice];
    
    [_adultsPicker selectRow:_parent.adultsCount-1 inComponent:0 animated:NO];
    [_childrenPicker selectRow:_parent.childrenCount inComponent:0 animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == _maxPriceTF)
    {
        _parent.maxPrice = [_maxPriceTF.text integerValue];
    }
}

#pragma pickerView delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView == _adultsPicker)
        _parent.adultsCount = row+1;
    else
        _parent.childrenCount = row;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView == _adultsPicker)
        return 10;
    else
        return 11;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView == _adultsPicker)
        return [NSString stringWithFormat:@"%d",row+1];
    else
        return [NSString stringWithFormat:@"%d",row];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (void)stopsChanged:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0:
            _parent.numberOfStops = @"none";
            break;
        case 1:
            _parent.numberOfStops = @"one";
            break;
        case 2:
            _parent.numberOfStops = @"two_plus";
            break;
        case 3:
            _parent.numberOfStops = nil;
            
        default:
            break;
    }
    NSLog(@"%@",_parent.numberOfStops);
}

@end
