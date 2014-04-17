//
//  BlogPost.h
//  WheelsUp
//
//  Created by Konrad Przyludzki on 17.04.2014.
//  Copyright (c) 2014 Broc Pacholik . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BlogPost : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * postId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) id tags;
@property (nonatomic, retain) id categories;

@end
