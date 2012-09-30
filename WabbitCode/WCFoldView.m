//
//  WCFoldView.m
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

#import "WCFoldView.h"
#import "WCFoldScanner.h"
#import "Fold.h"
#import "NSColor+WCExtensions.h"
#import "NSTextView+WCExtensions.h"
#import "WCGeometry.h"

static const CGFloat kFoldViewWidth = 7;

@interface WCFoldView ()
@property (strong,nonatomic) NSTrackingArea *foldTrackingRect;
@property (strong,nonatomic) Fold *foldToHighlight;

- (NSColor *)_colorForFold:(Fold *)fold;
@end

@implementation WCFoldView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    NSUInteger lineNumber = [self lineNumberForPoint:[self convertPoint:theEvent.locationInWindow fromView:nil]];
    
    if (lineNumber == NSNotFound)
        return;
    
    NSUInteger lineStartIndex = [[self.lineStartIndexes objectAtIndex:lineNumber] unsignedIntegerValue];
    Fold *fold = [[self.delegate foldScannerForFoldView:self] deepestFoldForRange:NSMakeRange(lineStartIndex, 0)];
    
    [self setFoldToHighlight:fold];
}
- (void)mouseExited:(NSEvent *)theEvent {
    [self setFoldToHighlight:nil];
}
- (void)mouseMoved:(NSEvent *)theEvent {
    NSUInteger lineNumber = [self lineNumberForPoint:[self convertPoint:theEvent.locationInWindow fromView:nil]];
    
    if (lineNumber == NSNotFound)
        return;
    
    NSUInteger lineStartIndex = [[self.lineStartIndexes objectAtIndex:lineNumber] unsignedIntegerValue];
    Fold *fold = [[self.delegate foldScannerForFoldView:self] deepestFoldForRange:NSMakeRange(lineStartIndex, 0)];
    
    [self setFoldToHighlight:fold];
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    
    [self removeTrackingArea:self.foldTrackingRect];
    
    NSView *contentView = self.window.contentView;
    BOOL assumeInside = ([contentView hitTest:[contentView convertPoint:[contentView.window convertScreenToBase:[NSEvent mouseLocation]] fromView:nil]] == self);
    NSTrackingAreaOptions options = NSTrackingActiveInKeyWindow|NSTrackingMouseMoved|NSTrackingMouseEnteredAndExited;
    
    if (assumeInside)
        options |= NSTrackingAssumeInside;
    
    [self setFoldTrackingRect:[[NSTrackingArea alloc] initWithRect:NSMakeRect(NSMaxX(self.frame) - kFoldViewWidth, 0, kFoldViewWidth, NSHeight(self.frame)) options:options owner:self userInfo:nil]];
    [self addTrackingArea:self.foldTrackingRect];
}

- (CGFloat)requiredThickness {
    return [super requiredThickness] + kFoldViewWidth;
}

- (void)drawHashMarksAndLabelsInRect:(NSRect)rect {
    [super drawBackgroundAndDividerLineInRect:NSMakeRect(NSMinX(self.frame), 0, NSWidth(self.frame) - kFoldViewWidth, NSHeight(self.frame))];
    [super drawLineNumbersInRect:NSMakeRect(NSMinX(self.frame), 0, NSWidth(self.frame) - kFoldViewWidth, NSHeight(self.frame))];
    [self drawFoldsInRect:NSMakeRect(NSMaxX(self.frame) - kFoldViewWidth, 0, kFoldViewWidth, NSHeight(self.frame))];
}

- (void)drawFoldsInRect:(NSRect)rect; {
    [[NSColor WC_colorWithHexadecimalString:@"ededed"] setFill];
    NSRectFill(rect);
    
    NSArray *folds = [[self.delegate foldScannerForFoldView:self] foldsForRange:[self.textView WC_visibleRange]];
    
    for (Fold *fold in folds) {
        NSRange range = NSRangeFromString(fold.range);
        NSUInteger numberOfLineRects;
        NSRectArray lineRects = [self.textView.layoutManager rectArrayForCharacterRange:range withinSelectedCharacterRange:WC_NSNotFoundRange inTextContainer:self.textView.textContainer rectCount:&numberOfLineRects];
        
        if (!numberOfLineRects)
            continue;
        
        NSRect lineRect = lineRects[0];
        
        if (numberOfLineRects > 1) {
            if (numberOfLineRects > 1) {
                NSUInteger rectIndex;
                
                for (rectIndex=1; rectIndex<numberOfLineRects; rectIndex++)
                    lineRect = NSUnionRect(lineRect, lineRects[rectIndex]);
            }
        }
        
        NSRect foldRect = NSMakeRect(NSMinX(rect), [self convertPoint:lineRect.origin fromView:self.clientView].y, kFoldViewWidth, NSHeight(lineRect));
        NSColor *foldColor = [self _colorForFold:fold];
        
        [foldColor setFill];
        NSRectFill(foldRect);
    }
    
    if (self.foldToHighlight) {
        NSRange range = NSRangeFromString(self.foldToHighlight.range);
        NSUInteger numberOfLineRects;
        NSRectArray lineRects = [self.textView.layoutManager rectArrayForCharacterRange:range withinSelectedCharacterRange:WC_NSNotFoundRange inTextContainer:self.textView.textContainer rectCount:&numberOfLineRects];
        
        if (!numberOfLineRects)
            return;
        
        NSRect lineRect = lineRects[0];
        
        if (numberOfLineRects > 1) {
            if (numberOfLineRects > 1) {
                NSUInteger rectIndex;
                
                for (rectIndex=1; rectIndex<numberOfLineRects; rectIndex++)
                    lineRect = NSUnionRect(lineRect, lineRects[rectIndex]);
            }
        }
        
        NSRect foldRect = NSMakeRect(NSMinX(rect), [self convertPoint:lineRect.origin fromView:self.clientView].y, kFoldViewWidth, NSHeight(lineRect));
        
        [[NSColor WC_colorWithHexadecimalString:@"ededed"] setFill];
        NSRectFill(foldRect);
        
        const CGFloat kTriangleHeight = 5;
        NSBezierPath *path = [NSBezierPath bezierPath];
        
        [path moveToPoint:NSMakePoint(NSMinX(foldRect), NSMinY(foldRect))];
        [path lineToPoint:NSMakePoint(NSMaxX(foldRect), NSMinY(foldRect))];
        [path lineToPoint:NSMakePoint(NSMidX(foldRect), NSMinY(foldRect) + kTriangleHeight)];
        [path lineToPoint:NSMakePoint(NSMinX(foldRect), NSMinY(foldRect))];
        [path closePath];
        
        [path moveToPoint:NSMakePoint(NSMinX(foldRect), NSMaxY(foldRect))];
        [path lineToPoint:NSMakePoint(NSMaxX(foldRect), NSMaxY(foldRect))];
        [path lineToPoint:NSMakePoint(NSMidX(foldRect), NSMaxY(foldRect) - kTriangleHeight)];
        [path lineToPoint:NSMakePoint(NSMinX(foldRect), NSMaxY(foldRect))];
        [path closePath];
        
        [[NSColor alternateSelectedControlColor] setFill];
        [path fill];
    }
}

- (void)setDelegate:(id<WCFoldViewDelegate>)delegate {
    _delegate = delegate;
    
    if (delegate) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_foldScannerDidFinishScanningFolds:) name:WCFoldScannerDidFinishScanningFoldsNotification object:[delegate foldScannerForFoldView:self]];
    }
}

- (NSColor *)_colorForFold:(Fold *)fold; {
    const CGFloat kStepAmount = 0.08;
    NSColor *baseColor = [[NSColor WC_colorWithHexadecimalString:@"dcdcdc"] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    int16_t depth = fold.depth.shortValue;
    
    return [NSColor colorWithCalibratedHue:baseColor.hueComponent saturation:baseColor.saturationComponent brightness:baseColor.brightnessComponent - (depth * kStepAmount) alpha:baseColor.alphaComponent];
}

- (void)setFoldToHighlight:(Fold *)foldToHighlight {
    if (_foldToHighlight == foldToHighlight)
        return;
    
    _foldToHighlight = foldToHighlight;
    
    [self setNeedsDisplay:YES];
}

- (void)_foldScannerDidFinishScanningFolds:(NSNotification *)note {
    [self setNeedsDisplay:YES];
}

@end
