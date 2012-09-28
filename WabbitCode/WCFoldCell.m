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

static const CGFloat kLeftRightMargin = 2;

@implementation WCFoldCell

- (id)initTextCell:(NSString *)aString {
    if (!(self = [super initTextCell:NSLocalizedString(@"...", nil)]))
        return nil;
    
    return self;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView characterIndex:(NSUInteger)charIndex layoutManager:(NSLayoutManager *)layoutManager {
//    BOOL isSelected = NSLocationInRange(charIndex, layoutManager.firstTextView.selectedRange);
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(cellFrame, 0, 1) xRadius:5 yRadius:5];
    
    [[NSColor colorWithCalibratedRed:247.0/255.0 green:245.0/255.0 blue:196.0/255.0 alpha:1.0] setFill];
	[path fill];
	[[NSColor colorWithCalibratedRed:167.0/255.0 green:164.0/255.0 blue:60.0/255.0 alpha:1.0] setStroke];
	[path strokeInside];
    
    [self.attributedStringValue drawInRect:NSInsetRect(cellFrame, kLeftRightMargin, 0)];
}

- (NSRect)cellFrameForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(NSRect)lineFrag glyphPosition:(NSPoint)position characterIndex:(NSUInteger)charIndex {
    NSRect frame = [super cellFrameForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:self.stringValue attributes:textContainer.textView.typingAttributes];
    
    [self setAttributedStringValue:string];
    
    frame.size.width = string.size.width + (kLeftRightMargin * 2);
    frame.size.height = NSHeight(lineFrag);
    frame.origin.y -= [textContainer.layoutManager.typesetter baselineOffsetInLayoutManager:textContainer.layoutManager glyphIndex:[textContainer.layoutManager glyphIndexForCharacterAtIndex:0]];
    
    return frame;
}

@end
