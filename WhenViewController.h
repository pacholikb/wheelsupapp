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

@interface WhenViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) WHLSearchViewController *parent;

@end
