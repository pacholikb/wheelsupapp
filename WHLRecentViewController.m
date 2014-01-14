//
//  WHLRecentViewController.m
//  WheelsUp
//
//  Created by Broc Pacholik  on 2014-01-09.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "WHLRecentViewController.h"
#import "REMenu.h"

@interface WHLRecentViewController ()

@end

@implementation WHLRecentViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [ self setTitle : @"Recent" ] ;
    
    self.navigationItem.leftBarButtonItem = [[ UIBarButtonItem alloc ] initWithTitle : @"Menu" style : UIBarButtonItemStyleBordered target : self.navigationController action : @selector( toggleMenu ) ] ;
    

}


@end
