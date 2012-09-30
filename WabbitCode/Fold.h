//
//  Fold.h
//  WabbitStudio
//
//  Created by William Towe on 9/28/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "WCFoldMarker.h"

typedef enum {
    FoldTypeComment = WCFoldMarkerTypeCommentStart,
    FoldTypeMacro = WCFoldMarkerTypeMacroStart,
    FoldTypeIf = WCFoldMarkerTypeIfStart
    
} FoldType;

@class Fold;

@interface Fold : NSManagedObject

@property (nonatomic, retain) NSString * range;
@property (nonatomic, retain) NSString * contentRange;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * depth;
@property (nonatomic, retain) NSNumber * location;
@property (nonatomic, retain) NSSet *folds;
@property (nonatomic, retain) Fold *fold;

- (void)increaseDepth;
@end

@interface Fold (CoreDataGeneratedAccessors)

- (void)addFoldsObject:(Fold *)value;
- (void)removeFoldsObject:(Fold *)value;
- (void)addFolds:(NSSet *)values;
- (void)removeFolds:(NSSet *)values;

@end
