//
//  WHLSearchViewController.m
//  WheelsUp
//
//  Created by Broc Pacholik  on 2014-01-09.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "WHLSearchViewController.h"
#import "WHLNetworkManager.h"
#import "REMenu.h"
#import "City.h"
#import <Parse/Parse.h>
#import "SVProgressHUD.h"

@interface WHLSearchViewController ()

@end

@implementation WHLSearchViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [ self setTitle : @"Search" ] ;
    
     self.navigationItem.leftBarButtonItem = [ [ UIBarButtonItem alloc ] initWithTitle : @"Menu" style : UIBarButtonItemStyleBordered target : self.navigationController action : @selector( toggleMenu ) ] ;
    
    
    _fromTF.delegate = self;
    _toTF.delegate = self;
    
    [WHLNetworkManager sharedInstance].locationManager.delegate = self;
    [[WHLNetworkManager sharedInstance].locationManager startUpdatingLocation];
}

- (IBAction)gpsAction:(id)sender {
    [WHLNetworkManager sharedInstance].locationManager.delegate = self;
    [[WHLNetworkManager sharedInstance].locationManager startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    
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
    [_toTF resignFirstResponder];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [_Dropobj fadeOut];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    if(textField == _fromTF && textField.text.length > 0)
    {
        _fromCode = nil;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"City" inManagedObjectContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name ==[c] %@",[_fromTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *results = [[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:fetchRequest error:&error];

        
        if(results && results.count > 0) {
            City *city = (City *)[results firstObject];
            _fromCode = city.iata;
        }
        else
            [self showDialogWithTitle:@"Oops!" andMessage:@"Couldn't find any airport nearby"];
        
    }
    else if(textField == _toTF && textField.text.length > 0)
    {
        _toCode = nil;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"City" inManagedObjectContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name ==[c] %@",[_toTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *results = [[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        
        if(results && results.count > 0)
            _toCode = ((City *)[results firstObject]).iata;
        else
            [self showDialogWithTitle:@"Oops!" andMessage:@"Couldn't find any airport nearby"];
            
    }
    
}

- (void)findFlights
{
    [_fromTF resignFirstResponder];
    [_toTF resignFirstResponder];

    if (_fromCode.length == 0 || _toCode.length == 0)
        [self showDialogWithTitle:@"Oops!" andMessage:@"Make sure you fill out all the fields!"];
    else
    {
        __weak typeof (self) wself = self;
        
        [SVProgressHUD showWithStatus:@"Searching." maskType:SVProgressHUDMaskTypeBlack];
        [[WHLNetworkManager sharedInstance] makeSearchRequestFrom:_fromCode to:_toCode success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            
            if(mappingResult.array.count > 0) {
                wself.trip = [mappingResult.array firstObject];
                
                [[WHLNetworkManager sharedInstance] makeFlightRequestWithSearchId:wself.trip.searchId andTripId:[[wself.trip.trips firstObject] valueForKey:@"id"] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                    
                    [SVProgressHUD dismiss];
                    
                    if(mappingResult.array.count > 0)
                    {
                        wself.flights = mappingResult.array;
                        [wself performSegueWithIdentifier:@"resultsSegue" sender:nil];
                    }
                    else
                        [wself showDialogWithTitle:@"Oops!" andMessage:@"No flights found!"];
        
                } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                    [SVProgressHUD dismiss];
                } numberOfTimes:5];
                
            }
            else
                [wself showDialogWithTitle:@"Oops!" andMessage:@"No route found!"];
            
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [SVProgressHUD dismiss];
        }];
        
    }
    
}

- (IBAction)searchAction:(id)sender {
    [self findFlights];
}

#pragma locationFramework delegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManager didFailWithError %@",error);
    
    [self showDialogWithTitle:@"Oops!" andMessage:@"Could not find your location."];
    
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
    
    [_Dropobj fadeOut];
    _Dropobj = [[DropDownListView alloc] initWithTitle:popupTitle options:arrOptions xy:point size:size isMultiple:isMultiple];
    _Dropobj.delegate = self;
    [_Dropobj showInView:self.view animated:YES];
    
    /*----------------Set DropDown backGroundColor-----------------*/
    [_Dropobj SetBackGroundDropDwon_R:0.0 G:108.0 B:194.0 alpha:0.70];
    
    [_fromTF resignFirstResponder];
    [_toTF resignFirstResponder];
    
}

- (void)DropDownListView:(DropDownListView *)dropdownListView didSelectedIndex:(NSInteger)anIndex {
    
    
}

- (void)DropDownListView:(DropDownListView *)dropdownListView Datalist:(NSMutableArray*)ArryData{
    
    NSLog(@"didSelectedIndex ");
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
