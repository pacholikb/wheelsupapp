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
    
    [[WHLNetworkManager sharedInstance] setBackgroundGradient:self.view];
    
    [_scrollView setContentSize:CGSizeMake(960, 140)];
 
    _departureCityName = [[_trip.trips firstObject] objectForKey:@"departure_name"];
    _arrivalCityName = [[_trip.trips firstObject] objectForKey:@"arrival_name"];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    _dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZ";
    
    SearchModel *search = [SearchModel new];
    search.location = _arrivalCityName;
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ - %@", [[_trip.trips firstObject] objectForKey:@"departure_code"], [[_trip.trips firstObject] objectForKey:@"arrival_code"]];
//    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithRed:194/255.0f green:209/255.0f blue:202/255.0f alpha:1.0f]};

        
    __weak typeof (self) wself = self;
    [[WHLNetworkManager sharedInstance].weatherObjectManager getObjectsAtPathForRouteNamed:@"weatherRoute" object:nil parameters:@{@"q" : _arrivalCityName, @"format" : @"json", @"num_of_days" : @"3", @"key" : @"28czykhh9e3qe9vxsd8qcp94"} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        
        wself.weatherArray = mappingResult.array;
        if(wself.weatherArray.count >= 3) {
          
            wself.noWeatherLabel.hidden = YES;
            
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
        
    }];
    
    NSString *localFormat = [NSDateFormatter dateFormatFromTemplate:@"MMM dd hh:mm a" options:0 locale:[NSLocale currentLocale]];
    _dateFormatterOutput = [[NSDateFormatter alloc] init];
    _dateFormatterOutput.dateFormat = localFormat;

    NSString *location = [NSString stringWithFormat:@"%@, %@",[[_trip.trips firstObject] objectForKey:@"arrival_name"],[[_trip.trips firstObject] objectForKey:@"arrival_country_name"]];
    [[WHLNetworkManager sharedInstance].eventsObjectManager getObjectsAtPathForRouteNamed:@"eventRoute" object:nil parameters:@{@"app_key" : @"TS2pw8MnQv7kNhKP", @"location" : location, @"date" : @"This Week", @"page_size" : @"3", @"image_sizes" : @"medium" } success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        wself.eventsArray = mappingResult.array;
        
        wself.noEventsLabel.hidden = YES;
        wself.eventsTableView.hidden = NO;
        
        [wself.eventsTableView reloadData];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        ;
    }];

    _mapView.userInteractionEnabled = YES;

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
            wself.mapView.userInteractionEnabled = YES;
            
        }];
    }];
    
    _mapView.zoomEnabled = NO;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openMap:)];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    [_mapView addGestureRecognizer:tapGestureRecognizer];
    
}

- (void)openMap:(id) sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com?q=%@",_arrivalCityName]]];
}

- (void)viewDidLayoutSubviews
{
    [_scrollView setContentSize:CGSizeMake(960, 140)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{    
    // Update the page when more than 50% of the previous/next page is visible
    if(!_pageControlBeingUsed && scrollView == _scrollView) {
        CGFloat pageWidth = self.scrollView.frame.size.width;
        int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.pageControl.currentPage = page;
        
        if(page == 2)
            [_eventsTableView reloadData];
    }
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
    if(tableView == _tableView) {
        Flight *flight = [_flights objectAtIndex:indexPath.row];
    
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        UILabel *cityLabel = (UILabel *)[cell viewWithTag:1];
        UILabel *countryLabel = (UILabel *)[cell viewWithTag:2];
        UILabel *priceLabel = (UILabel *)[cell viewWithTag:3];
        UILabel *timeLabel = (UILabel *)[cell viewWithTag:4];
        UILabel *stopsLabel = (UILabel *)[cell viewWithTag:5];
        
        NSDate *departureDate = [_dateFormatter dateFromString:[[flight.outbounds firstObject] valueForKey:@"departure_time"]];
        NSDate *arrivalDate = [_dateFormatter dateFromString:[[flight.outbounds lastObject] valueForKey:@"arrival_time"]];
    
        cityLabel.text = _arrivalCityName;
        countryLabel.text = [[flight.outbounds firstObject] valueForKey:@"airline_name"];
        priceLabel.text = [NSString stringWithFormat:@"$%.2f",[flight.price floatValue]];
        timeLabel.text = [NSString stringWithFormat:@"%@ - %@",[_dateFormatterOutput stringFromDate:departureDate],[_dateFormatterOutput stringFromDate:arrivalDate]];
        stopsLabel.text = ((NSArray *)flight.outbounds).count > 1 ? [NSString stringWithFormat:@"stops: %d",((NSArray *)flight.outbounds).count - 1] : @"direct";
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"eventCell" forIndexPath:indexPath];
        
        Event *event = [_eventsArray objectAtIndex:indexPath.row];
        
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
        UILabel *dateLabel = (UILabel *)[cell viewWithTag:2];
        UILabel *placeLabel = (UILabel *)[cell viewWithTag:3];
        UIButton *btn = (UIButton *)[cell viewWithTag:4];
        UIImageView *img = (UIImageView *)[cell viewWithTag:5];
        
        if(event.imageUrl.length == 0)
            nameLabel.frame = CGRectMake(10, 5, 300, 36);
        else
            nameLabel.frame = CGRectMake(10, 5, 218, 36);
        
        NSLog(@"frame %f",nameLabel.frame.size.width);
        
        [img setImageWithURL:[NSURL URLWithString:event.imageUrl] placeholder:nil];
        nameLabel.text = event.title;
        dateLabel.text = [_dateFormatterOutput stringFromDate:event.startTime];
        placeLabel.text = event.venueName;
        
        [btn addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == _tableView) {
    if(_flights)
        return _flights.count;
    else
        return 0;
    }
    else {
        if(_eventsArray)
            return _eventsArray.count;
        else
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _tableView)
        return 65.0;
    else
        return 120;
}

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if(overlay == self.routeLine)
    {
        if(nil == self.routeLineView)
        {
            self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
            self.routeLineView.fillColor = [UIColor blueColor];
            self.routeLineView.strokeColor = [UIColor blueColor];
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
    
    [self sortAction:nil];
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
    
    [self sortAction:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _tableView) {
        _selectedFlight = [_flights objectAtIndex:indexPath.row];
        
        [self performSegueWithIdentifier:@"detailSegue" sender:nil];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tableView == _eventsTableView)
        return @"Events";
    else
        return nil;
}

- (void)moreAction:(UIButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:self.eventsTableView];
    NSIndexPath *clickedButtonPath = [self.eventsTableView indexPathForRowAtPoint:buttonPosition];
    
    Event *event = [_eventsArray objectAtIndex:clickedButtonPath.row];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:event.url]];
}

- (IBAction)sortAction:(id)sender {
    if(_dropDownView.alpha == 0.0)
        [UIView animateWithDuration:0.2 animations:^{
            _dropDownView.alpha = 0.8;
        }];
    else
        [UIView animateWithDuration:0.2 animations:^{
            _dropDownView.alpha = 0.0;
        }];
}

- (IBAction)changePage {
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
    _pageControlBeingUsed = YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _pageControlBeingUsed = NO;
}

@end
