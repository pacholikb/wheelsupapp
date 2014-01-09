//
//  WHLProfileViewController.m
//  WheelsUp
//
//  Created by Broc Pacholik  on 2014-01-09.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "WHLProfileViewController.h"

@interface WHLProfileViewController ()

@end

@implementation WHLProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [ self setTitle : @"Profile" ] ;
    
    self.navigationItem.leftBarButtonItem = [ [ UIBarButtonItem alloc ] initWithTitle : @"Menu" style : UIBarButtonItemStyleBordered target : self.navigationController action : @selector( toggleMenu ) ] ;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
