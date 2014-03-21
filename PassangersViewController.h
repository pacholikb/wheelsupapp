//
//  PassangersViewController.h
//  WheelsUp
//
//  Created by Konrad Przyludzki on 19.03.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WHLSearchViewController.h"

@interface PassangersViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *adultsCountLabel;
@property (strong, nonatomic) IBOutlet UIButton *adultsAdd;
@property (strong, nonatomic) IBOutlet UIButton *adultsRemove;

@property (strong, nonatomic) IBOutlet UILabel *childrenCountLabel;
@property (strong, nonatomic) IBOutlet UIButton *childrenAdd;
@property (strong, nonatomic) IBOutlet UIButton *childrenRemove;

@property (nonatomic, strong) WHLSearchViewController *parent;

@end
