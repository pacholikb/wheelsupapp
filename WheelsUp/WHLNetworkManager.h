//
//  WHLNetworkManager.h
//  WheelsUp
//
//  Created by Konrad Przyludzki on 13.02.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <CoreLocation/CoreLocation.h>

#define BASE_URL @"http://api.wego.com/flights/api/k/2/"
//#define BASE_URL @"http://postcatcher.in/catchers/"

@interface WHLNetworkManager : NSObject

@property (nonatomic, strong)CLLocationManager *locationManager;
@property (nonatomic, strong)RKObjectManager *weatherObjectManager;
@property (nonatomic, strong)NSDictionary *apiKeys;

@property (strong) NSDateFormatter *dateFormatter;

+ (WHLNetworkManager *)sharedInstance;
- (void)configureObjectManager :(RKManagedObjectStore *)managedObjectStore;
- (NSDictionary *)getApiKeysParams;

- (void)makeSearchRequestFrom :(NSString *)from to:(NSString *)to adults:(NSString *)adults children:(NSString *)children success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                       failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;
- (void)makeFlightRequestWithSearchId :(NSString *)searchId andTripId:(NSString *)tripId stops:(NSString *)stops maxrrice:(NSString *)maxPrice success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                               failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure numberOfTimes:(NSUInteger)nTimes;

@end
