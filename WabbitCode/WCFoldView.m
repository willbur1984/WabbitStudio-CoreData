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
#import "WCTextStorage.h"
#import "WCBookmarkManager.h"
#import "Bookmark.h"
#import "WCDefines.h"

static const CGFloat kFoldViewWidth = 7;

static const CGFloat kBookmarkHeight = 9;
static const CGFloat kBookmarkWidth = 12;
static const CGFloat kBookmarkEdgeInset = 3;

@interface WCFoldView ()
@property (readonly,nonatomic) WCTextStorage *textStorage;
@property (strong,nonatomic) NSTrackingArea *foldTrackingRect;
@property (strong,nonatomic) Fold *foldToHighlight;
@property (strong,nonatomic) Fold *clickedFold;

- (NSColor *)_colorForFold:(Fold *)fold;
@end

@implementation WCFoldView
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark NSResponder
- (void)mouseEntered:(NSEvent *)theEvent {
    NSUInteger lineNumber = [self lineNumberForPoint:[self convertPoint:theEvent.locationInWindow fromView:nil]];
    
    if (lineNumber == NSNotFound)
        return;
    
    NSUInteger lineStartIndex = [[self.lineStartIndexes objectAtIndex:lineNumber] unsignedIntegerValue];
    Fold *fold = [[self.delegate foldScannerForFoldView:self] deepestFoldForRange:[self.textView.string lineRangeForRange:NSMakeRange(lineStartIndex, 0)]];
    
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
    Fold *fold = [[self.delegate foldScannerForFoldView:self] deepestFoldForRange:[self.textView.string lineRangeForRange:NSMakeRange(lineStartIndex, 0)]];
    
    [self setFoldToHighlight:fold];
}

- (void)mouseDown:(NSEvent *)theEvent {
    [self setClickedFold:self.foldToHighlight];
    
    if (!self.clickedFold)
        [super mouseDown:theEvent];
}
- (void)mouseUp:(NSEvent *)theEvent {
    if (self.foldToHighlight) {
        NSRange contentRange = NSRangeFromString(self.foldToHighlight.contentRange);
        
        if ([self.textStorage foldRangeForRange:contentRange].location == NSNotFound)
            [self.textStorage foldRange:contentRange];
        else
            [self.textStorage unfoldRange:contentRange effectiveRange:NULL];
    }
    
    [self setClickedFold:nil];
}
#pragma mark NSView
+ (NSMenu *)defaultMenu {
    NSMenu *retval = [[NSMenu alloc] initWithTitle:@"org.revsoft.wcfoldview.default-menu"];
    
    [retval addItemWithTitle:NSLocalizedString(@"Remove All Bookmarks", nil) action:@selector(_removeAllBookmarksAction:) keyEquivalent:@""];
    
    return retval;
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    
    [self removeTrackingArea:self.foldTrackingRect];
    
    NSRect rect = NSMakeRect(NSMaxX(self.frame) - kFoldViewWidth, 0, kFoldViewWidth, NSHeight(self.frame));
    NSTrackingAreaOptions options = NSTrackingActiveInKeyWindow|NSTrackingMouseMoved|NSTrackingMouseEnteredAndExited|NSTrackingEnabledDuringMouseDrag;
    
    if (NSPointInRect([self convertPoint:self.window.mouseLocationOutsideOfEventStream fromView:nil], rect))
        options |= NSTrackingAssumeInside;
    
    [self setFoldTrackingRect:[[NSTrackingArea alloc] initWithRect:rect options:options owner:self userInfo:nil]];
    [self addTrackingArea:self.foldTrackingRect];
}
#pragma mark NSRulerView
- (CGFloat)requiredThickness {
    return [super requiredThickness] + kFoldViewWidth + 6;
}

- (void)drawHashMarksAndLabelsInRect:(NSRect)rect {
    [self drawBackgroundAndDividerLineInRect:NSMakeRect(NSMinX(self.frame), 0, NSWidth(self.frame) - kFoldViewWidth, NSHeight(self.frame))];
    [self drawLineNumbersInRect:NSMakeRect(NSMinX(self.frame), 0, NSWidth(self.frame) - kFoldViewWidth, NSHeight(self.frame))];
    [self drawFoldsInRect:NSMakeRect(NSMaxX(self.frame) - kFoldViewWidth, 0, kFoldViewWidth, NSHeight(self.frame))];
    [self drawBookmarksInRect:NSMakeRect(NSMinX(self.bounds), 0, NSWidth(self.frame), NSHeight(self.frame))];
}
#pragma mark *** Public Methods ***
- (id)initWithTextView:(NSTextView *)textView {
    if (!(self = [super initWithTextView:textView]))
        return nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidFold:) name:WCTextStorageDidFoldNotification object:textView.textStorage];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidUnfold:) name:WCTextStorageDidUnfoldNotification object:textView.textStorage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_bookmarkManagerDidAddBookmark:) name:WCBookmarkManagerDidAddBookmarkNotification object:self.textStorage.bookmarkManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_bookmarkManagerDidRemoveBookmark:) name:WCBookmarkManagerDidRemoveBookmarkNotification object:self.textStorage.bookmarkManager];
    
    return self;
}

- (void)drawBookmarksInRect:(NSRect)rect; {
    NSArray *bookmarks = [self.textStorage.bookmarkManager bookmarksForRange:[self.textView WC_visibleRange]];
    
    for (Bookmark *bookmark in bookmarks) {
        NSUInteger numberOfLineRects;
        NSRectArray lineRects = [self.textView.layoutManager rectArrayForCharacterRange:NSMakeRange(bookmark.location.integerValue, 0) withinSelectedCharacterRange:WC_NSNotFoundRange inTextContainer:self.textView.textContainer rectCount:&numberOfLineRects];
        
        if (!numberOfLineRects)
            continue;
        
        NSRect lineRect = lineRects[0];
        NSRect bookmarkRect = NSMakeRect(NSMinX(rect), [self convertPoint:lineRect.origin fromView:self.clientView].y + (NSHeight(lineRect) * 0.5) - (kBookmarkHeight * 0.5), kBookmarkWidth, kBookmarkHeight);
        NSBezierPath *path = [NSBezierPath bezierPath];
        
        [path moveToPoint:NSMakePoint(NSMinX(bookmarkRect), NSMinY(bookmarkRect))];
        [path lineToPoint:NSMakePoint(NSMaxX(bookmarkRect), NSMinY(bookmarkRect))];
        [path lineToPoint:NSMakePoint(NSMaxX(bookmarkRect) - kBookmarkEdgeInset, NSMidY(bookmarkRect))];
        [path lineToPoint:NSMakePoint(NSMaxX(bookmarkRect), NSMaxY(bookmarkRect))];
        [path lineToPoint:NSMakePoint(NSMinX(bookmarkRect), NSMaxY(bookmarkRect))];
        [path lineToPoint:NSMakePoint(NSMinX(bookmarkRect), NSMinY(bookmarkRect))];
        [path closePath];
        
        [[NSColor blueColor] setFill];
        [path fill];
    }
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
            NSUInteger rectIndex;
            
            for (rectIndex=1; rectIndex<numberOfLineRects; rectIndex++)
                lineRect = NSUnionRect(lineRect, lineRects[rectIndex]);
        }
        
        NSRect foldRect = NSMakeRect(NSMinX(rect), [self convertPoint:lineRect.origin fromView:self.clientView].y, kFoldViewWidth, NSHeight(lineRect));
        NSColor *foldColor = [self _colorForFold:fold];
        
        [foldColor setFill];
        NSRectFill(foldRect);
    }
    
    if (self.foldToHighlight) {
        NSRange range = NSRangeFromString(self.foldToHighlight.range);
        NSRange contentRange = NSRangeFromString(self.foldToHighlight.contentRange);
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
        
        if ([self.textStorage foldRangeForRange:contentRange].location == NSNotFound) {
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
        }
        else {
            [path moveToPoint:NSMakePoint(NSMinX(foldRect), NSMinY(foldRect))];
            [path lineToPoint:NSMakePoint(NSMaxX(foldRect), NSMinY(foldRect) + (NSWidth(foldRect) * 0.5))];
            [path lineToPoint:NSMakePoint(NSMinX(foldRect), NSMinY(foldRect) + NSWidth(foldRect))];
            [path lineToPoint:NSMakePoint(NSMinX(foldRect), NSMinY(foldRect))];
            [path closePath];
        }
        
        [[NSColor alternateSelectedControlColor] setFill];
        [path fill];
    }
}
#pragma mark Properties
- (void)setDelegate:(id<WCFoldViewDelegate>)delegate {
    _delegate = delegate;
    
    if (delegate) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_foldScannerDidFinishScanningFolds:) name:WCFoldScannerDidFinishScanningFoldsNotification object:[delegate foldScannerForFoldView:self]];
    }
}
#pragma mark *** Private Methods ***
- (NSColor *)_colorForFold:(Fold *)fold; {
    const CGFloat kStepAmount = 0.08;
    NSColor *baseColor = [[NSColor WC_colorWithHexadecimalString:@"dcdcdc"] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    int16_t depth = fold.depth.shortValue;
    
    return [NSColor colorWithCalibratedHue:baseColor.hueComponent saturation:baseColor.saturationComponent brightness:baseColor.brightnessComponent - (depth * kStepAmount) alpha:baseColor.alphaComponent];
}
#pragma mark Properties
- (void)setFoldToHighlight:(Fold *)foldToHighlight {
    if (_foldToHighlight == foldToHighlight)
        return;
    
    _foldToHighlight = foldToHighlight;
    
    [self setNeedsDisplay:YES];
}

- (WCTextStorage *)textStorage {
    return (WCTextStorage *)self.textView.textStorage;
}
#pragma mark Actions
- (IBAction)_removeAllBookmarksAction:(id)sender {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:WCBookmarkManagerShowRemoveAllWarningUserDefaultsKey]) {
        [self.textStorage.bookmarkManager removeAllBookmarks];
        return;
    }
    
    NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Remove All Bookmarks", nil) defaultButton:NSLocalizedString(@"Remove All", nil) alternateButton:NSLocalizedString(@"Cancel", nil) otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Are you sure you want to remove all bookmarks? This operation cannot be undone.", nil)];
    
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert setShowsSuppressionButton:YES];
    
    [alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(_removeAllBookmarksAlert:code:context:) contextInfo:NULL];
}
#pragma mark Callbacks
- (void)_removeAllBookmarksAlert:(NSAlert *)alert code:(NSInteger)code context:(void *)context {
    if (code == NSAlertDefaultReturn) {
        if (alert.suppressionButton.state == NSOnState)
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:WCBookmarkManagerShowRemoveAllWarningUserDefaultsKey];
        
        [self.textStorage.bookmarkManager removeAllBookmarks];
    }
}

#pragma mark Notifications
- (void)_foldScannerDidFinishScanningFolds:(NSNotification *)note {
    [self setNeedsDisplay:YES];
}
- (void)_textStorageDidFold:(NSNotification *)note {
    [self setNeedsDisplay:YES];
}
- (void)_textStorageDidUnfold:(NSNotification *)note {
    [self setNeedsDisplay:YES];
}
- (void)_bookmarkManagerDidAddBookmark:(NSNotification *)note {
    [self setNeedsDisplay:YES];
}
- (void)_bookmarkManagerDidRemoveBookmark:(NSNotification *)note {
    [self setNeedsDisplay:YES];
}

@end
