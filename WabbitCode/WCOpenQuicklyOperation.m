//
//  WCOpenQuicklyOperation.m
//  WabbitStudio
//
//  Created by William Towe on 11/13/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCOpenQuicklyOperation.h"
#import "WCOpenQuicklyItem.h"
#import "WCOpenQuicklyWindowController.h"
#import "WCProjectDocument.h"
#import "WCSymbolIndex.h"
#import "Symbol.h"
#import "File.h"
#import "NSObject+WCExtensions.h"
#import "WCDefines.h"

@interface WCOpenQuicklyOperation ()
@property (assign,nonatomic) WCOpenQuicklyWindowController *windowController;
@property (copy,nonatomic) NSString *string;
@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;
@property (assign,getter = isExecuting) BOOL executing;
@property (assign,getter = isFinished) BOOL finished;
@end

@implementation WCOpenQuicklyOperation

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
    
    __weak typeof (self) weakSelf = self;
    
    [self.managedObjectContext performBlock:^{
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:0];
        
        do {
            if (self.string.length <= 1)
                break;
            
            NSMutableString *pattern = [NSMutableString stringWithCapacity:0];
            
            for (NSUInteger patternIndex=0; patternIndex<self.string.length; patternIndex++) {
                NSString *subPattern = [NSRegularExpression escapedPatternForString:[self.string substringWithRange:NSMakeRange(patternIndex, 1)]];
                
                [pattern appendFormat:@"[^%@]*(%@)",subPattern,subPattern];
            }
            
            [pattern appendString:@".*"];
            
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:NULL];
            
            WCAssert(regex,@"regex cannot be nil!");
            
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Symbol"];
            NSArray *symbols = [weakSelf.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
            
            for (Symbol *symbol in symbols) {
                NSTextCheckingResult *result = [regex firstMatchInString:symbol.name options:0 range:NSMakeRange(0, symbol.name.length)];
                
                if (!result)
                    continue;
                
                WCOpenQuicklyItem *item = [[WCOpenQuicklyItem alloc] initWithObjectID:symbol.objectID];
                
                [item setName:symbol.name];
                [item setImage:symbol.image];
                [item setFileUUID:symbol.fileUUID];
                
                NSMutableIndexSet *ranges = [NSMutableIndexSet indexSet];
                
                for (NSUInteger captureIndex=1; captureIndex<result.numberOfRanges; captureIndex++)
                    [ranges addIndexesInRange:[result rangeAtIndex:captureIndex]];
                
                [item setRanges:ranges];
                
                __block NSUInteger numberOfRanges = 0;
                
                [ranges enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
                    numberOfRanges++;
                }];
                
                [item setNumberOfContiguousRanges:numberOfRanges];
                
                [items addObject:item];
            }
            
            if (self.isCancelled)
                break;
            
            [items sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO comparator:^NSComparisonResult(WCOpenQuicklyItem *obj1, WCOpenQuicklyItem *obj2) {
                CGFloat contiguousWeight1 = floor((CGFloat)obj1.ranges.count / (CGFloat)obj1.numberOfContiguousRanges);
                CGFloat contiguousWeight2 = floor((CGFloat)obj2.ranges.count / (CGFloat)obj2.numberOfContiguousRanges);
                
                if (contiguousWeight1 < contiguousWeight2)
                    return NSOrderedAscending;
                else if (contiguousWeight1 > contiguousWeight2)
                    return NSOrderedDescending;
                return NSOrderedSame;
                
            }],[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES comparator:^NSComparisonResult(WCOpenQuicklyItem *obj1, WCOpenQuicklyItem *obj2) {
                NSUInteger firstIndex1 = obj1.ranges.firstIndex;
                NSUInteger firstIndex2 = obj2.ranges.firstIndex;
                
                if (firstIndex1 < firstIndex2)
                    return NSOrderedAscending;
                else if (firstIndex1 > firstIndex2)
                    return NSOrderedDescending;
                return NSOrderedSame;
                
            }],[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES comparator:^NSComparisonResult(WCOpenQuicklyItem *obj1, WCOpenQuicklyItem *obj2) {
                NSUInteger difference1 = obj1.name.length - obj1.ranges.count;
                NSUInteger difference2 = obj2.name.length - obj2.ranges.count;
                
                if (difference1 < difference2)
                    return NSOrderedAscending;
                else if (difference1 > difference2)
                    return NSOrderedDescending;
                return NSOrderedSame;
                
            }],[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)]]];
            
        } while (0);
        
        if (!self.isCancelled) {
            [weakSelf WC_performBlockOnMainThread:^{
                [weakSelf.windowController setOpenQuicklyItems:items];
            }];
        }
        
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        [self setExecuting:NO];
        [self setFinished:YES];
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
    }];
}

- (id)initWithOpenQuicklyWindowController:(WCOpenQuicklyWindowController *)windowController; {
    if (!(self = [super init]))
        return nil;
    
    [self setWindowController:windowController];
    [self setManagedObjectContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType]];
    [self.managedObjectContext setUndoManager:nil];
    [self.managedObjectContext setParentContext:windowController.projectDocument.symbolIndex.managedObjectContext];
    [self setString:windowController.searchString];
    
    return self;
}

@end
