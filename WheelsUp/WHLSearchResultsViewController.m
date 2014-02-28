//
//  WHLSearchResultsViewController.m
//  WheelsUp
//
//  Created by Konrad Przyludzki on 18.02.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "WHLSearchResultsViewController.h"
#import "WHLNetworkManager.h"

@interface WHLSearchResultsViewController ()

@end

@implementation WHLSearchResultsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _departureCityName = [[_trip.trips firstObject] objectForKey:@"departure_name"];
    _arrivalCityName = [[_trip.trips firstObject] objectForKey:@"arrival_name"];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZ";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    Flight *flight = [_flights objectAtIndex:indexPath.row];
    
    if(_selectedFlight == flight)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell" forIndexPath:indexPath];
        
        UILabel *cityLabel = (UILabel *)[cell viewWithTag:1];
//        UILabel *firstDayLabel = (UILabel *)[cell viewWithTag:11];
//        UILabel *secondDayLabel = (UILabel *)[cell viewWithTag:12];
//        UILabel *thirdDayLabel = (UILabel *)[cell viewWithTag:13];
//        UILabel *firstConditionsLabel = (UILabel *)[cell viewWithTag:21];
//        UILabel *secondConditionsLabel = (UILabel *)[cell viewWithTag:22];
//        UILabel *thirdConditionsLabel = (UILabel *)[cell viewWithTag:23];

            for(int i = 0; i<3; i++)
            {
                UILabel *label1 = (UILabel *)[cell viewWithTag:11+i];
                UILabel *label2 = (UILabel *)[cell viewWithTag:21+i];
                
                Weather *weather = [_weatherArray objectAtIndex:i];
                if(weather)
                {
                    label1.text = weather.date;
                    label2.text = [[weather.conditions firstObject] valueForKey:@"value"];//validation needed
                }
            }
        

    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
        UILabel *cityLabel = (UILabel *)[cell viewWithTag:1];
        UILabel *countryLabel = (UILabel *)[cell viewWithTag:2];
        UILabel *priceLabel = (UILabel *)[cell viewWithTag:3];
        UILabel *timeLabel = (UILabel *)[cell viewWithTag:4];
        
        NSDate *departureDate = [_dateFormatter dateFromString:[[flight.outbounds lastObject] valueForKey:@"departure_time"]];
        NSDate *arrivalDate = [_dateFormatter dateFromString:[[flight.outbounds lastObject] valueForKey:@"arrival_time"]];
        NSDateComponents *componentsDeparture = [[NSCalendar currentCalendar] components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:departureDate];
        NSDateComponents *componentsArrival = [[NSCalendar currentCalendar] components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:arrivalDate];
    
        countryLabel.text = [[flight.outbounds firstObject] valueForKey:@"departure_name"];
        cityLabel.text = [[flight.outbounds lastObject] valueForKey:@"arrival_name"];
        priceLabel.text = [NSString stringWithFormat:@"$%.2f",[flight.price floatValue]];
        timeLabel.text = [NSString stringWithFormat:@"%2d:%2d - %2d:%2d",componentsDeparture.hour,componentsDeparture.minute,componentsArrival.hour,componentsArrival.minute];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_flights)
        return _flights.count;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Flight *flight = [_flights objectAtIndex:indexPath.row];
    
    if(_selectedFlight == flight)
        return 150.0;
    else
        return 65.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 80;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"ResultsHeaderView" owner:nil options:nil] objectAtIndex:0];
    
    UILabel *fromLabel = (UILabel *) [view viewWithTag:1];
    fromLabel.text = _departureCityName;
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedFlight = [_flights objectAtIndex:indexPath.row];
    
    if(_weatherArray && _weatherArray.count > 0)
    {
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    else
    {
        SearchModel *search = [SearchModel new];
        search.location = _arrivalCityName;
        
        __weak typeof (self) wself = self;
        [[WHLNetworkManager sharedInstance].weatherObjectManager getObjectsAtPathForRouteNamed:@"weatherRoute" object:nil parameters:@{@"q" : _arrivalCityName, @"format" : @"json", @"num_of_days" : @"3", @"key" : @"28czykhh9e3qe9vxsd8qcp94"} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
            wself.weatherArray = mappingResult.array;
            NSLog(@"weather success %@",_weatherArray);
        
            if(wself.weatherArray.count > 0)
            {
                [wself.tableView beginUpdates];
                [wself.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [wself.tableView endUpdates];
            }
            else
                wself.selectedFlight = nil;
        
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSLog(@"weather failure %@",error);
        
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"Couldn't get weather info"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        
            [alertView show];
            wself.selectedFlight = nil;
        }];
    }
}

@end
