//
//  Weather.h
//  WheelsUp
//
//  Created by Konrad Przyludzki on 21.02.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Weather : NSManagedObject

@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * tempMax;
@property (nonatomic, retain) NSString * iconUrl;
@property (nonatomic, retain) NSString * tempMin;
@property (nonatomic, retain) id conditions;
@property (nonatomic, retain) NSString * location;

@end
