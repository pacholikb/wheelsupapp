//
//  WHLMenuViewController.m
//  WheelsUp
//
//  Created by Broc Pacholik  on 2014-01-09.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "WHLMenuViewController.h"

@interface WHLMenuViewController ()

@property (readwrite, strong, nonatomic) REMenu* menu;

@end

@implementation WHLMenuViewController

- ( void ) viewDidLoad
{
    [ super viewDidLoad ] ;

    
    self.navigationBar.tintColor = [ UIColor whiteColor ] ;
    
    __typeof ( self ) __weak weakSelf = self ;
    
    _searchItem = [ [ REMenuItem alloc ] initWithTitle : @"Search"
                                                            image : [UIImage imageNamed:@"Icon_Home"]
                                                 highlightedImage : nil
                                                           action : ^( REMenuItem* item ) {
                                                               
                                                               WHLSearchViewController* viewController = [ self.storyboard instantiateViewControllerWithIdentifier : @"WHLSearchViewController" ] ;
                                                               [ weakSelf setViewControllers : @[ viewController ] animated : NO ] ;
                                                               
                                                           } ] ;
    
    _recentItem = [ [ REMenuItem alloc ] initWithTitle : @"Recent"
                                                            image : [UIImage imageNamed:@"Icon_Home"]
                                                 highlightedImage : nil
                                                           action : ^( REMenuItem* item ) {
                                                               
                                                               WHLRecentViewController* viewController = [ self.storyboard instantiateViewControllerWithIdentifier : @"WHLRecentViewController" ] ;
                                                               [ weakSelf setViewControllers : @[ viewController ] animated : NO ] ;
                                                               
                                                           } ] ;
    
    _profileItem = [ [ REMenuItem alloc ] initWithTitle : @"Profile"
                                                             image : [UIImage imageNamed:@"Icon_Home"]
                                                  highlightedImage : nil
                                                            action : ^( REMenuItem* item ) {
                                                            
                                                                    WHLLoginViewController* viewController = [ self.storyboard instantiateViewControllerWithIdentifier : @"WHLLoginViewController" ];
                                                                    [ weakSelf setViewControllers : @[ viewController ] animated : NO ] ;
                                                              
                                                            } ] ;
    
    _discoveryItem = [ [ REMenuItem alloc ] initWithTitle : @"Discovery"
                                                             image : [UIImage imageNamed:@"Icon_Home"]
                                                  highlightedImage : nil
                                                            action : ^( REMenuItem* item ) {
                                                                
                                                                DiscoveryViewController* viewController = [ self.storyboard instantiateViewControllerWithIdentifier : @"DiscoveryViewController" ];
                                                                [ weakSelf setViewControllers : @[ viewController ] animated : NO ] ;
                                                                
                                                            } ] ;
    
    _searchItem.tag = 0 ;
    _recentItem.tag = 1 ;
    _profileItem.tag = 2 ;
    _discoveryItem.tag = 3;
    
    self.menu = [ [ REMenu alloc ] initWithItems : @[ _searchItem, _recentItem, _profileItem, _discoveryItem ] ] ;
    
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
