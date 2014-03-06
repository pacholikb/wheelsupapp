//
//  City.h
//  WheelsUp
//
//  Created by Konrad Przyludzki on 06.03.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface City : NSManagedObject

@property (nonatomic, retain) NSString * iata;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * country;

@end
