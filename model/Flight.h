//
//  Flight.h
//  WheelsUp
//
//  Created by Konrad Przyludzki on 27.02.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Flight : NSManagedObject

@property (nonatomic, retain) NSString * deeplink;
@property (nonatomic, retain) NSString * flightNumber;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * searchId;
@property (nonatomic, retain) NSString * tripId;
@property (nonatomic, retain) id outbounds;
@property (nonatomic, retain) id inbounds;

@end
