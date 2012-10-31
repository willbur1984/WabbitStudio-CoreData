//
//  WCScanSymbolsOperation.m
//  WabbitStudio
//
//  Created by William Towe on 9/22/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCScanSymbolsOperation.h"
#import "WCSymbolScanner.h"
#import "WCSyntaxHighlighter.h"
#import "NSString+WCExtensions.h"
#import "NSArray+WCExtensions.h"
#import "WCDefines.h"
#import "Label.h"
#import "Equate.h"
#import "Define.h"
#import "Macro.h"
#import "FileContainer.h"

@interface WCScanSymbolsOperation ()
@property (copy,nonatomic) NSString *string;
@property (strong) NSManagedObjectContext *managedObjectContext;
@property (assign,getter = isExecuting) BOOL executing;
@property (assign,getter = isFinished) BOOL finished;
@property (assign,getter = isCancelled) BOOL cancelled;
@property (copy,nonatomic) NSURL *fileURL;
@end

@implementation WCScanSymbolsOperation

- (id)initWithSymbolScanner:(WCSymbolScanner *)symbolScanner; {
    if (!(self = [super init]))
        return nil;
    
    [self setString:symbolScanner.textStorage.string];
    [self setFileURL:[symbolScanner.delegate fileURLForSymbolScanner:symbolScanner]];
    [self setManagedObjectContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType]];
    [self.managedObjectContext setParentContext:symbolScanner.managedObjectContext];
    [self.managedObjectContext setUndoManager:nil];
    
    return self;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)cancel {
    [self willChangeValueForKey:@"isCancelled"];
    [self setCancelled:YES];
    [self didChangeValueForKey:@"isCancelled"];
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
        do {
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FileContainer"];
            
            FileContainer *file = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL].lastObject;
            
            if (file) {
                [self.managedObjectContext deleteObject:file];
            }
            
            file = [NSEntityDescription insertNewObjectForEntityForName:@"FileContainer" inManagedObjectContext:self.managedObjectContext];
            
            [file setIdentifier:[NSString WC_UUIDString]];
            [file setPath:self.fileURL.path];
            
            if (self.isCancelled)
                break;
            
            NSRegularExpression *commentRegex = [NSRegularExpression regularExpressionWithPattern:@"(?:#comment.*?#endcomment)|(?:;+.*?$)" options:NSRegularExpressionDotMatchesLineSeparators|NSRegularExpressionAnchorsMatchLines error:NULL];
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
            
            if (self.isCancelled)
                break;
            
            [[WCSyntaxHighlighter equateRegex] enumerateMatchesInString:self.string options:0 range:NSMakeRange(0, self.string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                NSRange commentRange = [comments WC_rangeForRange:result.range];
                
                if (NSLocationInRange(result.range.location, commentRange))
                    return;
                
                Equate *entity = [NSEntityDescription insertNewObjectForEntityForName:@"Equate" inManagedObjectContext:self.managedObjectContext];
                
                [entity setType:@(SymbolTypeEquate)];
                [entity setLocation:@(result.range.location)];
                [entity setRange:NSStringFromRange([result rangeAtIndex:1])];
                [entity setName:[self.string substringWithRange:[result rangeAtIndex:1]]];
                [entity setLineNumber:@([self.string WC_lineNumberForRange:result.range])];
                [entity setValue:[[self.string substringWithRange:[result rangeAtIndex:2]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                [entity setFile:file];
            }];
            
            if (self.isCancelled)
                break;
            
            [[WCSyntaxHighlighter labelRegex] enumerateMatchesInString:self.string options:0 range:NSMakeRange(0, self.string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                if (result.range.length == 1 &&
                    [self.string characterAtIndex:result.range.location] == '_')
                    return;
                
                NSRange commentRange = [comments WC_rangeForRange:result.range];
                
                if (NSLocationInRange(result.range.location, commentRange))
                    return;
                
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Equate"];
                
                [fetchRequest setResultType:NSCountResultType];
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.location == %@",@(result.range.location)]];
                
                NSArray *fetchResult = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
                
                if ([fetchResult.lastObject unsignedIntegerValue] > 0)
                    return;
                
                Label *entity = [NSEntityDescription insertNewObjectForEntityForName:@"Label" inManagedObjectContext:self.managedObjectContext];
                
                [entity setType:@(SymbolTypeLabel)];
                [entity setLocation:@(result.range.location)];
                [entity setRange:NSStringFromRange(result.range)];
                [entity setName:[self.string substringWithRange:result.range]];
                [entity setLineNumber:@([self.string WC_lineNumberForRange:result.range])];
                [entity setFile:file];
            }];
            
            if (self.isCancelled)
                break;
            
            [[WCSyntaxHighlighter defineRegex] enumerateMatchesInString:self.string options:0 range:NSMakeRange(0, self.string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                NSRange commentRange = [comments WC_rangeForRange:result.range];
                
                if (NSLocationInRange(result.range.location, commentRange))
                    return;
                
                Define *entity = [NSEntityDescription insertNewObjectForEntityForName:@"Define" inManagedObjectContext:self.managedObjectContext];
                
                [entity setType:@(SymbolTypeDefine)];
                [entity setLocation:@(result.range.location)];
                [entity setRange:NSStringFromRange([result rangeAtIndex:1])];
                [entity setName:[self.string substringWithRange:[result rangeAtIndex:1]]];
                [entity setLineNumber:@([self.string WC_lineNumberForRange:result.range])];
                [entity setFile:file];
                
                [[WCSyntaxHighlighter expandedDefineRegex] enumerateMatchesInString:self.string options:0 range:[self.string lineRangeForRange:result.range] usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                    NSRange argumentsRange = [result rangeAtIndex:2];
                    
                    if (argumentsRange.length > 0)
                        [entity setArguments:[self.string substringWithRange:NSMakeRange(argumentsRange.location + 1, argumentsRange.length - 2)]];
                    
                    [entity setValue:[[self.string substringWithRange:[result rangeAtIndex:3]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                    
                    *stop = YES;
                }];
            }];
            
            if (self.isCancelled)
                break;
            
            [[WCSyntaxHighlighter macroRegex] enumerateMatchesInString:self.string options:0 range:NSMakeRange(0, self.string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                NSRange commentRange = [comments WC_rangeForRange:result.range];
                
                if (NSLocationInRange(result.range.location, commentRange))
                    return;
                
                Macro *entity = [NSEntityDescription insertNewObjectForEntityForName:@"Macro" inManagedObjectContext:self.managedObjectContext];
                
                [entity setType:@(SymbolTypeMacro)];
                [entity setLocation:@(result.range.location)];
                [entity setRange:NSStringFromRange([result rangeAtIndex:1])];
                [entity setName:[self.string substringWithRange:[result rangeAtIndex:1]]];
                [entity setLineNumber:@([self.string WC_lineNumberForRange:result.range])];
                [entity setFile:file];
                
                [[WCSyntaxHighlighter expandedMacroRegex] enumerateMatchesInString:self.string options:0 range:NSMakeRange(result.range.location, self.string.length - result.range.location) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                    NSRange argumentsRange = [result rangeAtIndex:2];
                    
                    if (argumentsRange.length > 0)
                        [entity setArguments:[self.string substringWithRange:NSMakeRange(argumentsRange.location + 1, argumentsRange.length - 2)]];

                    [entity setValue:[[self.string substringWithRange:[result rangeAtIndex:3]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                    
                    *stop = YES;
                }];
            }];
            
        } while (0);
        
        if (!self.isCancelled)
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
