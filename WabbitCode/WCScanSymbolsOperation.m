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
#import "WCDefines.h"
#import "Label.h"
#import "Equate.h"
#import "Define.h"
#import "Macro.h"
#import "File.h"

@interface WCScanSymbolsOperation ()
@property (copy,nonatomic) NSString *string;
@property (strong) NSManagedObjectContext *managedObjectContext;
@property (assign,getter = isExecuting) BOOL executing;
@property (assign,getter = isFinished) BOOL finished;
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
        File *file = [NSEntityDescription insertNewObjectForEntityForName:@"File" inManagedObjectContext:self.managedObjectContext];
        
        [file setIdentifier:[NSString WC_UUIDString]];
        [file setPath:self.fileURL.path];
        
        [[WCSyntaxHighlighter equateRegex] enumerateMatchesInString:self.string options:0 range:NSMakeRange(0, self.string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            Equate *entity = [NSEntityDescription insertNewObjectForEntityForName:@"Equate" inManagedObjectContext:self.managedObjectContext];
            
            [entity setType:@(SymbolTypeEquate)];
            [entity setLocation:@(result.range.location)];
            [entity setRange:NSStringFromRange([result rangeAtIndex:1])];
            [entity setName:[self.string substringWithRange:[result rangeAtIndex:1]]];
            [entity setLineNumber:@([self.string WC_lineNumberForRange:result.range])];
            [entity setFile:file];
        }];
        
        [[WCSyntaxHighlighter labelRegex] enumerateMatchesInString:self.string options:0 range:NSMakeRange(0, self.string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            if (result.range.length == 1 &&
                [self.string characterAtIndex:result.range.location] == '_')
                return;
            
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Equate"];
            
            [fetchRequest setResultType:NSCountResultType];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.location == %lu",result.range.location]];
            
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
        
        [[WCSyntaxHighlighter defineRegex] enumerateMatchesInString:self.string options:0 range:NSMakeRange(0, self.string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            Define *entity = [NSEntityDescription insertNewObjectForEntityForName:@"Define" inManagedObjectContext:self.managedObjectContext];
            
            [entity setType:@(SymbolTypeDefine)];
            [entity setLocation:@(result.range.location)];
            [entity setRange:NSStringFromRange([result rangeAtIndex:1])];
            [entity setName:[self.string substringWithRange:[result rangeAtIndex:1]]];
            [entity setLineNumber:@([self.string WC_lineNumberForRange:result.range])];
            [entity setFile:file];
        }];
        
        [[WCSyntaxHighlighter macroRegex] enumerateMatchesInString:self.string options:0 range:NSMakeRange(0, self.string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            Macro *entity = [NSEntityDescription insertNewObjectForEntityForName:@"Macro" inManagedObjectContext:self.managedObjectContext];
            
            [entity setType:@(SymbolTypeMacro)];
            [entity setLocation:@(result.range.location)];
            [entity setRange:NSStringFromRange([result rangeAtIndex:1])];
            [entity setName:[self.string substringWithRange:[result rangeAtIndex:1]]];
            [entity setLineNumber:@([self.string WC_lineNumberForRange:result.range])];
            [entity setFile:file];
            
            NSRange lineRange = [self.string lineRangeForRange:result.range];
            NSRange parensRange = NSMakeRange(NSMaxRange(result.range), NSMaxRange(lineRange) - NSMaxRange(result.range));
            NSString *parensString = [self.string substringWithRange:parensRange];
            NSTextCheckingResult *parensResult = [[NSRegularExpression regularExpressionWithPattern:@"^\\((.+?)\\)" options:0 error:NULL] firstMatchInString:parensString options:0 range:NSMakeRange(0, parensRange.length)];
            
            if (parensResult)
                [entity setArguments:[parensString substringWithRange:[parensResult rangeAtIndex:1]]];
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
