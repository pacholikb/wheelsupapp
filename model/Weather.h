//
//  Weather.h
//  WheelsUp
//
//  Created by Konrad Przyludzki on 10.03.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Weather : NSObject

@property (nonatomic, retain) id conditions;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) id iconUrls;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * tempMax;
@property (nonatomic, retain) NSString * tempMin;

@end
