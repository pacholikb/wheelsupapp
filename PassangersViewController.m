//
//  PassangersViewController.m
//  WheelsUp
//
//  Created by Konrad Przyludzki on 19.03.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "PassangersViewController.h"
#import "MZFormSheetController.h"

@interface PassangersViewController ()

@end

@implementation PassangersViewController

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
	
    _adultsCountLabel.text = [NSString stringWithFormat:@"%d",_parent.adultsCount];
    _childrenCountLabel.text = [NSString stringWithFormat:@"%d",_parent.childrenCount];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)adultAdd:(id)sender {
    if(_parent.adultsCount < 10)
        _parent.adultsCount ++;
    
    _adultsCountLabel.text = [NSString stringWithFormat:@"%d",_parent.adultsCount];
}
- (IBAction)adultRemove:(id)sender {
    if(_parent.adultsCount > 1)
        _parent.adultsCount --;
    
    _adultsCountLabel.text = [NSString stringWithFormat:@"%d",_parent.adultsCount];
}

- (IBAction)childAdd:(id)sender {
    if(_parent.childrenCount < 10)
        _parent.childrenCount ++;
    
    _childrenCountLabel.text = [NSString stringWithFormat:@"%d",_parent.childrenCount];
}
- (IBAction)childRemove:(id)sender {
    if(_parent.childrenCount > 0)
        _parent.childrenCount --;
    
    _childrenCountLabel.text = [NSString stringWithFormat:@"%d",_parent.childrenCount];
}

- (IBAction)doneAction:(id)sender {
    NSString *adultsPart;
    NSString *childrenPart = @"";
    
    if(_parent.adultsCount == 1 && _parent.childrenCount == 0)
        adultsPart = @"Solo";
    else if(_parent.adultsCount == 1)
        adultsPart = @"With an adult";
    else
        adultsPart = [NSString stringWithFormat:@"With %d adults",_parent.adultsCount];
    
    if (_parent.childrenCount == 1)
        childrenPart = @" and a child";
    else if(_parent.childrenCount > 1)
        childrenPart = [NSString stringWithFormat:@" and %d children",_parent.childrenCount];
    
    NSLog(@"%@",[NSString stringWithFormat:@"%@%@",adultsPart,childrenPart]);
    [_parent.passangersBtn setTitle:[NSString stringWithFormat:@"%@%@",adultsPart,childrenPart] forState:UIControlStateNormal];
    
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

@end
