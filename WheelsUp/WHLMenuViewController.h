//
//  WHLMenuViewController.h
//  WheelsUp
//
//  Created by Broc Pacholik  on 2014-01-09.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <UIKit/UIKit.h>

@class REMenu;

@interface WHLMenuViewController : UINavigationController

@property (readonly, strong, nonatomic) REMenu* menu;

- (void) toggleMenu;

@end
