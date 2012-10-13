//
//  Completion.h
//  WabbitStudio
//
//  Created by William Towe on 10/13/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Completion : NSManagedObject

@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * priority;

@end
