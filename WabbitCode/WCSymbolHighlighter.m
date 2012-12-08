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
#import "NSTextView+WCExtensions.h"
#import "WCTextStorage.h"
#import "WCSymbolIndex.h"
#import "Label.h"

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidProcessEditing:) name:NSTextStorageDidProcessEditingNotification object:self.textStorage];
    
    return self;
}

- (void)symbolHighlightInVisibleRange; {
    NSMutableIndexSet *ranges = [NSMutableIndexSet indexSet];
    
    for (NSLayoutManager *layoutManager in self.textStorage.layoutManagers) {
        for (NSTextContainer *textContainer in layoutManager.textContainers) {
            if (!textContainer.textView.isHidden)
                [ranges addIndexesInRange:[textContainer.textView WC_visibleRange]];
        }
    }
    
    [ranges enumerateRangesWithOptions:0 usingBlock:^(NSRange range, BOOL *stop) {
        [self symbolHighlightInRange:range];
    }];
}
- (void)symbolHighlightInRange:(NSRange)range; {
    if (!range.length)
        return;
    
    id <WCSymbolsProvider> symbolsProvider = [self.delegate symbolsProviderForSymbolHighlighter:self];
    
    [self.textStorage beginEditing];
    
    NSRange foldRange;
    id value;
    
    while (range.length) {
        [(WCTextStorage *)self.textStorage setFolding:YES];
        value = [self.textStorage attribute:WCTextStorageFoldAttributeName atIndex:range.location longestEffectiveRange:&foldRange inRange:range];
        [(WCTextStorage *)self.textStorage setFolding:NO];
        
        if (![value boolValue]) {
            NSRange highlightRange = foldRange;
            NSRange symbolRange;
            
            while (highlightRange.length) {
                if ((value = [self.textStorage attribute:kSymbolAttributeName atIndex:highlightRange.location longestEffectiveRange:&symbolRange inRange:highlightRange])) {
                    NSString *name = [self.textStorage.string substringWithRange:symbolRange];                    
                    NSArray *symbols = [symbolsProvider symbolsWithName:name];
                    Symbol *symbol = [symbols WC_firstObject];
                    
                    switch (symbol.type.intValue) {
                        case SymbolTypeLabel:
                            [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0 alpha:1] range:symbolRange];
                            
                            if ([(Label *)symbol isCalledValue])
                                [self.textStorage addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle|NSUnderlinePatternSolid) range:symbolRange];
                            break;
                        case SymbolTypeEquate:
                            [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedRed:0 green:0.5 blue:0.5 alpha:1] range:symbolRange];
                            break;
                        case SymbolTypeDefine:
                            [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor brownColor] range:symbolRange];
                            break;
                        case SymbolTypeMacro:
                            [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedRed:1 green:0.4 blue:0.4 alpha:1] range:symbolRange];
                            break;
                        default:
                            [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor] range:symbolRange];
                            [self.textStorage removeAttribute:NSUnderlineStyleAttributeName range:symbolRange];
                            break;
                    }
                }
                
                highlightRange = NSMakeRange(NSMaxRange(symbolRange), NSMaxRange(highlightRange) - NSMaxRange(symbolRange));
            }
        }
        
        range = NSMakeRange(NSMaxRange(foldRange), NSMaxRange(range) - NSMaxRange(foldRange));
    }
    
    [self.textStorage endEditing];
}

- (void)_textStorageDidProcessEditing:(NSNotification *)note {
    if (!([note.object editedMask] & NSTextStorageEditedCharacters))
        return;
    
    [self performSelector:@selector(symbolHighlightInVisibleRange) withObject:nil afterDelay:0];
}

@end
