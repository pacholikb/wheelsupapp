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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[WHLNetworkManager sharedInstance] setBackgroundGradient:self.view];

    _outbounds = _flight.outbounds;
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    _dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZ";
    [_dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSString *localFormat = [NSDateFormatter dateFormatFromTemplate:@"MMM dd hh:mm a" options:0 locale:[NSLocale currentLocale]];
    _dateFormatterOutput = [[NSDateFormatter alloc] init];
    _dateFormatterOutput.dateFormat = localFormat;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 1)
        return 1;
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

- (IBAction)infoAction:(id)sender {
    NSString *urlString = [NSString stringWithFormat:@"http://en.wikipedia.org/wiki/%@",[[_outbounds lastObject] valueForKey:@"arrival_name"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

@end
