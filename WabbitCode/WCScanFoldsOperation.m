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
