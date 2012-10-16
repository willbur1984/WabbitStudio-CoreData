//
//  WCCompletionItem.m
//  WabbitStudio
//
//  Created by William Towe on 9/24/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCCompletionItem.h"
#import "WCSyntaxHighlighter.h"
#import "Symbol.h"
#import "Completion.h"

@interface WCCompletionItem ()
@property (readwrite,strong,nonatomic) id <WCCompletionItemDataSource> dataSource;
@property (readwrite,copy,nonatomic) NSAttributedString *displayString;
@end

@implementation WCCompletionItem

- (id)initWithDataSource:(id<WCCompletionItemDataSource>)dataSource; {
    if (!(self = [super init]))
        return nil;
    
    [self setDataSource:dataSource];
    
    NSDictionary *defaultAttributes = [WCSyntaxHighlighter defaultAttributes];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[self.dataSource name] attributes:defaultAttributes];
    
    if ([self.dataSource respondsToSelector:@selector(arguments)]) {
        NSArray *arguments = [[self.dataSource arguments] componentsSeparatedByString:@","];
        
        if (arguments.count) {
            NSMutableArray *temp = [NSMutableArray arrayWithCapacity:arguments.count];
            
            for (NSString *argument in arguments)
                [temp addObject:[argument stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            
            [string.mutableString appendFormat:@"(%@)",[temp componentsJoinedByString:@","]];
        }
    }
    
    if ([self.dataSource respondsToSelector:@selector(lineNumber)]) {
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@" \u2192 %@:%ld", nil),[self.dataSource path].lastPathComponent,[self.dataSource lineNumber].integerValue + 1] attributes:@{ NSFontAttributeName : [defaultAttributes objectForKey:NSFontAttributeName], NSForegroundColorAttributeName : [NSColor lightGrayColor]}]];
    }
    
    [self setDisplayString:string];
    
    return self;
}

@end
