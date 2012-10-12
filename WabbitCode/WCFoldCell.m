//
//  WCFoldCell.m
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

#import "WCFoldCell.h"
#import "NSBezierPath+StrokeExtensions.h"
#import "WCSyntaxHighlighter.h"
#import "WCDefines.h"
#import "WCTextView.h"

static const CGFloat kLeftRightMargin = 2;

static NSTextStorage *kTextStorage;
static NSLayoutManager *kLayoutManager;
static NSTextContainer *kTextContainer;

@implementation WCFoldCell

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kTextStorage = [[NSTextStorage alloc] initWithString:@""];
        kLayoutManager = [[NSLayoutManager alloc] init];
        
        [kLayoutManager setAllowsNonContiguousLayout:NO];
        [kLayoutManager setBackgroundLayoutEnabled:YES];
        
        kTextContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
        
        [kLayoutManager addTextContainer:kTextContainer];
        [kTextStorage addLayoutManager:kLayoutManager];
    });
}

- (id)initTextCell:(NSString *)aString {
    if (!(self = [super initTextCell:NSLocalizedString(@"\u2219\u2219\u2219", nil)]))
        return nil;
    
    return self;
}

- (BOOL)wantsToTrackMouseForEvent:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView atCharacterIndex:(NSUInteger)charIndex {
    return NSPointInRect([controlView convertPoint:theEvent.locationInWindow fromView:nil], cellFrame);
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView atCharacterIndex:(NSUInteger)charIndex untilMouseUp:(BOOL)flag {
    if ([controlView respondsToSelector:@selector(unfoldAction:)]) {
        [(NSTextView *)controlView setSelectedRange:NSMakeRange(charIndex, 1)];
        [(WCTextView *)controlView unfoldAction:nil];
    }
    return NO;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView characterIndex:(NSUInteger)charIndex layoutManager:(NSLayoutManager *)layoutManager {
//    BOOL isSelected = NSLocationInRange(charIndex, layoutManager.firstTextView.selectedRange);
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(cellFrame, kLeftRightMargin, 1) xRadius:5 yRadius:5];
    
    [[NSColor colorWithCalibratedRed:247.0/255.0 green:245.0/255.0 blue:196.0/255.0 alpha:1.0] setFill];
	[path fill];
	[[NSColor colorWithCalibratedRed:167.0/255.0 green:164.0/255.0 blue:60.0/255.0 alpha:1.0] setStroke];
	[path stroke];
    
    [kLayoutManager drawGlyphsForGlyphRange:[kLayoutManager glyphRangeForTextContainer:kTextContainer] atPoint:NSMakePoint(NSMinX(cellFrame) + kLeftRightMargin, NSMinY(cellFrame))];
}

- (NSRect)cellFrameForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(NSRect)lineFrag glyphPosition:(NSPoint)position characterIndex:(NSUInteger)charIndex {
    NSRect frame = [super cellFrameForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
    NSMutableDictionary *attributes = [[WCSyntaxHighlighter defaultAttributes] mutableCopy];
    
    [attributes setObject:[NSColor colorWithCalibratedRed:167.0/255.0 green:164.0/255.0 blue:60.0/255.0 alpha:1.0] forKey:NSForegroundColorAttributeName];
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:self.stringValue attributes:attributes];
    
    [self setAttributedStringValue:string];
    
    [kTextStorage replaceCharactersInRange:NSMakeRange(0, kTextStorage.length) withAttributedString:string];
    [kLayoutManager ensureLayoutForTextContainer:kTextContainer];
    
    NSRect rect = [kLayoutManager usedRectForTextContainer:kTextContainer];
    
    frame.size.width = NSWidth(rect) + (kLeftRightMargin * 2);
    frame.size.height = NSHeight(lineFrag);
    frame.origin.y -= [textContainer.layoutManager.typesetter baselineOffsetInLayoutManager:kLayoutManager glyphIndex:0];
    
    return frame;
}

@end
