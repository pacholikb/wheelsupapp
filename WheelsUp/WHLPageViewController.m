//
//  WHLPageViewController.m
//  WheelsUp
//
//  Created by Konrad Przyludzki on 18.03.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "WHLPageViewController.h"
#import "PageContentViewController.h"

@interface WHLPageViewController ()

@end

@implementation WHLPageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.dataSource = self;
    self.delegate = self;
    
    [self setViewControllers:@[[self viewControllerAtIndex:1]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == 4) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
    
}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    
    PageContentViewController *pageContentViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

@end
