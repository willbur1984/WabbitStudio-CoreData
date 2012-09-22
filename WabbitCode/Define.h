//
//  Define.h
//  WabbitStudio
//
//  Created by William Towe on 9/22/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Symbol.h"


@interface Define : Symbol

@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSString * arguments;

@end
