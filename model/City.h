//
//  City.h
//  Pods
//
//  Created by Konrad Przyludzki on 27.02.2014.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface City : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * iata;

@end
