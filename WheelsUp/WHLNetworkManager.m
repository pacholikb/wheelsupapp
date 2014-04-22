//
//  WHLNetworkManager.m
//  WheelsUp
//
//  Created by Konrad Przyludzki on 13.02.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import "Weather.h"
#import "Event.h"
#import "BlogPost.h"
#import "WHLNetworkManager.h"

@implementation WHLNetworkManager

+ (WHLNetworkManager *)sharedInstance
{
    static WHLNetworkManager *sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[WHLNetworkManager alloc] init];
        
        sharedInstance.locationManager = [[CLLocationManager alloc] init];
    });
    
    return sharedInstance;
}

- (NSDictionary *)getApiKeysParams
{
    if(!_apiKeys)
        _apiKeys = [NSDictionary dictionaryWithObjectsAndKeys:@"api_key", @"362145dfb72cb3ce293d", @"ts_code", @"7756f", nil];
    
    NSLog(@"%@",_apiKeys);
    return _apiKeys;
}

- (void)configureObjectManager :(RKManagedObjectStore *)managedObjectStore
{
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:BASE_URL]];
    objectManager.managedObjectStore = managedObjectStore;
    
    [RKObjectManager setSharedManager:objectManager];
    
    //Flight entity
    
    //[objectManager.router.routeSet addRoute:[RKRoute routeWithName:@"flightsRoute" pathPattern:@"fares" method:RKRequestMethodPOST]];
    
    RKEntityMapping *flightMapping = [RKEntityMapping mappingForEntityForName:@"Flight" inManagedObjectStore:managedObjectStore];
    [flightMapping addAttributeMappingsFromDictionary:@{
                                                        
                                                         @"id":                                     @"flightNumber",
                                                         @"best_fare.price":                        @"price",
                                                         @"best_fare.deeplink":                     @"deeplink",
                                                         @"best_fare.deeplink_params.trip_id":      @"tripId",
                                                         @"best_fare.deeplink_params.search_id":    @"searchId",
                                                         @"outbound_segments":                      @"outbounds",
                                                         @"inbound_segments":                       @"inbounds"
                                                         
                                                         }];
    flightMapping.identificationAttributes = @[ @"flightNumber" ];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:flightMapping method:RKRequestMethodPOST pathPattern:nil keyPath:@"routes" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    //
    
    //Trip entity
    
    RKEntityMapping *tripMapping = [RKEntityMapping mappingForEntityForName:@"Trip" inManagedObjectStore:managedObjectStore];
    [tripMapping addAttributeMappingsFromDictionary:@{
                                                      
                                                        @"key":               @"key",
                                                        @"trips":             @"trips",
                                                        @"created_at":        @"createdAt",
                                                        @"id":                @"searchId"
                                                        
                                                        }];
    tripMapping.identificationAttributes = @[ @"key" ];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:tripMapping method:RKRequestMethodPOST pathPattern:@"searches" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [objectManager addResponseDescriptor:responseDescriptor];
//
//    [objectManager addFetchRequestBlock:^NSFetchRequest *(NSURL *URL) {
//        RKPathMatcher *pathMatcher = [RKPathMatcher pathMatcherWithPattern:@"searches"];
//        NSDictionary *argsDict = nil;
//        if ([pathMatcher matchesPath:[URL relativePath] tokenizeQueryStrings:NO parsedArguments:&argsDict]) {
//            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Trip"];
//            return fetchRequest;
//        }
//        return nil;
//    }];
    
    //
    
    //Weather entity
    _weatherObjectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://api.worldweatheronline.com/free/v1/"]];
    
    [_weatherObjectManager.router.routeSet addRoute:[RKRoute routeWithName:@"weatherRoute" pathPattern:@"weather.ashx" method:RKRequestMethodGET]];
    
    RKObjectMapping *weatherMapping = [RKObjectMapping mappingForClass:[Weather class]];
    [weatherMapping addAttributeMappingsFromDictionary:@{
                                                         @"@metadata.routing.parameters.location":     @"location",
                                                         @"date":                                      @"date",
                                                         @"tempMaxC":                                  @"tempMax",
                                                         @"weatherIconUrl":                            @"iconUrls",
                                                         @"weatherDesc":                               @"conditions",
                                                         @"tempMinC":                                  @"tempMin"
                                                         }];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:weatherMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"data.weather" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [_weatherObjectManager addResponseDescriptor:responseDescriptor];
    //
    
    //Event entity
    _eventsObjectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://api.eventful.com/json/events/search"]];
    
    [_eventsObjectManager.router.routeSet addRoute:[RKRoute routeWithName:@"eventRoute" pathPattern:@"" method:RKRequestMethodGET]];
    
    RKObjectMapping *eventMapping = [RKObjectMapping mappingForClass:[Event class]];
    [eventMapping addAttributeMappingsFromDictionary:@{
                                                         @"id":                         @"eventId",
                                                         @"title":                      @"title",
                                                         @"url":                        @"url",
                                                         @"start_time":                 @"startTime",
                                                         @"description":                @"desc",
                                                         @"venue_name":                 @"venueName",
                                                         @"image.medium.url":           @"imageUrl"
                                                         }];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:eventMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"events.event" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [_eventsObjectManager addResponseDescriptor:responseDescriptor];
    //
    
    //BlogPost entity
    _blogObjectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://wheels-up.co"]];
    _blogObjectManager.managedObjectStore = managedObjectStore;
    
    [_blogObjectManager.router.routeSet addRoute:[RKRoute routeWithName:@"blogRoute" pathPattern:@"" method:RKRequestMethodGET]];
    
    RKEntityMapping *blogMapping = [RKEntityMapping mappingForEntityForName:@"BlogPost" inManagedObjectStore:managedObjectStore];
    [blogMapping addAttributeMappingsFromDictionary:@{
                                                       @"id":                        @"postId",
                                                       @"title":                     @"title",
                                                       @"content":                   @"content",
                                                       @"tags":                      @"tags",
                                                       @"categories":                @"categories",
                                                       @"thumbnail":                 @"image",
                                                       @"modified":                      @"date"
                                                       }];
    blogMapping.identificationAttributes = @[ @"postId" ];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:blogMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"posts" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [_blogObjectManager addResponseDescriptor:responseDescriptor];
    //
    
}

- (void)makeSearchRequestFrom :(NSString *)from to:(NSString *)to when:(NSString *)when returnOn:(NSString *)inbound adults:(NSString *)adults children:(NSString *)children success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                       failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    if(!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"YYYY-MM-d";
    }
    
    NSString *date = when.length > 0 ? when : [_dateFormatter stringFromDate:[NSDate date]];
    
    NSDictionary *tripDictionary;
    if(inbound.length > 0)
        tripDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[from uppercaseString], @"departure_code", [to uppercaseString], @"arrival_code", date, @"outbound_date", inbound, @"inbound_date", nil];
    else
        tripDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[from uppercaseString], @"departure_code", [to uppercaseString], @"arrival_code", date, @"outbound_date", nil];
        
    NSMutableDictionary *body = [NSMutableDictionary dictionaryWithObjectsAndKeys: [NSArray arrayWithObject:tripDictionary], @"trips", nil ];
    
    if(adults)
        [body setValue:adults forKey:@"adults_count"];
    else
        [body setValue:@"1" forKey:@"adults_count"];
    if(children)
        [body setValue:children forKey:@"children_count"];
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://api.wego.com/flights/api/k/2/searches?api_key=362145dfb72cb3ce293d&ts_code=7756f"]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData ];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    RKManagedObjectRequestOperation *op = [[RKObjectManager sharedManager] managedObjectRequestOperationWithRequest:request managedObjectContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if(success)success(operation, mappingResult);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if(failure)failure(operation, error);
    }];
    
    [op start];
}

- (void)makeFlightRequestWithSearchId :(NSString *)searchId andTripId:(NSString *)tripId stops:(NSString *)stops maxrrice:(NSString *)maxPrice success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                               failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure numberOfTimes:(NSUInteger)nTimes
{
    if(nTimes <= 0)
    {
        NSError *error = [NSError errorWithDomain:@"" code:-10 userInfo:nil];
        if(failure)failure(nil, error);
    }
    else
    {
        NSMutableDictionary *flightsDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:searchId, @"search_id", tripId, @"trip_id", @"route", @"fares_query_type", @"as34fg3dfvasse", @"id", @"USD", @"currency_code", nil];
        
        if(stops)
            [flightsDictionary setValue:[NSArray arrayWithObject:stops] forKey:@"stop_types"];
        if(maxPrice)
            [flightsDictionary setValue:maxPrice forKey:@"price_max_usd"];
    
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:flightsDictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
        //NSLog(@"%@",flightsDictionary);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://api.wego.com/flights/api/k/2/fares?api_key=362145dfb72cb3ce293d&ts_code=7756f"]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:jsonData ];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
        RKManagedObjectRequestOperation *op = [[RKObjectManager sharedManager] managedObjectRequestOperationWithRequest:request managedObjectContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {  
            if(mappingResult.array && mappingResult.array.count > 0) {
                if(success)success(operation, mappingResult);
            }
            else {
                [[WHLNetworkManager sharedInstance] makeFlightRequestWithSearchId:searchId andTripId:tripId stops:stops maxrrice:maxPrice success:success failure:failure numberOfTimes:nTimes-1];
            }
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [[WHLNetworkManager sharedInstance] makeFlightRequestWithSearchId:searchId andTripId:tripId stops:stops maxrrice:maxPrice success:success failure:failure numberOfTimes:nTimes-1];
        }];
    
        [op performSelector:@selector(start) withObject:nil afterDelay:2];
        
    }
}

- (void)setBackgroundGradient :(UIView *)view
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.startPoint = CGPointMake(0, 1);
    gradient.endPoint = CGPointMake(0, 0);
    gradient.frame = view.frame;
    gradient.colors = [NSArray arrayWithObjects:(id)[[[WHLNetworkManager sharedInstance] colorFromHexString:@"#FFFFFF"] CGColor], (id)[[[WHLNetworkManager sharedInstance] colorFromHexString:@"#E1DCE5"] CGColor], nil];
    
    [view.layer insertSublayer:gradient atIndex:0];
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
