//
//  WHLSearchViewController.m
//  WheelsUp
//
//  Created by Broc Pacholik  on 2014-01-09.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "WHLSearchViewController.h"
#import "PassangersViewController.h"
#import "WhereViewController.h"
#import "WHLNetworkManager.h"
#import "REMenu.h"
#import "City.h"
#import <Parse/Parse.h>
#import "SVProgressHUD.h"
#import "MZFormSheetController.h"

@interface WHLSearchViewController ()

@end

@implementation WHLSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [ self setTitle : @"Search" ] ;
    
    self.navigationItem.leftBarButtonItem = [ [ UIBarButtonItem alloc ] initWithTitle :@"Menu"
                                                                                style :UIBarButtonItemStyleBordered
                                                                               target :self.navigationController
                                                                               action :@selector( toggleMenu ) ] ;
    
    _fromTF.delegate = self;
    
    [WHLNetworkManager sharedInstance].locationManager.delegate = self;
    [[WHLNetworkManager sharedInstance].locationManager startUpdatingLocation];
        
    _maxPrice = 0;
    _adultsCount = 1;
    _childrenCount = 0;
 
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchProgressEvent:) name:SVProgressHUDDidReceiveTouchEventNotification object:nil];
}

- (void)touchProgressEvent:(id)sender
{
    [SVProgressHUD showErrorWithStatus:@"Canceled"];
}

- (IBAction)somewhereHotAction:(id)sender {
    
    [_fromTF resignFirstResponder];
    [_maxPriceTF resignFirstResponder];
    
    if (_fromCode.length == 0) {
        [self showDialogWithTitle:@"Oops!" andMessage:@"Make sure you fill out from and to fields!"];
        return ;
    }
    
    [SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeBlack];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"City" inManagedObjectContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *results = [[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    City *result = [results objectAtIndex: arc4random() % results.count];
    
    __weak typeof (self) wself = self;
    [[WHLNetworkManager sharedInstance].weatherObjectManager getObjectsAtPathForRouteNamed:@"weatherRoute" object:nil parameters:@{@"q" : result.name, @"format" : @"json", @"num_of_days" : @"3", @"key" : @"28czykhh9e3qe9vxsd8qcp94"} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        int sum = 0;
        for(Weather *w in mappingResult.array)
            sum += [w.tempMax integerValue];
        
        if(sum >0 && sum/mappingResult.array.count > 30)
        {
            _toCode = result.iata;
            
            __weak typeof (self) wself = self;
            
            NSString *adults = [NSString stringWithFormat:@"%d",_adultsCount];
            NSString *children = [NSString stringWithFormat:@"%d",_childrenCount];
            NSString *maxPrice = _maxPrice ? [NSString stringWithFormat:@"%ld",(long)_maxPrice] : nil;
            
            [[WHLNetworkManager sharedInstance] makeSearchRequestFrom:_fromCode to:_toCode adults:adults children:children success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                
                if(mappingResult.array.count > 0) {
                    wself.trip = [mappingResult.array firstObject];
                    
                    [[WHLNetworkManager sharedInstance] makeFlightRequestWithSearchId:wself.trip.searchId andTripId:[[wself.trip.trips firstObject] valueForKey:@"id"] stops:_numberOfStops maxrrice:maxPrice success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                        
                        if(mappingResult.array.count > 0)
                        {
                            [SVProgressHUD dismiss];
                            
                            wself.flights = mappingResult.array;
                            [wself performSegueWithIdentifier:@"resultsSegue" sender:nil];
                        }
                        else
                            [wself somewhereHotAction:nil];
                        
                    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                        [wself somewhereHotAction:nil];
                    } numberOfTimes:4];
                    
                }
                else
                    [wself anywhereAction:nil];
                
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                [wself somewhereHotAction:nil];
            }];
        }
        else
            [wself somewhereHotAction:nil];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"weather failure %@",error);
        
        [wself somewhereHotAction:nil];
        
    }];
}

- (IBAction)anywhereAction:(id)sender {
    
    [_fromTF resignFirstResponder];
    [_maxPriceTF resignFirstResponder];
    
    if (_fromCode.length == 0) {
        [self showDialogWithTitle:@"Oops!" andMessage:@"Make sure you fill out from and to fields!"];
        return ;
    }

    [SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeBlack];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"City" inManagedObjectContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filtered = true"];
    [fetchRequest setPredicate:predicate];
  
    NSError *error;
    NSArray *results = [[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    City *result = [results objectAtIndex: arc4random() % results.count];
    _toCode = result.iata;
    
    __weak typeof (self) wself = self;
    
    NSString *adults = [NSString stringWithFormat:@"%d",_adultsCount];
    NSString *children = [NSString stringWithFormat:@"%d",_childrenCount];
    NSString *maxPrice = _maxPrice ? [NSString stringWithFormat:@"%ld",(long)_maxPrice] : nil;
    
    [[WHLNetworkManager sharedInstance] makeSearchRequestFrom:_fromCode to:_toCode adults:adults children:children success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        if(mappingResult.array.count > 0) {
            wself.trip = [mappingResult.array firstObject];
            
            [[WHLNetworkManager sharedInstance] makeFlightRequestWithSearchId:wself.trip.searchId andTripId:[[wself.trip.trips firstObject] valueForKey:@"id"] stops:_numberOfStops maxrrice:maxPrice success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                
                if(mappingResult.array.count > 0)
                {
                    [SVProgressHUD dismiss];
                    
                    wself.flights = mappingResult.array;
                    [wself performSegueWithIdentifier:@"resultsSegue" sender:nil];
                }
                else
                    [wself anywhereAction:nil];
                
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                [wself anywhereAction:nil];
            } numberOfTimes:4];
            
        }
        else
            [wself anywhereAction:nil];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [wself anywhereAction:nil];
    }];

}

- (IBAction)gpsAction:(id)sender {
    [WHLNetworkManager sharedInstance].locationManager.delegate = self;
    [[WHLNetworkManager sharedInstance].locationManager startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated
{

}

- (void)highlightSearch
{
    // Initialize MDCFocusView and customize its background color
    _focusView = [MDCFocusView new];
    _focusView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
    
    // Register a MDCFocalPointView subclass to "wrap" focal points
    //_focusView.focalPointViewClass = [MDCFocalPointView class];
    _focusView.focalPointViewClass = [MDCSpotlightView class];
    
    // Add any number of custom views to MDCFocusView
    //[f_ocusView addSubview:buildLabel];
    
    // Present the focus view
    [_focusView focus:_fromTF, _searchButton, nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults boolForKey:@"firstUse"]) {
        [self highlightSearch];
        [defaults setBool:YES forKey:@"firstUse"];
        [defaults synchronize];
    }
}

- (IBAction)whereAction:(id)sender {
    WhereViewController *where = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"WhereViewController"];
    where.parent = self;
    if(_searchMode == place)
        where.placeName = _whereButton.titleLabel.text;
    
    [self presentOnSheet:where];
}

- (IBAction)passengersAction:(id)sender {
    PassangersViewController *passangers = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PassangersViewController"];
    passangers.parent = self;
    [self presentOnSheet:passangers];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[WHLNetworkManager sharedInstance].locationManager stopUpdatingLocation];
    [WHLNetworkManager sharedInstance].locationManager.delegate = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"resultsSegue"])
    {
        WHLSearchResultsViewController *controller = (WHLSearchResultsViewController *)segue.destinationViewController;
        controller.flights = _flights;
        controller.trip = _trip;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_fromTF resignFirstResponder];
    [_maxPriceTF resignFirstResponder];
    return NO;
}

- (IBAction)showHideFilters:(id)sender {
    float alpha;
    if(_isFiltersViewVisible)
        alpha = 0.0;
    else
        alpha = 1.0;
    
    [UIView animateWithDuration:0.3 animations:^{
        _filtersView.alpha = alpha;
    } completion:^(BOOL finished) {
        if(finished) {
            _isFiltersViewVisible = !_isFiltersViewVisible;
            if(_isFiltersViewVisible)
               [_showHideFiltersButton setTitle:@"-" forState:UIControlStateNormal];
            else {
                [_showHideFiltersButton setTitle:@"+" forState:UIControlStateNormal];
                _maxPrice = 0;
                _maxPriceTF.text = @"";
            }
        }
    }];
}

-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    const int movementDistance = -180; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    if(textField == _fromTF && textField.text.length > 0)
    {
        _fromCode = nil;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"City" inManagedObjectContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSString *city;
        if([_fromTF.text rangeOfString:@","].location != NSNotFound)
            city = [_fromTF.text substringToIndex:[_fromTF.text rangeOfString:@","].location];
        else
            city = _fromTF.text;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name ==[c] %@",[city stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *results = [[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:fetchRequest error:&error];

        
        if(results && results.count > 0) {
            if(results.count > 1) {
                _dropdownOptions = results;
                [self showPopUpWithTitle:@"Choose City" withOption:_dropdownOptions xy:CGPointMake(35, 125) isMultiple:NO];
            }
            else {
                City *city = (City *)[results firstObject];
                _fromCode = city.iata;
                _fromTF.text = [NSString stringWithFormat:@"%@, %@",city.name,city.country];
            }
        }
        else {
            [self showDialogWithTitle:@"Oops!" andMessage:@"Couldn't find any airport nearby"];
            _fromTF.text = @"";
        }
        
    }
    if(textField == _maxPriceTF)
    {
        _maxPrice = [_maxPriceTF.text integerValue];
        [self animateTextField:_maxPriceTF up:NO];
    }
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField == _maxPriceTF)
        [self animateTextField:_maxPriceTF up:YES];
}

- (void)findFlights
{
    [_fromTF resignFirstResponder];
    [_maxPriceTF resignFirstResponder];

    if (_fromCode.length == 0 || _toCode.length == 0)
        [self showDialogWithTitle:@"Oops!" andMessage:@"Make sure you fill out from and to fields!"];
    else
    {
        __weak typeof (self) wself = self;
        
        [SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeBlack];
        
        NSString *adults = [NSString stringWithFormat:@"%ld",_adultsCount];
        NSString *children = [NSString stringWithFormat:@"%ld",_childrenCount];
        NSString *maxPrice = _maxPrice ? [NSString stringWithFormat:@"%ld",(long)_maxPrice] : nil;
        
        [[WHLNetworkManager sharedInstance] makeSearchRequestFrom:_fromCode to:_toCode adults:adults children:children success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            
            if(mappingResult.array.count > 0) {
                wself.trip = [mappingResult.array firstObject];
                
                [[WHLNetworkManager sharedInstance] makeFlightRequestWithSearchId:wself.trip.searchId andTripId:[[wself.trip.trips firstObject] valueForKey:@"id"] stops:_numberOfStops maxrrice:maxPrice success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                    
                    [SVProgressHUD dismiss];
                    
                    if(mappingResult.array.count > 0)
                    {
                        wself.flights = mappingResult.array;
                        [wself performSegueWithIdentifier:@"resultsSegue" sender:nil];
                    }
                    else
                        [wself showDialogWithTitle:@"Oops!" andMessage:@"No flights found!"];
        
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    [wself showDialogWithTitle:@"Oops!" andMessage:@"Please try again"];
                    [SVProgressHUD dismiss];
                } numberOfTimes:8];
                
            }
            else
                [wself showDialogWithTitle:@"Oops!" andMessage:@"No route found!"];
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [wself showDialogWithTitle:@"Oops!" andMessage:@"Please try again"];
            [SVProgressHUD dismiss];
        }];
        
    }
    
}

- (void)presentOnSheet:(UIViewController *)controller
{
    [_fromTF resignFirstResponder];
    [_maxPriceTF resignFirstResponder];
    
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(280, 200) viewController:controller];
    sheet.shouldDismissOnBackgroundViewTap = YES;
    sheet.transitionStyle = MZFormSheetTransitionStyleFade;
    [[MZFormSheetController sharedBackgroundWindow] setBackgroundBlurEffect:YES];
    [[MZFormSheetController sharedBackgroundWindow] setBlurRadius:5.0];
     
    [self mz_presentFormSheetController:sheet animated:YES completionHandler:nil];
}

- (IBAction)searchAction:(id)sender {
    
    if(_focusView)
        [_focusView dismiss:nil];
    
    UIImage *searchButtonImage = [UIImage imageNamed:@"Button1.png"];
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setImage:searchButtonImage forState:UIControlStateNormal];
    
    switch (_searchMode) {
        case anywhere:
        {
            [self anywhereAction:nil];
            break;
        }
        case somewhereHot:
        {
            [self somewhereHotAction:nil];
            break;
        }
        case place:
        {
            [self findFlights];
            break;
        }
        
        default:
            break;
    }
}

#pragma locationFramework delegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManager didFailWithError %@",error);
    
    //[self showDialogWithTitle:@"Oops!" andMessage:@"Could not find your location."];
    
    [[WHLNetworkManager sharedInstance].locationManager stopUpdatingLocation];
    [WHLNetworkManager sharedInstance].locationManager.delegate = nil;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    if(locations)
    {
        [[WHLNetworkManager sharedInstance].locationManager stopUpdatingLocation];
        [WHLNetworkManager sharedInstance].locationManager.delegate = nil;
        
        NSLog(@"didUpdateLocations \n%@",locations);
        
        CLLocation *location = [locations firstObject];
        
        [[CLGeocoder new] reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error){
            CLPlacemark *placemark = placemarks[0];
            NSLog(@"Found %@", placemark.locality);
            
            _fromTF.text = placemark.locality;
            [self textFieldDidEndEditing:_fromTF];
        }];
        
    }
}

#pragma dropDown

-(void)showPopUpWithTitle:(NSString*)popupTitle withOption:(NSArray*)arrOptions xy:(CGPoint)point isMultiple:(BOOL)isMultiple{
    
    CGSize size;
    if (arrOptions.count <= 2)
        size = CGSizeMake(250, 140);
    else if (arrOptions.count == 3)
        size = CGSizeMake(250, 185);
    else
        size = CGSizeMake(250, 230);
    
    NSMutableArray *options = [NSMutableArray new];
    for(City *city in arrOptions)
        [options addObject:[NSString stringWithFormat:@"%@, %@",city.name,city.country]];
    
    [_Dropobj fadeOut];
    _Dropobj = [[DropDownListView alloc] initWithTitle:popupTitle options:options xy:point size:size isMultiple:isMultiple];
    _Dropobj.delegate = self;
    [_Dropobj showInView:self.view animated:YES];
    
    /*----------------Set DropDown backGroundColor-----------------*/
    [_Dropobj SetBackGroundDropDwon_R:0.0 G:108.0 B:194.0 alpha:0.70];
    
    [_fromTF resignFirstResponder];

}

- (void)DropDownListView:(DropDownListView *)dropdownListView didSelectedIndex:(NSInteger)anIndex {
    City *city = [_dropdownOptions objectAtIndex:anIndex];
    
    _fromCode = city.iata;
    _fromTF.text = city.name;
    [self textFieldDidEndEditing:_fromTF];
    
}

- (void)DropDownListViewDidCancel{
    
}

-(CGSize)GetHeightDyanamic:(UILabel*)lbl
{
    NSRange range = NSMakeRange(0, [lbl.text length]);
    CGSize constraint;
    constraint= CGSizeMake(287 ,MAXFLOAT);
    CGSize size;
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    float ver_float = [ver floatValue];
    if (ver_float>6.0) {
        NSDictionary *attributes = [lbl.attributedText attributesAtIndex:0 effectiveRange:&range];
        CGSize boundingBox = [lbl.text boundingRectWithSize:constraint options: NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
        
        size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    }
    else{
        size = [lbl.text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    }
    return size;
}

- (void)showDialogWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    
    [alertView show];
}


@end
