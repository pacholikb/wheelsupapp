//
//  WHLFBProfileViewController.h
//  WheelsUp
//
//  Created by Broc Pacholik  on 2014-01-12.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WHLFBProfileViewController : UIViewController <NSURLConnectionDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UILabel *headerNameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *headerImageView;
@property (strong, nonatomic) IBOutlet UILabel *headeruserLocation;



// UITableView row data properties
@property (nonatomic, strong) NSArray *rowTitleArray;
@property (nonatomic, strong) NSMutableArray *rowDataArray;
@property (nonatomic, strong) NSMutableData *imageData;

- (void)logoutButtonTouchHandler:(id)sender;


@end
