//
//  WHLMenuViewController.m
//  WheelsUp
//
//  Created by Broc Pacholik  on 2014-01-09.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "WHLMenuViewController.h"

#import "WHLSearchViewController.h"
#import "WHLRecentViewController.h"
#import "WHLProfileViewController.h"

#import "REMenu.h"

@interface WHLMenuViewController ()

@property (readwrite, strong, nonatomic) REMenu* menu;

@end

@implementation WHLMenuViewController

- ( void ) viewDidLoad
{
    [ super viewDidLoad ] ;
    
    if( REUIKitIsFlatMode() )
    {
        [ self.navigationBar performSelector : @selector( setBarTintColor: ) withObject : [ UIColor colorWithRed : 84 / 255.0 green : 155 / 255.0 blue : 199 / 255.0 alpha : 1 ] ] ;
        
        self.navigationBar.tintColor = [ UIColor whiteColor ] ;
    }
    else
    {
        self.navigationBar.tintColor = [ UIColor colorWithRed : 0 green : 179 / 255.0 blue : 134 / 255.0 alpha : 1 ] ;
    }
    
    __typeof ( self ) __weak weakSelf = self ;
    
    REMenuItem* searchItem = [ [ REMenuItem alloc ] initWithTitle : @"Search"
                                                            image : [UIImage imageNamed:@"Icon_Home"]
                                                 highlightedImage : nil
                                                           action : ^( REMenuItem* item ) {
                                                               WHLSearchViewController* viewController = [ self.storyboard instantiateViewControllerWithIdentifier : @"WHLSearchViewController" ] ;
                                                               [ weakSelf setViewControllers : @[ viewController ] animated : NO ] ;
                                                           } ] ;
    
    REMenuItem* recentItem = [ [ REMenuItem alloc ] initWithTitle : @"Recent"
                                                            image : [UIImage imageNamed:@"Icon_Home"]
                                                 highlightedImage : nil
                                                           action : ^( REMenuItem* item ) {
                                                               WHLRecentViewController* viewController = [ self.storyboard instantiateViewControllerWithIdentifier : @"WHLRecentViewController" ] ;
                                                               [ weakSelf setViewControllers : @[ viewController ] animated : NO ] ;
                                                               
                                                           } ] ;
    
    REMenuItem* profileItem = [ [ REMenuItem alloc ] initWithTitle : @"Profile"
                                                             image : [UIImage imageNamed:@"Icon_Home"]
                                                  highlightedImage : nil
                                                            action : ^( REMenuItem* item ) {
                                                               /* if( [ PFUser currentUser ] == nil )
                                                                {
                                                                    WHLLoginViewController* viewController = [ self.storyboard instantiateViewControllerWithIdentifier : @"ProfileViewController" ] ;
                                                                    [ weakSelf setViewControllers : @[ viewController ] animated : NO ] ;
                                                                }
                                                                else
                                                                {*/
                                                                    WHLProfileViewController* viewController = [ self.storyboard instantiateViewControllerWithIdentifier : @"WHLProfileViewController" ] ;
                                                                    [ weakSelf setViewControllers : @[ viewController ] animated : NO ] ;
                                                                
                                                            } ] ;
    
    searchItem.tag = 0 ;
    recentItem.tag = 1 ;
    profileItem.tag = 2 ;
    
    self.menu = [ [ REMenu alloc ] initWithItems : @[ searchItem, recentItem, profileItem ] ] ;
    
    if( !REUIKitIsFlatMode() )
    {
        self.menu.cornerRadius = 4 ;
        self.menu.shadowRadius = 4 ;
        self.menu.shadowColor = [ UIColor blackColor ] ;
        self.menu.shadowOffset = CGSizeMake( 0, 1 ) ;
        self.menu.shadowOpacity = 1 ;
    }
    
    self.menu.imageOffset = CGSizeMake( 5, -1 ) ;
    self.menu.waitUntilAnimationIsComplete = NO ;
    self.menu.badgeLabelConfigurationBlock = ^( UILabel* badgeLabel, REMenuItem* item ) {
        badgeLabel.backgroundColor = [ UIColor colorWithRed : 0 green : 179 / 255.0 blue : 134 / 255.0 alpha : 1 ] ;
        badgeLabel.layer.borderColor = [ UIColor colorWithRed : 0.000 green : 0.648 blue : 0.507 alpha : 1.000 ].CGColor ;
    } ;
}

- ( void ) toggleMenu
{
    if( self.menu.isOpen )
    {
        [ self.menu close ] ;
    }
    else
    {
        [ self.menu showFromNavigationController : self ] ;
    }
}


@end
