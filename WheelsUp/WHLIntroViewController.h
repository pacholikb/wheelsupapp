//
//  WHLIntroViewController.h
//  WheelsUp
//
//  Created by Konrad Przyludzki on 28.03.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHLIntroViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *image1;
@property (strong, nonatomic) IBOutlet UIImageView *image2;
@property (strong, nonatomic) IBOutlet UIImageView *image3;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (assign) BOOL pageControlBeingUsed;
@property (strong, nonatomic) IBOutlet UIButton *skipButton;

@end
