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
    
    if(IS_WIDESCREEN){
        NSLog(@"iPhone5 screen size");
        switch (_pageIndex) {
            case 1:
                (_imageView.image = [UIImage imageNamed:@"instr1_5s.png"]);
                break;
            case 2:
                (_imageView.image = [UIImage imageNamed:@"instr2_5s.png"]);
                break;
            case 3:
                (_imageView.image = [UIImage imageNamed:@"instr3_5s.png"]);
                break;
                
            default:
                break;
        }
       
        
    }
        else {
            
            NSLog(@"normal iPhone screen dimensions");
            switch (_pageIndex) {
                case 1:
                    (_imageView.image = [UIImage imageNamed:@"Instr1.png"]);
                    break;
                case 2:
                    (_imageView.image = [UIImage imageNamed:@"instr2.png"]);
                    break;
                case 3:
                    (_imageView.image = [UIImage imageNamed:@"instr3.png"]);
                    break;
                    
                default:
                    break;
            }
      
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
