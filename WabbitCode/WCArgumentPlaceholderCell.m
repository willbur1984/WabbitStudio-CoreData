//
//  WCArgumentPlaceholderCell.m
//  WabbitStudio
//
//  Created by William Towe on 9/23/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCArgumentPlaceholderCell.h"
#import "NSBezierPath+StrokeExtensions.h"
#import "WCSyntaxHighlighter.h"

static const CGFloat kLeftRightMargin = 1;

static NSTextStorage *kTextStorage;
static NSLayoutManager *kLayoutManager;
static NSTextContainer *kTextContainer;

@interface WCArgumentPlaceholderCell ()
@property (copy,nonatomic) NSString *name;
@property (strong,nonatomic) NSArray *arguments;
@end

@implementation WCArgumentPlaceholderCell

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

- (id)initTextCell:(NSString *)aString arguments:(NSString *)arguments; {
    if (!(self = [super initTextCell:aString]))
        return nil;
    
    [self setName:aString];
    [self setArguments:[arguments componentsSeparatedByString:@","]];
    
    return self;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView characterIndex:(NSUInteger)charIndex layoutManager:(NSLayoutManager *)layoutManager {
    static NSColor *kFillColor, *kSelectedFillColor, *kStrokeColor, *kSelectedStrokeColor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kFillColor = [NSColor colorWithCalibratedRed:0.871 green:0.906 blue:0.973 alpha:1.0];
        kSelectedFillColor = [NSColor colorWithCalibratedRed:131.0/255.0 green:166.0/255.0 blue:239.0/255.0 alpha:1.0];
        kStrokeColor = [NSColor colorWithCalibratedRed:0.643 green:0.741 blue:0.925 alpha:1.0];
        kSelectedStrokeColor = [NSColor colorWithCalibratedRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0];
    });
    
    BOOL isSelected = NSLocationInRange(charIndex, layoutManager.firstTextView.selectedRange);
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(cellFrame, 0, 1) xRadius:5 yRadius:5];
    
    if (isSelected)
        [kSelectedFillColor setFill];
    else
        [kFillColor setFill];
    [path fill];
    
    if (isSelected)
        [kSelectedStrokeColor setStroke];
    else
        [kStrokeColor setStroke];
    [path stroke];
    
    [kTextStorage replaceCharactersInRange:NSMakeRange(0, kTextStorage.length) withAttributedString:self.attributedStringValue];
    
    if (isSelected)
        [kTextStorage addAttribute:NSForegroundColorAttributeName value:[NSColor alternateSelectedControlTextColor] range:NSMakeRange(0, kTextStorage.length)];
    
    [kLayoutManager ensureLayoutForTextContainer:kTextContainer];
    [kLayoutManager drawGlyphsForGlyphRange:[kLayoutManager glyphRangeForTextContainer:kTextContainer] atPoint:NSMakePoint(NSMinX(cellFrame) + kLeftRightMargin, NSMinY(cellFrame))];
}

- (NSRect)cellFrameForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(NSRect)lineFrag glyphPosition:(NSPoint)position characterIndex:(NSUInteger)charIndex {
    NSRect frame = [super cellFrameForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:self.name attributes:[WCSyntaxHighlighter defaultAttributes]];
    
    if (self.arguments.count > 0)
        [string.mutableString appendString:@"\u25BC"];
    
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
