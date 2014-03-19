//
//  PageContentViewController.h
//  WheelsUp
//
//  Created by Konrad Przyludzki on 18.03.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContentViewController : UIViewController

@property (nonatomic, assign) NSInteger pageIndex;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end
