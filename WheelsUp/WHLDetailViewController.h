//
//  WHLDetailViewController.h
//  WheelsUp
//
//  Created by Broc Pacholik  on 2014-01-07.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHLDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
