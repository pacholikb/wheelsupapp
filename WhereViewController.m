//
//  WhereViewController.m
//  WheelsUp
//
//  Created by Konrad Przyludzki on 19.03.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "WhereViewController.h"

@interface WhereViewController ()

@end

@implementation WhereViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _toTF.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_toTF resignFirstResponder];
    
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField == _toTF && textField.text.length > 0)
    {
        _parent.toCode = nil;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"City" inManagedObjectContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSString *city;
        if([_toTF.text rangeOfString:@","].location != NSNotFound)
            city = [_toTF.text substringToIndex:[_toTF.text rangeOfString:@","].location];
        else
            city = _toTF.text;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name ==[c] %@",[city stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *results = [[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        
        if(results && results.count > 0)
        {
            if(results.count > 1) {
                _dropdownOptions = results;
                [self showPopUpWithTitle:@"Choose City" withOption:_dropdownOptions xy:CGPointMake(25, 139) isMultiple:NO];
            }
            else {
                City *city = (City *)[results firstObject];
                _parent.toCode = city.iata;
                _toTF.text = [NSString stringWithFormat:@"%@, %@",city.name,city.country];
                _parent.searchMode = place;
                [_parent.whereButton setTitle:_toTF.text forState:UIControlStateNormal];
            }
        }
        else
            [self showDialogWithTitle:@"Oops!" andMessage:@"Couldn't find any airport nearby"];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)anywhereAction:(id)sender {
    _parent.searchMode = anywhere;
    [_parent.whereButton setTitle:@"Anywhere" forState:UIControlStateNormal];
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

- (IBAction)somewhereHotAction:(id)sender {
    _parent.searchMode = somewhereHot;
    [_parent.whereButton setTitle:@"Somewhere hot" forState:UIControlStateNormal];
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

- (IBAction)doneAction:(id)sender {
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
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

#pragma dropDown

-(void)showPopUpWithTitle:(NSString*)popupTitle withOption:(NSArray*)arrOptions xy:(CGPoint)point isMultiple:(BOOL)isMultiple{
    
    CGSize size;
    if (arrOptions.count <= 2)
        size = CGSizeMake(232, 140);
    else if (arrOptions.count == 3)
        size = CGSizeMake(232, 185);
    else
        size = CGSizeMake(232, 230);
    
    NSMutableArray *options = [NSMutableArray new];
    for(City *city in arrOptions)
        [options addObject:[NSString stringWithFormat:@"%@, %@",city.name,city.country]];
    
    [_Dropobj fadeOut];
    _Dropobj = [[DropDownListView alloc] initWithTitle:popupTitle options:options xy:point size:size isMultiple:isMultiple];
    _Dropobj.delegate = self;
    [_Dropobj showInView:self.view animated:YES];
    
    /*----------------Set DropDown backGroundColor-----------------*/
    [_Dropobj SetBackGroundDropDwon_R:0.0 G:108.0 B:194.0 alpha:0.70];
    
    [_toTF resignFirstResponder];
    
}

- (void)DropDownListView:(DropDownListView *)dropdownListView didSelectedIndex:(NSInteger)anIndex {
    City *city = [_dropdownOptions objectAtIndex:anIndex];
    
    _parent.toCode = city.iata;
    _toTF.text = [NSString stringWithFormat:@"%@, %@",city.name,city.country];
    _parent.searchMode = place;
    [_parent.whereButton setTitle:_toTF.text forState:UIControlStateNormal];
    
}

- (void)DropDownListViewDidCancel{
    
}

@end
