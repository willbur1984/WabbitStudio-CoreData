//
//  WCSymbolHighlighter.m
//  WabbitStudio
//
//  Created by William Towe on 9/30/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCSymbolHighlighter.h"
#import "WCSyntaxHighlighter.h"
#import "WCSymbolScanner.h"
#import "NSArray+WCExtensions.h"
#import "WCDefines.h"

@interface WCSymbolHighlighter ()
@property (weak,nonatomic) NSTextStorage *textStorage;
@end

@implementation WCSymbolHighlighter

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithTextStorage:(NSTextStorage *)textStorage; {
    if (!(self = [super init]))
        return nil;
    
    [self setTextStorage:textStorage];
    
    return self;
}

- (void)symbolHighlightInRange:(NSRange)range; {
    if (!range.length)
        return;
    
    WCSymbolScanner *symbolScanner = [self.delegate symbolScannerForSymbolHighlighter:self];
    
    [self.textStorage beginEditing];
    
    [[WCSymbolScanner symbolRegex] enumerateMatchesInString:self.textStorage.string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        id attribute = [self.textStorage attribute:kTokenAttributeName atIndex:result.range.location effectiveRange:NULL];
        
        if ([attribute boolValue])
            return;
        
        NSArray *symbols = [symbolScanner symbolsWithName:[self.textStorage.string substringWithRange:result.range]];
        
        if (!symbols.count) {
            [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor] range:result.range];
            return;
        }
        
        Symbol *symbol = [symbols WC_firstObject];
        
        switch (symbol.type.intValue) {
            case SymbolTypeLabel:
                [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0 alpha:1] range:result.range];
                break;
            case SymbolTypeEquate:
                [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedRed:0 green:0.5 blue:0.5 alpha:1] range:result.range];
                break;
            case SymbolTypeDefine:
                [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor brownColor] range:result.range];
                break;
            case SymbolTypeMacro:
                [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedRed:1 green:0.4 blue:0.4 alpha:1] range:result.range];
                break;
            default:
                [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor] range:result.range];
                break;
        }
    }];
    
    [self.textStorage endEditing];
}

@end
