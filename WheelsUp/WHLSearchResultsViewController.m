//
//  WHLSearchResultsViewController.m
//  WheelsUp
//
//  Created by Konrad Przyludzki on 18.02.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "WHLSearchResultsViewController.h"
#import "WHLFlightDetailsViewController.h"
#import "WHLNetworkManager.h"
#import "JMImageCache.h"

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
    [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    _dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZ";
    
    SearchModel *search = [SearchModel new];
    search.location = _arrivalCityName;
    
    __weak typeof (self) wself = self;
    [[WHLNetworkManager sharedInstance].weatherObjectManager getObjectsAtPathForRouteNamed:@"weatherRoute" object:nil parameters:@{@"q" : _arrivalCityName, @"format" : @"json", @"num_of_days" : @"3", @"key" : @"28czykhh9e3qe9vxsd8qcp94"} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        wself.weatherArray = mappingResult.array;
        [wself.tableView reloadData];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"weather failure %@",error);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"Couldn't get weather info"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        
        [alertView show];

    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"detailSegue"])
    {
        WHLFlightDetailsViewController *controller = segue.destinationViewController;
        controller.flight = _selectedFlight;
    }
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
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
    UILabel *cityLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *countryLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *priceLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:4];
    UILabel *stopsLabel = (UILabel *)[cell viewWithTag:5];
        
    NSDate *departureDate = [_dateFormatter dateFromString:[[flight.outbounds firstObject] valueForKey:@"departure_time"]];
    NSDate *arrivalDate = [_dateFormatter dateFromString:[[flight.outbounds lastObject] valueForKey:@"arrival_time"]];
    NSDateComponents *componentsDeparture = [[NSCalendar currentCalendar] components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:departureDate];
    NSDateComponents *componentsArrival = [[NSCalendar currentCalendar] components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:arrivalDate];
    
    cityLabel.text = _arrivalCityName;
    countryLabel.text = [[flight.outbounds firstObject] valueForKey:@"airline_name"];
    priceLabel.text = [NSString stringWithFormat:@"$%.2f",[flight.price floatValue]];
    timeLabel.text = [NSString stringWithFormat:@"%02d:%02d - %02d:%02d",componentsDeparture.hour,componentsDeparture.minute,componentsArrival.hour,componentsArrival.minute];
    stopsLabel.text = ((NSArray *)flight.outbounds).count > 1 ? [NSString stringWithFormat:@"stops: %d",((NSArray *)flight.outbounds).count - 1] : @"direct";
    
    
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
    return 65.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(!_weatherArray || _weatherArray.count < 3)
        return 44;
    else
        return 170;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view;
    
    if(!_weatherArray || _weatherArray.count < 3)
        view = [[[NSBundle mainBundle] loadNibNamed:@"ResultsHeaderView" owner:nil options:nil] objectAtIndex:1];
    else
        view = [[[NSBundle mainBundle] loadNibNamed:@"ResultsHeaderView" owner:nil options:nil] objectAtIndex:0];
    
    UILabel *fromLabel = (UILabel *) [view viewWithTag:1];
    fromLabel.text = [NSString stringWithFormat:@"%@ - %@",_departureCityName,_arrivalCityName];
    
    UIButton *sortByPriceButton = (UIButton *)[view viewWithTag:2];
    UIButton *sortByDateButton = (UIButton *)[view viewWithTag:3];
    
    [sortByPriceButton addTarget:self action:@selector(sortByPrice:) forControlEvents:UIControlEventTouchUpInside];
    [sortByDateButton addTarget:self action:@selector(sortByDate:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *weatherLabel = (UILabel *)[view viewWithTag:4];
    weatherLabel.text = [NSString stringWithFormat:@"Weather in %@:",_arrivalCityName];

    for(int i = 0; i<3; i++)
    {
        UILabel *label1 = (UILabel *)[view viewWithTag:11+i];
        UILabel *label2 = (UILabel *)[view viewWithTag:21+i];
        UILabel *label3 = (UILabel *)[view viewWithTag:41+i];
        UIImageView *imageView = (UIImageView *)[view viewWithTag:31+i];
        
        Weather *weather = [_weatherArray objectAtIndex:i];
        NSDictionary *dictionary = [weather.conditions firstObject];
        
        if(weather && dictionary)
        {
            label1.text = weather.date;
            label2.text = [dictionary valueForKey:@"value"];//validation needed
            label3.text = [NSString stringWithFormat:@"%@C to %@C", weather.tempMin,weather.tempMax];
            [imageView setImageWithURL:[NSURL URLWithString:[[weather.iconUrls firstObject] valueForKey:@"value"]] placeholder:nil];
        }
    }
    
    return view;
}

- (void)sortByPrice:(id)sender
{
    NSArray *sortedArray;
    sortedArray = [_flights sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSNumber *first = [(Flight*)a price];
        NSNumber *second = [(Flight*)b price];
        return [first compare:second];
    }];
    
    _flights = sortedArray;
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)sortByDate:(id)sender
{
    NSArray *sortedArray;
    sortedArray = [_flights sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [_dateFormatter dateFromString: [[[(Flight*)a outbounds] firstObject] valueForKey:@"departure_time"]];
        NSDate *second = [_dateFormatter dateFromString: [[[(Flight*)b outbounds] firstObject] valueForKey:@"departure_time"]];
        return [first compare:second];
    }];
    
    _flights = sortedArray;
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedFlight = [_flights objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"detailSegue" sender:nil];
    
//    if(_weatherArray && _weatherArray.count > 0)
//    {
//        [self.tableView beginUpdates];
//        [self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationFade];
//        [self.tableView endUpdates];
//    }
//    else
//    {
//        SearchModel *search = [SearchModel new];
//        search.location = _arrivalCityName;
//        
//        __weak typeof (self) wself = self;
//        [[WHLNetworkManager sharedInstance].weatherObjectManager getObjectsAtPathForRouteNamed:@"weatherRoute" object:nil parameters:@{@"q" : _arrivalCityName, @"format" : @"json", @"num_of_days" : @"3", @"key" : @"28czykhh9e3qe9vxsd8qcp94"} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//        
//            wself.weatherArray = mappingResult.array;
//            NSLog(@"weather success %@",_weatherArray);
//        
//            if(wself.weatherArray.count > 0)
//            {
//                [wself.tableView beginUpdates];
//                [wself.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//                [wself.tableView endUpdates];
//            }
//            else
//                wself.selectedFlight = nil;
//        
//        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//            NSLog(@"weather failure %@",error);
//        
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
//                                                            message:@"Couldn't get weather info"
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"Ok"
//                                                  otherButtonTitles:nil];
//        
//            [alertView show];
//            wself.selectedFlight = nil;
//        }];
//    }
}

@end
