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

CLLocationCoordinate2D coordinateArray[2];

@implementation WHLSearchResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _departureCityName = [[_trip.trips firstObject] objectForKey:@"departure_name"];
    _arrivalCityName = [[_trip.trips firstObject] objectForKey:@"arrival_name"];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    _dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZ";
    
    SearchModel *search = [SearchModel new];
    search.location = _arrivalCityName;
    
    _directionLabel.text = [NSString stringWithFormat:@"%@ - %@", [[_trip.trips firstObject] objectForKey:@"departure_code"], [[_trip.trips firstObject] objectForKey:@"arrival_code"]];
    
    __weak typeof (self) wself = self;
    [[WHLNetworkManager sharedInstance].weatherObjectManager getObjectsAtPathForRouteNamed:@"weatherRoute" object:nil parameters:@{@"q" : _arrivalCityName, @"format" : @"json", @"num_of_days" : @"3", @"key" : @"28czykhh9e3qe9vxsd8qcp94"} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        wself.weatherArray = mappingResult.array;
        if(wself.weatherArray.count >= 3) {
          
            [wself.scrollView setContentSize:CGSizeMake(640, 140)];
            
            wself.weatherLabelHeader.text = [NSString stringWithFormat:@"Weather in %@:",wself.arrivalCityName];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE"];
            
            Weather *weatherFirst = [wself.weatherArray objectAtIndex:0];
            NSDictionary *dictionaryFirst = [weatherFirst.conditions firstObject];
            
            if(weatherFirst && dictionaryFirst)
            {
                NSString *dayName = [dateFormatter stringFromDate:weatherFirst.date];
                wself.dayLabelFirst.text = dayName;
                wself.conditionsLabelFirst.text = [dictionaryFirst valueForKey:@"value"];//validation needed
                wself.tempLabelFirst.text = [NSString stringWithFormat:@"high of %@C", weatherFirst.tempMax];
                [wself.weatherIconFirst setImageWithURL:[NSURL URLWithString:[[weatherFirst.iconUrls firstObject] valueForKey:@"value"]] placeholder:nil];
            }
            
            Weather *weatherSecond = [wself.weatherArray objectAtIndex:1];
            NSDictionary *dictionarySecond = [weatherSecond.conditions firstObject];
            
            if(weatherSecond && dictionarySecond)
            {
                NSString *dayName = [dateFormatter stringFromDate:weatherSecond.date];
                wself.dayLabelSecond.text = dayName;
                wself.conditionsLabelSecond.text = [dictionarySecond valueForKey:@"value"];//validation needed
                wself.tempLabelSecond.text = [NSString stringWithFormat:@"high of %@C", weatherSecond.tempMax];
                [wself.weatherIconSecond setImageWithURL:[NSURL URLWithString:[[weatherSecond.iconUrls firstObject] valueForKey:@"value"]] placeholder:nil];
            }
            
            Weather *weatherThird = [wself.weatherArray objectAtIndex:2];
            NSDictionary *dictionaryThird = [weatherThird.conditions firstObject];
            
            if(weatherThird && dictionaryThird)
            {
                NSString *dayName = [dateFormatter stringFromDate:weatherThird.date];
                wself.dayLabelThird.text = dayName;
                wself.conditionsLabelThird.text = [dictionaryThird valueForKey:@"value"];//validation needed
                wself.tempLabelThird.text = [NSString stringWithFormat:@"high of %@C", weatherThird.tempMax];
                [wself.weatherIconThird setImageWithURL:[NSURL URLWithString:[[weatherThird.iconUrls firstObject] valueForKey:@"value"]] placeholder:nil];
            }
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"weather failure %@",error);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"Couldn't get weather info"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        
        [alertView show];

    }];

    _mapView.userInteractionEnabled = NO;

    [[CLGeocoder new] geocodeAddressString:_departureCityName completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *p = [placemarks firstObject];
        coordinateArray[0] = p.location.coordinate;
        
        [[CLGeocoder new] geocodeAddressString:_arrivalCityName completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *p = [placemarks firstObject];
            coordinateArray[1] = p.location.coordinate;
            
            wself.routeLine = [MKPolyline polylineWithCoordinates:coordinateArray count:2];
            MKMapRect rect = [wself.routeLine boundingMapRect];
            [wself.mapView setVisibleMapRect:rect edgePadding:UIEdgeInsetsMake(10, 10, 10, 10) animated:NO];
            [wself.mapView addOverlay:wself.routeLine];
//            wself.mapView.userInteractionEnabled = YES;
            
        }];
    }];
    
}

- (void)viewDidLayoutSubviews
{
    if(_weatherArray.count >= 3)
        [_scrollView setContentSize:CGSizeMake(640, 140)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == _scrollView)
        NSLog(@"1 %f",_scrollView.contentSize.width);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"detailSegue"])
    {
        WHLFlightDetailsViewController *controller = segue.destinationViewController;
        controller.flight = _selectedFlight;
        controller.location = [NSString stringWithFormat:@"%@, %@",[[_trip.trips firstObject] objectForKey:@"arrival_name"],[[_trip.trips firstObject] objectForKey:@"arrival_country_name"]];
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

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if(overlay == self.routeLine)
    {
        if(nil == self.routeLineView)
        {
            self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
            self.routeLineView.fillColor = [UIColor orangeColor];
            self.routeLineView.strokeColor = [UIColor orangeColor];
            self.routeLineView.lineWidth = 5;
            
        }
        
        return self.routeLineView;
    }
    
    return nil;
}

- (IBAction)sortByPrice:(id)sender
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

- (IBAction)sortByDate:(id)sender
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
    
}

@end
