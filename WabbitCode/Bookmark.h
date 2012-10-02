//
//  Bookmark.h
//  WabbitStudio
//
//  Created by William Towe on 10/1/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Bookmark : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * location;
@property (nonatomic, retain) NSString * range;

@end
