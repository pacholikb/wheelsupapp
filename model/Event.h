//
//  Event.h
//  WheelsUp
//
//  Created by Konrad Przyludzki on 17.03.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSString * venueName;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * eventId;

@end
