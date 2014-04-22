//
//  WHLMenuViewController.h
//  WheelsUp
//
//  Created by Broc Pacholik  on 2014-01-09.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WHLProfileViewController.h"
#import "WHLSearchViewController.h"
#import "WHLRecentViewController.h"
#import "DiscoveryViewController.h"
#import "WHLLoginViewController.h"
#import "WHLFBProfileViewController.h"
#import <Parse/Parse.h>
#import "REMenu.h"

@class REMenu;

@interface WHLMenuViewController : UINavigationController

@property (readonly, strong, nonatomic) REMenu* menu;
@property (nonatomic, strong) REMenuItem* searchItem;
@property (nonatomic, strong) REMenuItem* profileItem;
@property (nonatomic, strong) REMenuItem* recentItem;
@property (nonatomic, strong) REMenuItem* discoveryItem;

- (void) toggleMenu;

@end
