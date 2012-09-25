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
#import "Macro.h"
#import "File.h"

@interface WCCompletionItem ()
@property (readwrite,strong,nonatomic) Symbol *symbol;
@property (readwrite,copy,nonatomic) NSAttributedString *displayString;
@end

@implementation WCCompletionItem

- (id)initWithSymbol:(Symbol *)symbol; {
    if (!(self = [super init]))
        return nil;
    
    [self setSymbol:symbol];
    
    NSDictionary *defaultAttributes = [WCSyntaxHighlighter defaultAttributes];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:symbol.name attributes:defaultAttributes];
    
    if (symbol.type.intValue == SymbolTypeMacro) {
        Macro *macro = (Macro *)symbol;
        NSArray *arguments = [macro.arguments componentsSeparatedByString:@","];
        
        if (arguments.count) {
            NSMutableString *argumentString = [NSMutableString stringWithCapacity:0];
            
            [arguments enumerateObjectsUsingBlock:^(NSString *argument, NSUInteger argumentIndex, BOOL *stop) {
                if (argumentIndex == 0)
                    [argumentString appendString:@"("];
                
                [argumentString appendString:[argument stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                
                if (argumentIndex == arguments.count - 1)
                    [argumentString appendString:@")"];
                else
                    [argumentString appendString:@","];
            }];
            
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:argumentString attributes:defaultAttributes]];
        }
    }
    
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@" \u2192 %@:%ld", nil),symbol.file.path.lastPathComponent,symbol.lineNumber.integerValue + 1] attributes:@{ NSFontAttributeName : [defaultAttributes objectForKey:NSFontAttributeName], NSForegroundColorAttributeName : [NSColor lightGrayColor]}]];
    
    [self setDisplayString:string];
    
    return self;
}

@end
