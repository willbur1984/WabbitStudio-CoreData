//
//  Fold.m
//  WabbitStudio
//
//  Created by William Towe on 9/28/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//

#import "Fold.h"
#import "Fold.h"


@implementation Fold

@dynamic range;
@dynamic contentRange;
@dynamic type;
@dynamic depth;
@dynamic location;
@dynamic endLocation;
@dynamic folds;
@dynamic fold;

- (void)increaseDepth; {
    [self setDepth:@(self.depth.shortValue + 1)];
    
    for (Fold *fold in self.folds) {
        [fold setDepth:self.depth];
        [fold increaseDepth];
    }
}

@end
