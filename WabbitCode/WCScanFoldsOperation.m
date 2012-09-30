//
//  WCScanFoldsOperation.m
//  WabbitStudio
//
//  Created by William Towe on 9/28/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCScanFoldsOperation.h"
#import "WCFoldScanner.h"
#import "Fold.h"
#import "WCFoldMarker.h"
#import "NSArray+WCExtensions.h"

@interface WCScanFoldsOperation ()
@property (copy,nonatomic) NSString *string;
@property (strong) NSManagedObjectContext *managedObjectContext;
@property (assign,getter = isExecuting) BOOL executing;
@property (assign,getter = isFinished) BOOL finished;
@end

@implementation WCScanFoldsOperation

- (id)initWithFoldScanner:(WCFoldScanner *)foldScanner; {
    if (!(self = [super init]))
        return nil;
    
    [self setString:foldScanner.textStorage.string];
    [self setManagedObjectContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType]];
    [self.managedObjectContext setParentContext:foldScanner.managedObjectContext];
    [self.managedObjectContext setUndoManager:nil];
    
    return self;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)main {
    if (self.isCancelled) {
        [self willChangeValueForKey:@"isFinished"];
        [self setFinished:YES];
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    [self setExecuting:YES];
    [self didChangeValueForKey:@"isExecuting"];
    
    [self.managedObjectContext performBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Fold"];
        
        for (Fold *fold in [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL])
            [self.managedObjectContext deleteObject:fold];
        
        NSRegularExpression *commentRegex = [NSRegularExpression regularExpressionWithPattern:@"(?:#comment.*?#endcomment)|(?:;+.?$)" options:NSRegularExpressionDotMatchesLineSeparators|NSRegularExpressionAnchorsMatchLines error:NULL];
        NSMutableArray *comments = [NSMutableArray arrayWithCapacity:0];
        
        [commentRegex enumerateMatchesInString:self.string options:0 range:NSMakeRange(0, self.string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            [comments addObject:[NSValue valueWithRange:result.range]];
        }];
        
        [comments sortUsingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
            NSRange range1 = obj1.rangeValue;
            NSRange range2 = obj2.rangeValue;
            
            if (range1.location < range2.location)
                return NSOrderedAscending;
            else if (range1.location > range2.location)
                return NSOrderedDescending;
            return NSOrderedSame;
        }];
        
        NSMutableArray *foldMarkers = [NSMutableArray arrayWithCapacity:0];
        
        [[WCFoldMarker foldStartMarkerRegex] enumerateMatchesInString:self.string options:0 range:NSMakeRange(0, self.string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            NSString *name = [[self.string substringWithRange:result.range] lowercaseString];
            WCFoldMarkerType type;
            
            if ([name isEqualToString:@"#comment"])
                type = WCFoldMarkerTypeCommentStart;
            else if ([name isEqualToString:@"#macro"])
                type = WCFoldMarkerTypeMacroStart;
            else
                type = WCFoldMarkerTypeIfStart;
            
            NSRange commentRange = [comments WC_rangeForRange:result.range];
            
            if (NSLocationInRange(result.range.location, commentRange))
                return;
            
            [foldMarkers addObject:[[WCFoldMarker alloc] initWithType:type range:result.range]];
        }];
        
        [[WCFoldMarker foldEndMarkerRegex] enumerateMatchesInString:self.string options:0 range:NSMakeRange(0, self.string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            NSString *name = [[self.string substringWithRange:result.range] lowercaseString];
            WCFoldMarkerType type;
            
            if ([name isEqualToString:@"#comment"])
                type = WCFoldMarkerTypeCommentEnd;
            else if ([name isEqualToString:@"#endmacro"])
                type = WCFoldMarkerTypeMacroEnd;
            else
                type = WCFoldMarkerTypeIfEnd;
            
            NSRange commentRange = [comments WC_rangeForRange:result.range];
            
            if (NSLocationInRange(result.range.location, commentRange))
                return;
            
            [foldMarkers addObject:[[WCFoldMarker alloc] initWithType:type range:result.range]];
        }];
        
        [foldMarkers sortUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"range" ascending:YES comparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
            NSRange range1 = obj1.rangeValue;
            NSRange range2 = obj2.rangeValue;
            
            if (range1.location < range2.location)
                return NSOrderedAscending;
            else if (range1.location > range2.location)
                return NSOrderedDescending;
            return NSOrderedSame;
        }] ]];
        
        NSMutableArray *folds = [NSMutableArray arrayWithCapacity:0];
        NSMutableArray *foldMarkerStack = [NSMutableArray arrayWithCapacity:0];
        
        for (WCFoldMarker *foldMarker in foldMarkers) {
            switch (foldMarker.type) {
                case WCFoldMarkerTypeCommentStart:
                case WCFoldMarkerTypeMacroStart:
                case WCFoldMarkerTypeIfStart:
                    [foldMarkerStack addObject:foldMarker];
                    break;
                case WCFoldMarkerTypeCommentEnd:
                case WCFoldMarkerTypeMacroEnd:
                case WCFoldMarkerTypeIfEnd: {
                    WCFoldMarker *startFoldMarker = foldMarkerStack.lastObject;
                    WCFoldMarker *endFoldMarker = foldMarker;
                    
                    if ((startFoldMarker.type == WCFoldMarkerTypeCommentStart && endFoldMarker.type == WCFoldMarkerTypeCommentEnd) ||
                        (startFoldMarker.type == WCFoldMarkerTypeMacroStart && endFoldMarker.type == WCFoldMarkerTypeMacroEnd) ||
                        (startFoldMarker.type == WCFoldMarkerTypeIfStart && endFoldMarker.type == WCFoldMarkerTypeIfEnd)) {
                        
                        NSRange range = [self.string lineRangeForRange:NSUnionRange(startFoldMarker.range, endFoldMarker.range)];
                        NSUInteger firstCharIndex = NSMaxRange(startFoldMarker.range);
                        NSUInteger lastCharIndex = endFoldMarker.range.location;
                        NSRange contentRange = NSMakeRange(firstCharIndex, lastCharIndex - firstCharIndex);
                        Fold *topLevelFold = [NSEntityDescription insertNewObjectForEntityForName:@"Fold" inManagedObjectContext:self.managedObjectContext];
                        
                        [topLevelFold setType:@(startFoldMarker.type)];
                        [topLevelFold setDepth:@0];
                        [topLevelFold setLocation:@(range.location)];
                        [topLevelFold setRange:NSStringFromRange(range)];
                        [topLevelFold setContentRange:NSStringFromRange(contentRange)];
                        
                        for (Fold *fold in folds.reverseObjectEnumerator) {
                            if (!NSLocationInRange(NSRangeFromString(fold.range).location, NSRangeFromString(topLevelFold.range)))
                                break;
                            
                            [fold increaseDepth];
                            
                            [topLevelFold addFoldsObject:fold];
                            [folds removeObject:fold];
                        }
                        
                        [folds addObject:topLevelFold];
                        [foldMarkerStack removeLastObject];
                    }
                    else {
                        for (WCFoldMarker *fold in foldMarkerStack.reverseObjectEnumerator) {
                            startFoldMarker = fold;
                            
                            if ((startFoldMarker.type == WCFoldMarkerTypeCommentStart && endFoldMarker.type == WCFoldMarkerTypeCommentEnd) ||
                                (startFoldMarker.type == WCFoldMarkerTypeMacroStart && endFoldMarker.type == WCFoldMarkerTypeMacroEnd) ||
                                (startFoldMarker.type == WCFoldMarkerTypeIfStart && endFoldMarker.type == WCFoldMarkerTypeIfEnd)) {
                                
                                NSRange range = [self.string lineRangeForRange:NSUnionRange(startFoldMarker.range, endFoldMarker.range)];
                                NSUInteger firstCharIndex = NSMaxRange(startFoldMarker.range);
                                NSUInteger lastCharIndex = endFoldMarker.range.location;
                                NSRange contentRange = NSMakeRange(firstCharIndex, lastCharIndex - firstCharIndex);
                                Fold *topLevelFold = [NSEntityDescription insertNewObjectForEntityForName:@"Fold" inManagedObjectContext:self.managedObjectContext];
                                
                                [topLevelFold setType:@(startFoldMarker.type)];
                                [topLevelFold setDepth:@0];
                                [topLevelFold setLocation:@(range.location)];
                                [topLevelFold setRange:NSStringFromRange(range)];
                                [topLevelFold setContentRange:NSStringFromRange(contentRange)];
                                
                                for (Fold *fold in folds.reverseObjectEnumerator) {
                                    if (!NSLocationInRange(NSRangeFromString(fold.range).location, NSRangeFromString(topLevelFold.range)))
                                        break;
                                    
                                    [fold increaseDepth];
                                    
                                    [topLevelFold addFoldsObject:fold];
                                    [folds removeObject:fold];
                                }
                                
                                [folds addObject:topLevelFold];
                                [foldMarkerStack removeObject:startFoldMarker];
                                
                                break;
                            }
                        }
                    }
                }
                    break;
                default:
                    break;
            }
        }
        
        [self.managedObjectContext save:NULL];
        
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        [self setExecuting:NO];
        [self setFinished:YES];
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
    }];
}

@end
