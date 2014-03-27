//
//  PageContentViewController.m
//  WheelsUp
//
//  Created by Konrad Przyludzki on 18.03.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "PageContentViewController.h"

#define IS_WIDESCREEN ( [ [ UIScreen mainScreen ] bounds ].size.height == 568  )

@interface PageContentViewController ()

@end

@implementation PageContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(IS_WIDESCREEN)
        NSLog(@"iPhone5 screen size");
    else
        NSLog(@"normal iPhone screen dimensions");
    
    switch (_pageIndex) {
        case 1:
            (_imageView.image = [UIImage imageNamed:@"homebg(320x568).png"]);
            break;
        case 2:
            //set image here
            break;
        case 3:
            //set image here
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)quitSlideshow:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"intro"];
    [defaults synchronize];
    
    [self.parentViewController performSegueWithIdentifier:@"menuSegue" sender:nil];
}

@end
