//
//  WHLSearchViewController.m
//  WheelsUp
//
//  Created by Broc Pacholik  on 2014-01-09.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "WHLSearchViewController.h"
#import "REMenu.h"
#import <Parse/Parse.h>

@interface WHLSearchViewController ()

@end

@implementation WHLSearchViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [ self setTitle : @"Search" ] ;
    
     self.navigationItem.leftBarButtonItem = [ [ UIBarButtonItem alloc ] initWithTitle : @"Menu" style : UIBarButtonItemStyleBordered target : self.navigationController action : @selector( toggleMenu ) ] ;
  }



@end
