//
//  WCTableView.m
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

#import "WCTableView.h"
#import "WCGeometry.h"
#import "WCDefines.h"

@implementation WCTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if (self.numberOfRows == 0 && self.emptyAttributedString.length) {
        static NSTextStorage *textStorage;
        static NSLayoutManager *layoutManager;
        static NSTextContainer *textContainer;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            textStorage = [[NSTextStorage alloc] init];
            layoutManager = [[NSLayoutManager alloc] init];
            
            [textStorage addLayoutManager:layoutManager];
            
            textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
            
            [layoutManager addTextContainer:textContainer];
        });
        
        [textStorage replaceCharactersInRange:NSMakeRange(0, textStorage.length) withAttributedString:self.emptyAttributedString];
        [layoutManager ensureLayoutForTextContainer:textContainer];
        
        NSRect drawRect = [layoutManager usedRectForTextContainer:textContainer];
        NSRect centerRect = WC_NSRectCenter(drawRect, self.bounds);
        
        [layoutManager drawGlyphsForGlyphRange:[layoutManager glyphRangeForTextContainer:textContainer] atPoint:centerRect.origin];
    }
}

- (NSString *)emptyString {
    return self.emptyAttributedString.string;
}
- (void)setEmptyString:(NSString *)emptyString {
    [self setEmptyAttributedString:[[NSAttributedString alloc] initWithString:emptyString]];
}

- (void)setEmptyAttributedString:(NSAttributedString *)emptyAttributedString {
    _emptyAttributedString = emptyAttributedString;
    
    [self setNeedsDisplay:YES];
}

@end
