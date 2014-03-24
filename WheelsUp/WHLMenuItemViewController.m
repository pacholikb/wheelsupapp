//
//  WHLMenuItemViewController.m
//  WheelsUp
//
//  Created by Broc Pacholik  on 2014-01-09.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "WHLMenuViewController.h"
#import "WHLMenuItemViewController.h"

#import "REMenu.h"


@implementation WHLMenuItemViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
        self.navigationItem.leftBarButtonItem = [ [ UIBarButtonItem alloc ] initWithTitle : @"Menu" style : UIBarButtonItemStyleBordered target : self.navigationController action : @selector( toggleMenu ) ] ;
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    WHLMenuViewController* menuController = ( WHLMenuViewController* )self.navigationController ;
    [ menuController.menu setNeedsLayout ] ;
}


@end
