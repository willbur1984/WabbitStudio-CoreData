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
#import "NSShadow+MCAdditions.h"
#import "NSBezierPath+MCAdditions.h"

@implementation WCTableView

- (void)drawBackgroundInClipRect:(NSRect)clipRect {
    [super drawBackgroundInClipRect:clipRect];
    
    if (self.numberOfRows == 0 && self.emptyAttributedString.length > 0) {
        static NSTextStorage *kTextStorage;
        static NSLayoutManager *kLayoutManager;
        static NSTextContainer *kTextContainer;
        static NSShadow *kDropShadow;
        static NSShadow *kInnerShadow;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            kDropShadow = [[NSShadow alloc] initWithColor:[NSColor colorWithCalibratedWhite:1.0 alpha:1.0] offset:NSMakeSize(0, -1.0) blurRadius:1.0];
            kInnerShadow = [[NSShadow alloc] initWithColor:[NSColor colorWithCalibratedWhite:141.0/255.0 alpha:1.0] offset:NSMakeSize(0.0, -1.0) blurRadius:1.0];
            
            kTextStorage = [[NSTextStorage alloc] init];
            kLayoutManager = [[NSLayoutManager alloc] init];
            
            [kTextStorage addLayoutManager:kLayoutManager];
            
            kTextContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
            
            [kLayoutManager addTextContainer:kTextContainer];
        });
        
        [kTextStorage replaceCharactersInRange:NSMakeRange(0, kTextStorage.length) withAttributedString:self.emptyAttributedString];
        [kLayoutManager ensureLayoutForTextContainer:kTextContainer];
        
        NSRect drawRect = [kLayoutManager usedRectForTextContainer:kTextContainer];
        NSRect centerRect = WC_NSRectCenter(drawRect, self.bounds);
        NSRect borderRect = NSInsetRect(centerRect, -5, -5);
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:borderRect xRadius:5 yRadius:5];
        
        [NSGraphicsContext saveGraphicsState];
		[kDropShadow set];
		
		[[NSColor colorWithCalibratedWhite:151.0/255.0 alpha:1.0] setFill];
		[path fill];
		[NSGraphicsContext restoreGraphicsState];
		
		[path fillWithInnerShadow:kInnerShadow];
        
        [kLayoutManager drawGlyphsForGlyphRange:[kLayoutManager glyphRangeForTextContainer:kTextContainer] atPoint:centerRect.origin];
    }
}

- (BOOL)preservesContentDuringLiveResize {
    return NO;
}

- (NSString *)emptyString {
    return self.emptyAttributedString.string;
}
- (void)setEmptyString:(NSString *)emptyString {
    NSDictionary *attributes = @{NSFontAttributeName : [NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]], NSForegroundColorAttributeName : [NSColor whiteColor]};
    
    [self setEmptyAttributedString:[[NSAttributedString alloc] initWithString:emptyString attributes:attributes]];
}

- (void)setEmptyAttributedString:(NSAttributedString *)emptyAttributedString {
    _emptyAttributedString = emptyAttributedString;
    
    [self setNeedsDisplay:YES];
}

@end
