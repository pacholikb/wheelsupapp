//
//  WHLMoreViewController.h
//  WheelsUp
//
//  Created by Konrad Przyludzki on 10.03.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WHLSearchViewController.h"

@interface WHLMoreViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIPickerView *adultsPicker;
@property (strong, nonatomic) IBOutlet UIPickerView *childrenPicker;

@property (strong, nonatomic) IBOutlet UITextField *maxPriceTF;

@property (strong, nonatomic) IBOutlet UISegmentedControl *stopsSC;

@property (assign, nonatomic) WHLSearchViewController *parent;

@end
