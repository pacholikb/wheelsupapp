//
//  WhereViewController.h
//  WheelsUp
//
//  Created by Konrad Przyludzki on 19.03.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WHLSearchViewController.h"
#import "MZFormSheetController.h"

@interface WhereViewController : UIViewController <UITextFieldDelegate, kDropDownListViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *toTF;
@property (strong, nonatomic) WHLSearchViewController *parent;

@property (strong) DropDownListView * Dropobj;
@property (strong) NSArray *dropdownOptions;

@end
