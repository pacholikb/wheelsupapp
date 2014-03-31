//
//  WHLIntroViewController.m
//  WheelsUp
//
//  Created by Konrad Przyludzki on 28.03.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "WHLIntroViewController.h"

#define IS_WIDESCREEN ( [ [ UIScreen mainScreen ] bounds ].size.height == 568  )

@interface WHLIntroViewController ()

@end

@implementation WHLIntroViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    if(IS_WIDESCREEN){

        (_image1.image = [UIImage imageNamed:@"instr1_5s.png"]);

        (_image2.image = [UIImage imageNamed:@"instr2_5s.png"]);

        (_image3.image = [UIImage imageNamed:@"instr3_5s.png"]);
        
    }
    else {
        
        (_image1.image = [UIImage imageNamed:@"instr1.png"]);
        
        (_image2.image = [UIImage imageNamed:@"instr2.png"]);
        
        (_image3.image = [UIImage imageNamed:@"instr3.png"]);
        
    }

}

- (void)viewDidDisappear:(BOOL)animated
{
   
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Update the page when more than 50% of the previous/next page is visible
    if(!_pageControlBeingUsed) {
        CGFloat pageWidth = self.scrollView.frame.size.width;
        int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.pageControl.currentPage = page;
    }
}

- (void)viewDidLayoutSubviews
{
    [_scrollView setContentSize:CGSizeMake(960, _scrollView.frame.size.height)];
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
    
    [self performSegueWithIdentifier:@"menuSegue" sender:nil];
}

- (IBAction)changePage {
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
    _pageControlBeingUsed = YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _pageControlBeingUsed = NO;
}

@end
