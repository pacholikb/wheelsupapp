//
//  Trip.h
//  WheelsUp
//
//  Created by Konrad Przyludzki on 28.02.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Trip : NSManagedObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * searchId;
@property (nonatomic, retain) id trips;
@property (nonatomic, retain) NSDate * createdAt;

@end
