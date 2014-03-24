//
//  WHLFlightDetailsViewController.m
//  WheelsUp
//
//  Created by Konrad Przyludzki on 04.03.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "WHLFlightDetailsViewController.h"
#import "JMImageCache.h"
#import "WHLNetworkManager.h"
#import "Event.h"

@interface WHLFlightDetailsViewController ()

@end

@implementation WHLFlightDetailsViewController

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

    _outbounds = _flight.outbounds;
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    _dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZ";
    [_dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSString *localFormat = [NSDateFormatter dateFormatFromTemplate:@"MMM dd hh:mm a" options:0 locale:[NSLocale currentLocale]];
    _dateFormatterOutput = [[NSDateFormatter alloc] init];
    _dateFormatterOutput.dateFormat = localFormat;
    
    __weak typeof(self) wself = self;
    [[WHLNetworkManager sharedInstance].eventsObjectManager getObjectsAtPathForRouteNamed:@"eventRoute" object:nil parameters:@{@"app_key" : @"TS2pw8MnQv7kNhKP", @"location" : _location, @"date" : @"This Week", @"page_size" : @"3", @"image_sizes" : @"medium" } success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        wself.eventsArray = mappingResult.array;
        
        [wself.tableView reloadData];

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        ;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_eventsArray.count > 0)
        return 3;
    else
        return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 1)
        return 1;
    else if(section == 2)
        return _eventsArray.count;
    else
        return _outbounds.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        return 140;
    else if (indexPath.section == 2)
        return 100;
    else
        return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"outboundCell";
    UITableViewCell *cell;
    
    if(indexPath.section == 1)
    {
        CellIdentifier = @"bookCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        UILabel *priceLabel = (UILabel *)[cell viewWithTag:1];
        UIButton *bookNowButton = (UIButton *)[cell viewWithTag:2];
        
        priceLabel.text = [NSString stringWithFormat:@"$%.2f",[_flight.price floatValue]];
        [bookNowButton addTarget:self action:@selector(bookNow:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if(indexPath.section == 2)
    {
        CellIdentifier = @"eventCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        Event *event = [_eventsArray objectAtIndex:indexPath.row];
        
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
        UILabel *dateLabel = (UILabel *)[cell viewWithTag:2];
        UILabel *placeLabel = (UILabel *)[cell viewWithTag:3];
        UIButton *btn = (UIButton *)[cell viewWithTag:4];
        UIImageView *img = (UIImageView *)[cell viewWithTag:5];
        
        [img setImageWithURL:[NSURL URLWithString:event.imageUrl] placeholder:nil];
        nameLabel.text = event.title;
        dateLabel.text = [_dateFormatterOutput stringFromDate:event.startTime];
        placeLabel.text = event.venueName;
        
        [btn addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        UILabel *fromCodeLabel = (UILabel *)[cell viewWithTag:1];
        UILabel *fromNameLabel = (UILabel *)[cell viewWithTag:2];
        UILabel *fromTimeLabel = (UILabel *)[cell viewWithTag:3];
        
        UILabel *toCodeLabel = (UILabel *)[cell viewWithTag:11];
        UILabel *toNameLabel = (UILabel *)[cell viewWithTag:12];
        UILabel *toTimeLabel = (UILabel *)[cell viewWithTag:13];
        
        UIImageView *airlineLogoImageView = (UIImageView *)[cell viewWithTag:10];
        
        
        NSDictionary *outbound = [_outbounds objectAtIndex:indexPath.row];
        
        NSDate *departureDate = [_dateFormatter dateFromString:[outbound valueForKey:@"departure_time"]];
        NSDate *arrivalDate = [_dateFormatter dateFromString:[outbound valueForKey:@"arrival_time"]];
        NSDateComponents *componentsDeparture = [[NSCalendar currentCalendar] components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:departureDate];
        NSDateComponents *componentsArrival = [[NSCalendar currentCalendar] components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:arrivalDate];
        
        fromCodeLabel.text = [outbound valueForKey:@"departure_code"];
        fromNameLabel.text = [outbound valueForKey:@"departure_name"];
        //fromTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",componentsDeparture.hour,componentsDeparture.minute];
        fromTimeLabel.text = [_dateFormatterOutput stringFromDate:departureDate];
        
        toCodeLabel.text = [outbound valueForKey:@"arrival_code"];
        toNameLabel.text = [outbound valueForKey:@"arrival_name"];
        //toTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",componentsArrival.hour,componentsArrival.minute];
        toTimeLabel.text = [_dateFormatterOutput stringFromDate:arrivalDate];
        
        [airlineLogoImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.mediawego.com/images/flights/airlines/120x40t/%@.gif",[outbound valueForKey:@"airline_code"]]] placeholder:nil];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"Connecting Flights";
    else if(section == 2)
        return @"Upcoming events";
    else
        return @"Book Flight";
}

- (void)bookNow:(id)sender
{
    NSLog(@"BOOKING URL %@",[NSString stringWithFormat:@"%@&ts_code=7756f",_flight.deeplink]);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@&ts_code=7756f",_flight.deeplink]]];
}

- (void)moreAction:(UIButton *)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:self.tableView];
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    Event *event = [_eventsArray objectAtIndex:clickedButtonPath.row];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:event.url]];
}

@end
