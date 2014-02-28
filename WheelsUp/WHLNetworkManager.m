//
//  WHLNetworkManager.m
//  WheelsUp
//
//  Created by Konrad Przyludzki on 13.02.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

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
                                                        
                                                         @"id":                     @"flightNumber",
                                                         @"best_fare.price":                     @"price",
                                                         @"best_fare.deeplink":                     @"deeplink",
                                                         @"best_fare.deeplink_params.trip_id":                     @"tripId",
                                                         @"best_fare.deeplink_params.search_id":                     @"searchId",
                                                         @"outbound_segments":                     @"outbounds"
                                                         
                                                         }];
    flightMapping.identificationAttributes = @[ @"flightNumber" ];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:flightMapping method:RKRequestMethodPOST pathPattern:nil keyPath:@"routes" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    //
    
    //Trip entity
    
    RKEntityMapping *tripMapping = [RKEntityMapping mappingForEntityForName:@"Trip" inManagedObjectStore:managedObjectStore];
    [tripMapping addAttributeMappingsFromDictionary:@{
                                                      
                                                        @"key":                 @"key",
                                                        @"trips":             @"trips",
                                                        @"created_at":          @"createdAt",
                                                        @"id":                   @"searchId"
                                                        
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
    _weatherObjectManager.managedObjectStore = managedObjectStore;
    
    [_weatherObjectManager.router.routeSet addRoute:[RKRoute routeWithName:@"weatherRoute" pathPattern:@"weather.ashx" method:RKRequestMethodGET]];
    
    RKEntityMapping *weatherMapping = [RKEntityMapping mappingForEntityForName:@"Weather" inManagedObjectStore:managedObjectStore];
    [weatherMapping addAttributeMappingsFromDictionary:@{
                                                         @"@metadata.routing.parameters.location":     @"location",
                                                         @"date":                                            @"date",
                                                         @"tempMaxC":                                       @"tempMax",
                                                         @"weatherIconUrl":                                       @"iconUrl",
                                                         @"weatherDesc":                                       @"conditions",
                                                         @"tempMinC":                                     @"tempMin"
                                                         }];
    weatherMapping.identificationAttributes = @[ @"location", @"date" ];
    
    responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:weatherMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"data.weather" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [_weatherObjectManager addResponseDescriptor:responseDescriptor];
    //
    
}

- (void)makeSearchRequestFrom :(NSString *)from to:(NSString *)to success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                       failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure
{
    if(!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"YYYY-MM-d";
    }
    
    NSString *date = [_dateFormatter stringFromDate:[NSDate date]];
    
    NSDictionary *tripDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[from uppercaseString], @"departure_code", [to uppercaseString], @"arrival_code", date, @"outbound_date", nil];
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys: [NSArray arrayWithObject:tripDictionary], @"trips", @"1", @"adults_count", nil ];
    
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

- (void)makeFlightRequestWithSearchId :(NSString *)searchId andTripId:(NSString *)tripId success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                               failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure numberOfTimes:(NSUInteger)nTimes
{
    if(nTimes <= 0)
    {
        NSError *error = [NSError errorWithDomain:@"" code:-10 userInfo:nil];
        if(failure)failure(nil, error);
    }
    else
    {
        NSDictionary *flightsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:searchId, @"search_id", tripId, @"trip_id", @"route", @"fares_query_type", @"as34fg3dfvasse", @"id", nil];
    
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:flightsDictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
        NSLog(@"%@",flightsDictionary);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://api.wego.com/flights/api/k/2/fares?api_key=362145dfb72cb3ce293d&ts_code=7756f"]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:jsonData ];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
        RKManagedObjectRequestOperation *op = [[RKObjectManager sharedManager] managedObjectRequestOperationWithRequest:request managedObjectContext:[RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            if(mappingResult.array && mappingResult.array.count > 0) {
                if(success)success(operation, mappingResult);
            }
            else {
                [[WHLNetworkManager sharedInstance] makeFlightRequestWithSearchId:searchId andTripId:tripId success:success failure:failure numberOfTimes:nTimes-1];
            }
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [[WHLNetworkManager sharedInstance] makeFlightRequestWithSearchId:searchId andTripId:tripId success:success failure:failure numberOfTimes:nTimes-1];
        }];
    
        [op performSelector:@selector(start) withObject:nil afterDelay:1];
        
    }
}

@end
