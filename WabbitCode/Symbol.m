//
//  Symbol.m
//  WabbitStudio
//
//  Created by William Towe on 9/22/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//

#import "Symbol.h"


@implementation Symbol

@dynamic name;
@dynamic range;
@dynamic type;

@dynamic rangeValue;
- (NSRange)rangeValue {
    return NSRangeFromString(self.range);
}

@end
