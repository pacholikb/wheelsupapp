//
//  SearchModel.h
//  WheelsUp
//
//  Created by Konrad Przyludzki on 13.02.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchModel : NSObject

@property (nonatomic, retain) NSString * fromAirportCode;
@property (nonatomic, retain) NSString * toAirportCode;
@property (nonatomic, retain) NSString * date;

@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * radius;

@end
