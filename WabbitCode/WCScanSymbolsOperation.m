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
#import "CalledLabel.h"

@interface WCScanSymbolsOperation ()
@property (copy,nonatomic) NSString *string;
@property (strong) NSManagedObjectContext *managedObjectContext;
@property (assign,getter = isExecuting) BOOL executing;
@property (assign,getter = isFinished) BOOL finished;
@property (assign,getter = isCancelled) BOOL cancelled;
@property (copy,nonatomic) NSURL *fileURL;
@property (readwrite,strong,nonatomic) NSString *fileContainerUUID;
@end

@implementation WCScanSymbolsOperation

- (id)initWithSymbolScanner:(WCSymbolScanner *)symbolScanner; {
    if (!(self = [super init]))
        return nil;
    
    [self setString:symbolScanner.textStorage.string];
    [self setFileURL:[symbolScanner.delegate fileURLForSymbolScanner:symbolScanner]];
    [self setFileContainerUUID:symbolScanner.fileContainerUUID];
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
    
    __weak typeof (self) weakSelf = self;
    
    [self.managedObjectContext performBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FileContainer"];
        
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.uuid == %@",weakSelf.fileContainerUUID]];
        
        FileContainer *fileContainer = [weakSelf.managedObjectContext executeFetchRequest:fetchRequest error:NULL].lastObject;
        
        if (!fileContainer) {
            fileContainer = [NSEntityDescription insertNewObjectForEntityForName:@"FileContainer" inManagedObjectContext:weakSelf.managedObjectContext];
            
            [fileContainer setUuid:weakSelf.fileContainerUUID];
        }
        
        [fileContainer setPath:weakSelf.fileURL.path];
        
        for (CalledLabel *calledLabel in fileContainer.calledLabels)
            [weakSelf.managedObjectContext deleteObject:calledLabel];
        
        NSMutableSet *oldSymbols = [NSMutableSet setWithSet:fileContainer.symbols];
        
        do {
            NSRegularExpression *commentRegex = [NSRegularExpression regularExpressionWithPattern:@"(?:#comment.*?#endcomment)|(?:;+.*?$)" options:NSRegularExpressionDotMatchesLineSeparators|NSRegularExpressionAnchorsMatchLines error:NULL];
            NSMutableArray *comments = [NSMutableArray arrayWithCapacity:0];
            
            [commentRegex enumerateMatchesInString:weakSelf.string options:0 range:NSMakeRange(0, weakSelf.string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
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
            
            if (weakSelf.isCancelled)
                break;
            
            NSPredicate *equatePredicate = [NSPredicate predicateWithFormat:@"self.fileContainer == %@ AND self.range == $RANGE AND self.name ==[cd] $NAME",fileContainer];
            
            [[WCSyntaxHighlighter equateRegex] enumerateMatchesInString:weakSelf.string options:0 range:NSMakeRange(0, weakSelf.string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                NSRange commentRange = [comments WC_rangeForRange:result.range];
                
                if (NSLocationInRange(result.range.location, commentRange))
                    return;
                
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Equate"];
                
                [fetchRequest setPredicate:[equatePredicate predicateWithSubstitutionVariables:@{@"RANGE" : NSStringFromRange([result rangeAtIndex:1]), @"NAME" : [weakSelf.string substringWithRange:[result rangeAtIndex:1]]}]];
                [fetchRequest setFetchLimit:1];
                
                Equate *entity = [weakSelf.managedObjectContext executeFetchRequest:fetchRequest error:NULL].lastObject;
                
                if (entity) {
                    [oldSymbols removeObject:entity];
                }
                else {
                    entity = [NSEntityDescription insertNewObjectForEntityForName:@"Equate" inManagedObjectContext:weakSelf.managedObjectContext];
                }
                
                [entity setType:@(SymbolTypeEquate)];
                [entity setLocation:@(result.range.location)];
                [entity setRange:NSStringFromRange([result rangeAtIndex:1])];
                [entity setName:[weakSelf.string substringWithRange:[result rangeAtIndex:1]]];
                [entity setLineNumber:@([weakSelf.string WC_lineNumberForRange:result.range])];
                
                NSString *value = [[weakSelf.string substringWithRange:[result rangeAtIndex:2]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                [entity setValue:[value stringByReplacingOccurrencesOfString:@"\t" withString:@" "]];
                [entity setFileContainer:fileContainer];
            }];
            
            if (weakSelf.isCancelled)
                break;
            
            NSPredicate *labelPredicate = [NSPredicate predicateWithFormat:@"self.fileContainer == %@ AND self.range == $RANGE AND self.name ==[cd] $NAME",fileContainer];
            NSPredicate *duplicatePredicate = [NSPredicate predicateWithFormat:@"self.fileContainer == %@ AND self.location == $LOCATION",fileContainer];
            
            [[WCSyntaxHighlighter labelRegex] enumerateMatchesInString:weakSelf.string options:0 range:NSMakeRange(0, weakSelf.string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                if (result.range.length == 1 && [weakSelf.string characterAtIndex:result.range.location] == '_')
                    return;
                else if (NSMaxRange(result.range) < weakSelf.string.length && [weakSelf.string characterAtIndex:NSMaxRange(result.range)] == '(')
                    return;
                
                NSRange commentRange = [comments WC_rangeForRange:result.range];
                
                if (NSLocationInRange(result.range.location, commentRange))
                    return;
                
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Equate"];
                
                [fetchRequest setResultType:NSCountResultType];
                [fetchRequest setPredicate:[duplicatePredicate predicateWithSubstitutionVariables:@{@"LOCATION" : @(result.range.location)}]];
                
                NSArray *fetchResult = [weakSelf.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
                
                if ([fetchResult.lastObject unsignedIntegerValue] > 0)
                    return;
                
                fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Label"];
                
                [fetchRequest setPredicate:[labelPredicate predicateWithSubstitutionVariables:@{@"RANGE" : NSStringFromRange(result.range), @"NAME" : [weakSelf.string substringWithRange:result.range]}]];
                [fetchRequest setFetchLimit:1];
                
                Label *entity = [weakSelf.managedObjectContext executeFetchRequest:fetchRequest error:NULL].lastObject;
                
                if (entity) {
                    [oldSymbols removeObject:entity];
                }
                else {
                    entity = [NSEntityDescription insertNewObjectForEntityForName:@"Label" inManagedObjectContext:weakSelf.managedObjectContext];
                }
                
                [entity setType:@(SymbolTypeLabel)];
                [entity setLocation:@(result.range.location)];
                [entity setRange:NSStringFromRange(result.range)];
                [entity setName:[weakSelf.string substringWithRange:result.range]];
                [entity setLineNumber:@([weakSelf.string WC_lineNumberForRange:result.range])];
                [entity setFileContainer:fileContainer];
            }];
            
            if (weakSelf.isCancelled)
                break;
            
            NSPredicate *definePredicate = [NSPredicate predicateWithFormat:@"self.fileContainer == %@ AND self.range == $RANGE AND self.name ==[cd] $NAME",fileContainer];
            
            [[WCSyntaxHighlighter defineRegex] enumerateMatchesInString:weakSelf.string options:0 range:NSMakeRange(0, weakSelf.string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                NSRange commentRange = [comments WC_rangeForRange:result.range];
                
                if (NSLocationInRange(result.range.location, commentRange))
                    return;
                
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Define"];
                
                [fetchRequest setPredicate:[definePredicate predicateWithSubstitutionVariables:@{@"RANGE" : NSStringFromRange([result rangeAtIndex:1]), @"NAME" : [weakSelf.string substringWithRange:[result rangeAtIndex:1]]}]];
                [fetchRequest setFetchLimit:1];
                
                Define *entity = [weakSelf.managedObjectContext executeFetchRequest:fetchRequest error:NULL].lastObject;
                
                if (entity) {
                    [oldSymbols removeObject:entity];
                }
                else {
                    entity = [NSEntityDescription insertNewObjectForEntityForName:@"Define" inManagedObjectContext:weakSelf.managedObjectContext];
                }
                
                [entity setType:@(SymbolTypeDefine)];
                [entity setLocation:@(result.range.location)];
                [entity setRange:NSStringFromRange([result rangeAtIndex:1])];
                [entity setName:[weakSelf.string substringWithRange:[result rangeAtIndex:1]]];
                [entity setLineNumber:@([weakSelf.string WC_lineNumberForRange:result.range])];
                [entity setFileContainer:fileContainer];
                
                [[WCSyntaxHighlighter expandedDefineRegex] enumerateMatchesInString:weakSelf.string options:0 range:[weakSelf.string lineRangeForRange:result.range] usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                    NSRange argumentsRange = [result rangeAtIndex:2];
                    
                    if (argumentsRange.length > 0)
                        [entity setArguments:[weakSelf.string substringWithRange:NSMakeRange(argumentsRange.location + 1, argumentsRange.length - 2)]];
                    
                    [entity setValue:[[weakSelf.string substringWithRange:[result rangeAtIndex:3]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                    
                    *stop = YES;
                }];
            }];
            
            if (weakSelf.isCancelled)
                break;
            
            NSPredicate *macroPredicate = [NSPredicate predicateWithFormat:@"self.fileContainer == %@ AND self.range == $RANGE AND self.name ==[cd] $NAME",fileContainer];
            
            [[WCSyntaxHighlighter macroRegex] enumerateMatchesInString:weakSelf.string options:0 range:NSMakeRange(0, weakSelf.string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                NSRange commentRange = [comments WC_rangeForRange:result.range];
                
                if (NSLocationInRange(result.range.location, commentRange))
                    return;
               
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Macro"];
                
                [fetchRequest setPredicate:[macroPredicate predicateWithSubstitutionVariables:@{@"RANGE" : NSStringFromRange([result rangeAtIndex:1]), @"NAME" : [weakSelf.string substringWithRange:[result rangeAtIndex:1]]}]];
                [fetchRequest setFetchLimit:1];
                
                Macro *entity = [weakSelf.managedObjectContext executeFetchRequest:fetchRequest error:NULL].lastObject;
                
                if (entity) {
                    [oldSymbols removeObject:entity];
                }
                else {
                    entity = [NSEntityDescription insertNewObjectForEntityForName:@"Macro" inManagedObjectContext:weakSelf.managedObjectContext];
                }
                
                [entity setType:@(SymbolTypeMacro)];
                [entity setLocation:@(result.range.location)];
                [entity setRange:NSStringFromRange([result rangeAtIndex:1])];
                [entity setName:[weakSelf.string substringWithRange:[result rangeAtIndex:1]]];
                [entity setLineNumber:@([weakSelf.string WC_lineNumberForRange:result.range])];
                [entity setFileContainer:fileContainer];
                
                [[WCSyntaxHighlighter expandedMacroRegex] enumerateMatchesInString:weakSelf.string options:0 range:NSMakeRange(result.range.location, weakSelf.string.length - result.range.location) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                    NSRange argumentsRange = [result rangeAtIndex:2];
                    
                    if (argumentsRange.length > 0)
                        [entity setArguments:[weakSelf.string substringWithRange:NSMakeRange(argumentsRange.location + 1, argumentsRange.length - 2)]];

                    [entity setValue:[[weakSelf.string substringWithRange:[result rangeAtIndex:3]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                    
                    *stop = YES;
                }];
            }];
            
            if (weakSelf.isCancelled)
                break;
            
            NSPredicate *calledPredicate = [NSPredicate predicateWithFormat:@"self.isCalled == NO AND self.name ==[cd] $NAME"];
            NSMutableSet *calledLabelNames = [NSMutableSet setWithCapacity:0];
            
            [[WCSymbolScanner calledLabelRegex] enumerateMatchesInString:weakSelf.string options:0 range:NSMakeRange(0, weakSelf.string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                NSRange commentRange = [comments WC_rangeForRange:result.range];
                
                if (NSLocationInRange(result.range.location, commentRange))
                    return;
                
                NSString *labelName = [[weakSelf.string substringWithRange:[result rangeAtIndex:1]] lowercaseString];
                
                CalledLabel *entity = [NSEntityDescription insertNewObjectForEntityForName:@"CalledLabel" inManagedObjectContext:weakSelf.managedObjectContext];
                
                [entity setLocation:@(result.range.location)];
                [entity setRange:NSStringFromRange(result.range)];
                [entity setName:[weakSelf.string substringWithRange:result.range]];
                [entity setLineNumber:@([weakSelf.string WC_lineNumberForRange:result.range])];
                [entity setLabelName:labelName];
                [entity setFileContainer:fileContainer];
                
                if (![calledLabelNames containsObject:labelName]) {
                    [calledLabelNames addObject:labelName];
                    
                    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Label"];
                    
                    [fetchRequest setPredicate:[calledPredicate predicateWithSubstitutionVariables:@{@"NAME" : labelName}]];
                    
                    for (Label *label in [weakSelf.managedObjectContext executeFetchRequest:fetchRequest error:NULL])
                        [label setIsCalled:@true];
                }
            }];
            
            [[WCSymbolScanner calledLabelWithConditionalRegisterRegex] enumerateMatchesInString:weakSelf.string options:0 range:NSMakeRange(0, weakSelf.string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                NSRange commentRange = [comments WC_rangeForRange:result.range];
                
                if (NSLocationInRange(result.range.location, commentRange))
                    return;
                
                NSString *labelName = [[weakSelf.string substringWithRange:[result rangeAtIndex:1]] lowercaseString];
                
                CalledLabel *entity = [NSEntityDescription insertNewObjectForEntityForName:@"CalledLabel" inManagedObjectContext:weakSelf.managedObjectContext];
                
                [entity setLocation:@(result.range.location)];
                [entity setRange:NSStringFromRange(result.range)];
                [entity setName:[weakSelf.string substringWithRange:result.range]];
                [entity setLineNumber:@([weakSelf.string WC_lineNumberForRange:result.range])];
                [entity setLabelName:labelName];
                [entity setFileContainer:fileContainer];
                
                if (![calledLabelNames containsObject:labelName]) {
                    [calledLabelNames addObject:labelName];
                    
                    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Label"];
                    
                    [fetchRequest setPredicate:[calledPredicate predicateWithSubstitutionVariables:@{@"NAME" : labelName}]];
                    
                    for (Label *label in [weakSelf.managedObjectContext executeFetchRequest:fetchRequest error:NULL])
                        [label setIsCalled:@true];
                }
            }];
            
        } while (0);
        
        if (!weakSelf.isCancelled) {
            for (Symbol *symbol in oldSymbols)
                [weakSelf.managedObjectContext deleteObject:symbol];
            
            if ([weakSelf.managedObjectContext save:NULL]) {
                __weak NSManagedObjectContext *parentContext = weakSelf.managedObjectContext.parentContext;
                
                while (parentContext) {
                    [parentContext performBlockAndWait:^{
                        [parentContext save:NULL];
                    }];
                    
                    parentContext = parentContext.parentContext;
                }
            }
        }
        
        [weakSelf willChangeValueForKey:@"isExecuting"];
        [weakSelf willChangeValueForKey:@"isFinished"];
        [weakSelf setExecuting:NO];
        [weakSelf setFinished:YES];
        [weakSelf didChangeValueForKey:@"isExecuting"];
        [weakSelf didChangeValueForKey:@"isFinished"];
    }];
}

@end
