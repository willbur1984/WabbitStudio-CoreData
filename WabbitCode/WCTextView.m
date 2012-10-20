//
//  WCTextView.m
//  WabbitStudio
//
//  Created by William Towe on 9/19/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCTextView.h"
#import "NSTextView+WCExtensions.h"
#import "WCToolTipWindow.h"
#import "WCSymbolScanner.h"
#import "WCDefines.h"
#import "NSString+WCExtensions.h"
#import "WCArgumentPlaceholderCell.h"
#import "Macro.h"
#import "WCCompletionWindow.h"
#import "WCTextStorage.h"
#import "WCSymbolImageManager.h"
#import "WCGeometry.h"
#import "WCBookmarkManager.h"
#import "NSArray+WCExtensions.h"
#import "Bookmark.h"
#import "WCHUDStatusWindow.h"
#import "NSEvent+WCExtensions.h"
#import "WCSyntaxHighlighter.h"
#import "NSAttributedString+WCExtensions.h"
#import "WCFoldScanner.h"
#import "Fold.h"
#import "NSColor+WCExtensions.h"
#import "NSObject+WCExtensions.h"

NSString *const WCTextViewFocusFollowsSelectionUserDefaultsKey = @"WCTextViewFocusFollowsSelectionUserDefaultsKey";

static NSString *const kHoverLinkTrackingAreaRangeUserInfoKey = @"kHoverLinkTrackingAreaRangeUserInfoKey";

static char kWCTextViewObservingContext;

@interface WCTextView ()
@property (weak,nonatomic) NSTimer *toolTipTimer;
@property (strong,nonatomic) NSMutableSet *hoverLinkTrackingAreas;
@property (strong,nonatomic) NSTrackingArea *currentHoverLinkTrackingArea;

- (void)_highlightMatchingBrace;
- (void)_highlightMatchingTempLabel;
- (void)_jumpToDefinitionForRange:(NSRange)range;
@end

@implementation WCTextView
#pragma mark *** Subclass Overrides ***
+ (NSMenu *)defaultMenu {
    NSMenu *retval = [[NSMenu alloc] initWithTitle:@"org.revsoft.wctextview.default-menu"];
    
    [retval addItemWithTitle:NSLocalizedString(@"Cut", nil) action:@selector(cut:) keyEquivalent:@""];
    [retval addItemWithTitle:NSLocalizedString(@"Copy", nil) action:@selector(copy:) keyEquivalent:@""];
    [retval addItemWithTitle:NSLocalizedString(@"Paste", nil) action:@selector(paste:) keyEquivalent:@""];
    [retval addItem:[NSMenuItem separatorItem]];
    
    [retval addItemWithTitle:NSLocalizedString(@"Jump to Definition", nil) action:@selector(jumpToDefinitionAction:) keyEquivalent:@""];
    [retval addItem:[NSMenuItem separatorItem]];
    
    return retval;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self WC_stopObservingUserDefaultsKeysWithContext:&kWCTextViewObservingContext];
}

+ (NSSet *)WC_userDefaultsKeysToObserve {
    return [NSSet setWithObjects:WCTextViewFocusFollowsSelectionUserDefaultsKey, nil];
}

#pragma mark NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &kWCTextViewObservingContext) {
        if ([keyPath isEqualToString:[@"values." stringByAppendingString:WCTextViewFocusFollowsSelectionUserDefaultsKey]]) {
            [self setNeedsDisplayInRect:self.visibleRect avoidAdditionalLayout:YES];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;
    
    [self setAutomaticSpellingCorrectionEnabled:NO];
    [self setAutomaticTextReplacementEnabled:NO];
    [self setContinuousSpellCheckingEnabled:NO];
    [self setUsesFindBar:YES];
    [self setIncrementalSearchingEnabled:YES];
    
    [self setHoverLinkTrackingAreas:[NSMutableSet setWithCapacity:0]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textViewDidChangeSelection:) name:NSTextViewDidChangeSelectionNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_viewBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:self.enclosingScrollView.contentView];
    
    [self WC_startObservingUserDefaultsKeysWithOptions:NSKeyValueObservingOptionNew context:&kWCTextViewObservingContext];
    
    return self;
}
#pragma mark NSResponder
- (void)mouseEntered:(NSEvent *)theEvent {
    [super mouseEntered:theEvent];
    
    if ([self.hoverLinkTrackingAreas containsObject:theEvent.trackingArea]) {
        NSRange range = [[theEvent.trackingArea.userInfo objectForKey:kHoverLinkTrackingAreaRangeUserInfoKey] rangeValue];
        
        [self.layoutManager addTemporaryAttributes:@{NSForegroundColorAttributeName : [NSColor blueColor],NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle|NSUnderlinePatternSolid)} forCharacterRange:range];
        [self.textStorage addAttribute:NSCursorAttributeName value:[NSCursor pointingHandCursor] range:range];
        
        [self setCurrentHoverLinkTrackingArea:theEvent.trackingArea];
    }
}

- (void)mouseExited:(NSEvent *)theEvent {
    [super mouseExited:theEvent];
    
    if ([self.hoverLinkTrackingAreas containsObject:theEvent.trackingArea]) {
        NSRange range = [[theEvent.trackingArea.userInfo objectForKey:kHoverLinkTrackingAreaRangeUserInfoKey] rangeValue];
        
        [self.layoutManager removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:range];
        [self.layoutManager removeTemporaryAttribute:NSUnderlineStyleAttributeName forCharacterRange:range];
        [self.textStorage removeAttribute:NSCursorAttributeName range:range];
        
        [self setCurrentHoverLinkTrackingArea:nil];
    }
    else {
        [[WCToolTipWindow sharedInstance] hideToolTipWindow];
    }
}

- (void)mouseMoved:(NSEvent *)theEvent {
    [super mouseMoved:theEvent];
    
    if ((theEvent.modifierFlags & NSDeviceIndependentModifierFlagsMask) > 0) {
        [self setToolTipTimer:nil];
        return;
    }
    
    NSPoint point = [self convertPoint:theEvent.locationInWindow fromView:nil];
    NSUInteger charIndex = [self characterIndexForInsertionAtPoint:point];
    
    if (charIndex >= self.string.length) {
        [self setToolTipTimer:nil];
        return;
    }
    
    const NSTimeInterval kToolTipDelayInterval = 1;
    
    NSRange foldRange = [(WCTextStorage *)self.textStorage foldRangeForRange:NSMakeRange(charIndex, 0)];
    
    if (foldRange.location != NSNotFound) {
        if (self.toolTipTimer && [[WCToolTipWindow sharedInstance] isVisible])
            [self _toolTipTimerCallback:nil];
        else
            [self setToolTipTimer:[NSTimer scheduledTimerWithTimeInterval:kToolTipDelayInterval target:self selector:@selector(_toolTipTimerCallback:) userInfo:nil repeats:NO]];
        
        return;
    }
    else if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[self.string characterAtIndex:charIndex]]) {
        [self setToolTipTimer:nil];
        return;
    }
    
    NSRange symbolRange = [self.string WC_symbolRangeForRange:NSMakeRange(charIndex, 0)];
    
    if (symbolRange.location == NSNotFound) {
        [self setToolTipTimer:nil];
        return;
    }
    
    NSArray *symbols = [[self.delegate symbolScannerForTextView:self] symbolsSortedByLocationWithName:[self.string substringWithRange:symbolRange]];
    
    if (!symbols.count) {
        [self setToolTipTimer:nil];
        return;
    }
    
    if (self.toolTipTimer && [[WCToolTipWindow sharedInstance] isVisible])
        [self _toolTipTimerCallback:nil];
    else
        [self setToolTipTimer:[NSTimer scheduledTimerWithTimeInterval:kToolTipDelayInterval target:self selector:@selector(_toolTipTimerCallback:) userInfo:nil repeats:NO]];
}

- (void)flagsChanged:(NSEvent *)theEvent {
    [super flagsChanged:theEvent];
    
    if ([theEvent WC_isOnlyCommandKeyPressed]) {
        NSPoint point = [self convertPoint:self.window.mouseLocationOutsideOfEventStream fromView:nil];
        NSRange range = [self WC_visibleRange];
        NSRange effectiveRange;
        id value;
        
        while (range.length) {
            if ((value = [self.textStorage attribute:kSymbolAttributeName atIndex:range.location longestEffectiveRange:&effectiveRange inRange:range])) {
                NSUInteger rectCount;
                NSRectArray rects = [self.layoutManager rectArrayForCharacterRange:effectiveRange withinSelectedCharacterRange:WC_NSNotFoundRange inTextContainer:self.textContainer rectCount:&rectCount];
                
                if (rectCount > 0) {
                    NSRect rect = rects[0];
                    NSTrackingAreaOptions options = NSTrackingActiveInKeyWindow|NSTrackingMouseEnteredAndExited|NSTrackingEnabledDuringMouseDrag;
                    
                    if (NSPointInRect(point, rect)) {
                        options |= NSTrackingAssumeInside;
                        
                        [self.layoutManager addTemporaryAttributes:@{NSForegroundColorAttributeName : [NSColor blueColor],NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle|NSUnderlinePatternSolid)} forCharacterRange:effectiveRange];
                        [self.textStorage addAttribute:NSCursorAttributeName value:[NSCursor pointingHandCursor] range:effectiveRange];
                    }
                    
                    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:rect options:options owner:self userInfo:@{kHoverLinkTrackingAreaRangeUserInfoKey : [NSValue valueWithRange:effectiveRange]}];
                    
                    [self addTrackingArea:trackingArea];
                    [self.hoverLinkTrackingAreas addObject:trackingArea];
                    
                    if (options & NSTrackingAssumeInside)
                        [self setCurrentHoverLinkTrackingArea:trackingArea];
                }
            }
            
            range = NSMakeRange(NSMaxRange(effectiveRange), NSMaxRange(range) - NSMaxRange(effectiveRange));
        }
    }
    else {
        for (NSTrackingArea *trackingArea in self.hoverLinkTrackingAreas)
            [self removeTrackingArea:trackingArea];
        
        [self.hoverLinkTrackingAreas removeAllObjects];
        
        [self setCurrentHoverLinkTrackingArea:nil];
    }
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (theEvent.type == NSLeftMouseDown &&
        theEvent.clickCount == 2 &&
        !(theEvent.modifierFlags & NSDeviceIndependentModifierFlagsMask)) {
        
        NSUInteger glyphIndex = [self.layoutManager glyphIndexForPoint:[self convertPoint:theEvent.locationInWindow fromView:nil] inTextContainer:self.textContainer];
        
        if (glyphIndex >= self.layoutManager.numberOfGlyphs) {
            [super mouseDown:theEvent];
            return;
        }
        
        WCTextStorage *textStorage = (WCTextStorage *)self.textStorage;
        
        [textStorage setFolding:YES];
        
        NSUInteger charIndex = [self.layoutManager characterIndexForGlyphAtIndex:glyphIndex];
        NSRange effectiveRange;
        id value = [textStorage attribute:WCTextStorageFoldAttributeName atIndex:charIndex longestEffectiveRange:&effectiveRange inRange:NSMakeRange(0, textStorage.length)];
        
        if (![value boolValue]) {
            [textStorage setFolding:NO];
            [super mouseDown:theEvent];
            return;
        }
        
        NSTextAttachment *attachment = [textStorage attribute:NSAttachmentAttributeName atIndex:effectiveRange.location effectiveRange:NULL];
        
        if (!attachment) {
            [textStorage setFolding:NO];
            [super mouseDown:theEvent];
            return;
        }
        
        [textStorage setFolding:NO];
        
        glyphIndex = [self.layoutManager glyphIndexForCharacterAtIndex:effectiveRange.location];
        
        id <NSTextAttachmentCell> cell = attachment.attachmentCell;
        NSPoint delta = [self.layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL].origin;
        NSRect cellFrame;
        
        cellFrame.origin = self.textContainerOrigin;
        cellFrame.size = [self.layoutManager attachmentSizeForGlyphAtIndex:glyphIndex];
        cellFrame.origin.x += delta.x;
        cellFrame.origin.y += delta.y;
        cellFrame.origin.x += [self.layoutManager locationForGlyphAtIndex:glyphIndex].x;
        
        if ([cell wantsToTrackMouseForEvent:theEvent inRect:cellFrame ofView:self atCharacterIndex:effectiveRange.location]) {
            if ([cell trackMouse:theEvent inRect:cellFrame ofView:self atCharacterIndex:effectiveRange.location untilMouseUp:YES])
                return;
        }
    }
    else if (self.currentHoverLinkTrackingArea) {
        NSEvent *event = theEvent;
        
        do {
            if (event.type == NSLeftMouseDragged) {
                [self setCurrentHoverLinkTrackingArea:nil];
                [[NSCursor IBeamCursor] set];
                break;
            }
            else if (event.type == NSLeftMouseUp) {
                [self _jumpToDefinitionForRange:[[self.currentHoverLinkTrackingArea.userInfo objectForKey:kHoverLinkTrackingAreaRangeUserInfoKey] rangeValue]];
                return;
            }
            
        } while ((event = [self.window nextEventMatchingMask:NSLeftMouseUpMask|NSLeftMouseDraggedMask]));
    }
    
    [super mouseDown:theEvent];
}

- (void)insertTab:(id)sender {
    NSRange range = [self.textStorage WC_nextPlaceholderRangeForRange:self.selectedRange inRange:[self.string lineRangeForRange:self.selectedRange] wrap:YES];
    
    if (range.location == NSNotFound) {
        [super insertTab:nil];
        return;
    }
    
    [self setSelectedRange:range];
}

- (void)insertBacktab:(id)sender {
    NSRange range = [self.textStorage WC_previousPlaceholderRangeForRange:self.selectedRange inRange:[self.string lineRangeForRange:self.selectedRange] wrap:YES];
    
    if (range.location == NSNotFound) {
        [super insertBacktab:nil];
        return;
    }
    
    [self setSelectedRange:range];
}

- (void)insertNewline:(id)sender {
    [super insertNewline:sender];
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:[self.string substringWithRange:[self.string lineRangeForRange:NSMakeRange(self.selectedRange.location - 1, 0)]]];
    
    [scanner setCharactersToBeSkipped:nil];
    
    NSString *whitespace;
    
    if ([scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&whitespace])
        [self insertText:whitespace];
}

#pragma mark NSView
- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    [super viewWillMoveToWindow:newWindow];
    
    [self setToolTipTimer:nil];
}
- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    
    if ([self.window.currentEvent WC_isOnlyCommandKeyPressed]) {
        for (NSTrackingArea *trackingArea in self.hoverLinkTrackingAreas)
            [self removeTrackingArea:trackingArea];
        
        [self.hoverLinkTrackingAreas removeAllObjects];
        
        NSPoint point = [self convertPoint:self.window.mouseLocationOutsideOfEventStream fromView:nil];
        NSRange range = [self WC_visibleRange];
        NSRange effectiveRange;
        id value;
        
        while (range.length) {
            if ((value = [self.textStorage attribute:kSymbolAttributeName atIndex:range.location longestEffectiveRange:&effectiveRange inRange:range])) {
                NSUInteger rectCount;
                NSRectArray rects = [self.layoutManager rectArrayForCharacterRange:effectiveRange withinSelectedCharacterRange:WC_NSNotFoundRange inTextContainer:self.textContainer rectCount:&rectCount];
                
                if (rectCount > 0) {
                    NSRect rect = rects[0];
                    NSTrackingAreaOptions options = NSTrackingActiveInKeyWindow|NSTrackingMouseEnteredAndExited|NSTrackingEnabledDuringMouseDrag;
                    
                    if (NSPointInRect(point, rect)) {
                        options |= NSTrackingAssumeInside;
                        
                        [self.layoutManager addTemporaryAttributes:@{NSForegroundColorAttributeName : [NSColor blueColor],NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle|NSUnderlinePatternSolid)} forCharacterRange:effectiveRange];
                        [self.textStorage addAttribute:NSCursorAttributeName value:[NSCursor pointingHandCursor] range:effectiveRange];
                    }
                    
                    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:rect options:options owner:self userInfo:@{kHoverLinkTrackingAreaRangeUserInfoKey : [NSValue valueWithRange:effectiveRange]}];
                    
                    [self addTrackingArea:trackingArea];
                    [self.hoverLinkTrackingAreas addObject:trackingArea];
                    
                    if (options & NSTrackingAssumeInside)
                        [self setCurrentHoverLinkTrackingArea:trackingArea];
                }
            }
            
            range = NSMakeRange(NSMaxRange(effectiveRange), NSMaxRange(range) - NSMaxRange(effectiveRange));
        }
    }
}

#pragma mark NSTextInputClient
- (void)insertText:(id)aString replacementRange:(NSRange)replacementRange {
    [super insertText:aString replacementRange:replacementRange];
    
    // automatically insert matching brace characters when an opening brace character is inserted
    if ([aString isEqualToString:@"["]) {
        [super insertText:@"]"];
        [self setSelectedRange:NSMakeRange(self.selectedRange.location - 1, 0)];
    }
    else if ([aString isEqualToString:@"{"]) {
        [super insertText:@"}"];
        [self setSelectedRange:NSMakeRange(self.selectedRange.location - 1, 0)];
    }
    else if ([aString isEqualToString:@"("]) {
        [super insertText:@")"];
        [self setSelectedRange:NSMakeRange(self.selectedRange.location - 1, 0)];
    }
    else {
        if (self.window.firstResponder != self)
            return;
        else if ([self.undoManager isRedoing] ||
                 [self.undoManager isUndoing] ||
                 [aString length] != 1) {
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(complete:) object:nil];
            return;
        }
        
        static NSCharacterSet *kLegalCharacters;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSMutableCharacterSet *temp = [[NSCharacterSet letterCharacterSet] mutableCopy];
            
            [temp formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
            [temp formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"_!?.#"]];
            
            kLegalCharacters = [temp copy];
        });
        
        if (![kLegalCharacters characterIsMember:[aString characterAtIndex:0]]) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(complete:) object:nil];
            return;
        }
        
        id value = [self.textStorage attribute:kMultilineCommentAttributeName atIndex:self.selectedRange.location effectiveRange:NULL];
        
        if ([value boolValue]) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(complete:) object:nil];
            return;
        }
        
        value = [self.textStorage attribute:kCommentAttributeName atIndex:self.selectedRange.location effectiveRange:NULL];
        
        if ([value boolValue]) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(complete:) object:nil];
            return;
        }
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(complete:) object:nil];
        [self performSelector:@selector(complete:) withObject:nil afterDelay:0.35];
    }
}
#pragma mark NSTextView
- (void)drawViewBackgroundInRect:(NSRect)rect {
    [super drawViewBackgroundInRect:rect];
    
    const NSUInteger kColumnNumber = 80;
    const CGFloat width = [@" " sizeWithAttributes:[WCSyntaxHighlighter defaultAttributes]].width;
    const CGFloat frameX = width * kColumnNumber;
    NSRect guideRect = NSMakeRect(frameX, NSMinY(self.bounds), NSWidth(self.bounds) - frameX, NSHeight(self.bounds));
    
    if (NSIntersectsRect(guideRect, rect)) {
        NSColor *color = [NSColor lightGrayColor];
        
        [[color colorWithAlphaComponent:0.35] setFill];
        NSRectFillUsingOperation(guideRect, NSCompositeSourceOver);
        
        [color setFill];
        
        guideRect.size.width = 1;
        
        NSRectFill(guideRect);
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:WCTextViewFocusFollowsSelectionUserDefaultsKey]) {
        Fold *fold = [[self.delegate foldScannerForTextView:self] deepestFoldForRange:self.selectedRange];
        
        if (fold) {
            const CGFloat stepAmount = 0.05;
            NSMutableArray *foldRects = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *foldColors = [NSMutableArray arrayWithCapacity:0];
            NSColor *foldColor = self.backgroundColor;
            
            do {
                NSUInteger rectCount;
                NSRectArray rects = [self.layoutManager rectArrayForCharacterRange:NSRangeFromString(fold.contentRange) withinSelectedCharacterRange:WC_NSNotFoundRange inTextContainer:self.textContainer rectCount:&rectCount];
                NSRect foldRect = NSZeroRect;
                
                for (NSUInteger index=0; index<rectCount; index++)
                    foldRect = NSUnionRect(foldRect, rects[index]);
                
                [foldRects addObject:[NSValue valueWithRect:foldRect]];
                [foldColors addObject:foldColor];
                
                fold = fold.fold;
                foldColor = [foldColor WC_colorWithBrightnessAdjustment:stepAmount];
                
            } while (fold);
            
            [foldRects enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSValue *value, NSUInteger idx, BOOL *stop) {
                NSColor *color = [foldColors objectAtIndex:idx];
                NSRect rect = value.rectValue;
                
                [color setFill];
                [[NSBezierPath bezierPathWithRoundedRect:rect xRadius:8 yRadius:8] fill];
            }];
        }
    }
}

- (NSRange)selectionRangeForProposedRange:(NSRange)proposedCharRange granularity:(NSSelectionGranularity)granularity {
    if (granularity != NSSelectByWord)
        return proposedCharRange;
    
    NSRange symbolRange = [self.string WC_symbolRangeForRange:proposedCharRange];
    
    if (symbolRange.location == NSNotFound)
        return proposedCharRange;

    return symbolRange;
}
- (void)setSelectedRanges:(NSArray *)ranges affinity:(NSSelectionAffinity)affinity stillSelecting:(BOOL)stillSelectingFlag {
    if (!stillSelectingFlag && ([ranges count] == 1)) {
        NSRange range = [[ranges objectAtIndex:0] rangeValue];
		
        if ((range.location < self.textStorage.length) && ([[ranges objectAtIndex:0] rangeValue].length == 0)) {
            id attribute = [self.textStorage attribute:WCTextStorageFoldAttributeName atIndex:range.location effectiveRange:NULL];
			
            if (attribute && [attribute boolValue]) {
                NSRange effectiveRange;
                
                [self.textStorage attribute:WCTextStorageFoldAttributeName atIndex:range.location longestEffectiveRange:&effectiveRange inRange:NSMakeRange(0, self.textStorage.length)];
				
                if (range.location != effectiveRange.location) {
                    range.location = ((affinity == NSSelectionAffinityUpstream) ? effectiveRange.location : NSMaxRange(effectiveRange));
                    [super setSelectedRange:range];
                    return;
                }
            }
        }
    }
    
    [super setSelectedRanges:ranges affinity:affinity stillSelecting:stillSelectingFlag];
    
    // hack to update our line number ruler view while selecting with the mouse :(
    if (stillSelectingFlag) {
        [self.enclosingScrollView.verticalRulerView setNeedsDisplay:YES];
    }
}

- (NSRange)rangeForUserCompletion {
    return [self.string WC_completionRangeForRange:self.selectedRange];
}

- (IBAction)complete:(id)sender {
    [[WCCompletionWindow sharedInstance] showCompletionWindowForTextView:self];
}
#pragma mark *** Public Methods ***
+ (NSRegularExpression *)completionRegex; {
    static NSRegularExpression *retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[NSRegularExpression alloc] initWithPattern:@"[A-Za-z0-9_!?.#]+" options:0 error:NULL];
    });
    return retval;
}
#pragma mark Properties
@dynamic delegate;
- (id<WCTextViewDelegate>)delegate {
    return (id<WCTextViewDelegate>)[super delegate];
}
- (void)setDelegate:(id<WCTextViewDelegate>)delegate {
    [super setDelegate:delegate];
}
#pragma mark Actions
- (IBAction)jumpToDefinitionAction:(id)sender; {
    [self _jumpToDefinitionForRange:self.selectedRange];
}

- (IBAction)foldAction:(id)sender; {
    [(WCTextStorage *)self.textStorage foldRange:self.selectedRange];
}
- (IBAction)unfoldAction:(id)sender; {
    if (![(WCTextStorage *)self.textStorage unfoldRange:self.selectedRange effectiveRange:NULL])
        NSBeep();
}

- (IBAction)toggleBookmarkAction:(id)sender; {
    WCBookmarkManager *bookmarkManager = [(WCTextStorage *)self.textStorage bookmarkManager];
    NSArray *bookmarks = [bookmarkManager bookmarksForRange:NSMakeRange([self.string lineRangeForRange:self.selectedRange].location, 0)];
    
    if (bookmarks.count > 0)
        [bookmarkManager removeBookmark:bookmarks.lastObject];
    else
        [bookmarkManager addBookmarkForRange:NSMakeRange([self.string lineRangeForRange:self.selectedRange].location, 0) name:nil];
}
- (IBAction)nextBookmarkAction:(id)sender; {
    WCBookmarkManager *bookmarkManager = [(WCTextStorage *)self.textStorage bookmarkManager];
    NSRange lineRange = [self.string lineRangeForRange:self.selectedRange];
    NSArray *bookmarks = [bookmarkManager bookmarksForRange:NSMakeRange(NSMaxRange(lineRange), self.string.length - NSMaxRange(lineRange)) inclusive:NO];
    Bookmark *bookmark;
    
    if (bookmarks.count == 0) {
        bookmarks = bookmarkManager.bookmarksSortedByLocation;
        
        if (bookmarks.count > 0) {
            bookmark = [bookmarks WC_firstObject];
            
            [self setSelectedRange:NSRangeFromString(bookmark.range)];
            [self scrollRangeToVisible:self.selectedRange];
            
            [[WCHUDStatusWindow sharedInstance] showImage:[NSImage imageNamed:@"FindWrapIndicator.tiff"] inView:self.enclosingScrollView drawBackground:NO];
            
            return;
        }
        
        NSBeep();
        return;
    }
    
    bookmark = [bookmarks WC_firstObject];
    
    [self setSelectedRange:NSRangeFromString(bookmark.range)];
    [self scrollRangeToVisible:self.selectedRange];
}
- (IBAction)previousBookmarkAction:(id)sender; {
    WCBookmarkManager *bookmarkManager = [(WCTextStorage *)self.textStorage bookmarkManager];
    NSArray *bookmarks = [bookmarkManager bookmarksForRange:NSMakeRange(0, self.selectedRange.location) inclusive:NO];
    Bookmark *bookmark;
    
    if (bookmarks.count == 0) {
        bookmarks = bookmarkManager.bookmarksSortedByLocation;
        
        if (bookmarks.count > 0) {
            bookmark = bookmarks.lastObject;
            
            [self setSelectedRange:NSRangeFromString(bookmark.range)];
            [self scrollRangeToVisible:self.selectedRange];
            
            [[WCHUDStatusWindow sharedInstance] showImage:[NSImage imageNamed:@"FindWrapIndicatorReverse.tiff"] inView:self.enclosingScrollView drawBackground:NO];
            
            return;
        }
        
        NSBeep();
        return;
    }
    
    bookmark = bookmarks.lastObject;
    
    [self setSelectedRange:NSRangeFromString(bookmark.range)];
    [self scrollRangeToVisible:self.selectedRange];
}

- (IBAction)jumpToNextPlaceholderAction:(id)sender; {
    NSRange range = [self.textStorage WC_nextPlaceholderRangeForRange:self.selectedRange inRange:NSMakeRange(0, self.string.length) wrap:YES];
    
    if (range.location == NSNotFound) {
        NSBeep();
        return;
    }
    
    [self setSelectedRange:range];
    [self scrollRangeToVisible:self.selectedRange];
}
- (IBAction)jumpToPreviousPlaceholderAction:(id)sender; {
    NSRange range = [self.textStorage WC_previousPlaceholderRangeForRange:self.selectedRange inRange:NSMakeRange(0, self.string.length) wrap:YES];
    
    if (range.location == NSNotFound) {
        NSBeep();
        return;
    }
    
    [self setSelectedRange:range];
    [self scrollRangeToVisible:self.selectedRange];
}
#pragma mark *** Private Methods ***
- (void)_highlightMatchingBrace; {
    // need at least two characters in our string to be able to match
	if (self.string.length <= 1)
		return;
	// return early if we have any text selected
	else if (self.selectedRange.length)
		return;
	
	static NSCharacterSet *closingCharacterSet;
	static NSCharacterSet *openingCharacterSet;
	if (!closingCharacterSet) {
		closingCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@")]}"];
		openingCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"([{"];
	}
	// return early if the character at the caret position is not one our closing brace characters
	if (![closingCharacterSet characterIsMember:[self.string characterAtIndex:self.selectedRange.location - 1]])
		return;
	
	unichar closingBraceCharacter = [self.string characterAtIndex:self.selectedRange.location - 1];
	NSUInteger numberOfClosingBraces = 0, numberOfOpeningBraces = 0;
	NSInteger characterIndex;
	NSRange visibleRange = [self WC_visibleRange];
	
	// scan backwards starting at the selected character index
	for (characterIndex = self.selectedRange.location-1; characterIndex > visibleRange.location; characterIndex--) {
		unichar charAtIndex = [self.string characterAtIndex:characterIndex];
		
		// increment the number of opening braces
		if ([openingCharacterSet characterIsMember:charAtIndex]) {
			numberOfOpeningBraces++;
			
			// if the number of opening and closing braces are equal and the opening and closing characters match, show the find indicator on the opening brace
			if (numberOfOpeningBraces == numberOfClosingBraces &&
				((closingBraceCharacter == ')' && charAtIndex == '(') ||
				 (closingBraceCharacter == ']' && charAtIndex == '[') ||
				 (closingBraceCharacter == '}' && charAtIndex == '{'))) {
					[self showFindIndicatorForRange:NSMakeRange(characterIndex, 1)];
					return;
				}
			// otherwise the braces don't match, beep at the user because we are angry
			else if (numberOfOpeningBraces > numberOfClosingBraces) {
				NSBeep();
				return;
			}
		}
		// increment the number of closing braces
		else if ([closingCharacterSet characterIsMember:charAtIndex])
			numberOfClosingBraces++;
	}
	
	NSBeep();
}
- (void)_highlightMatchingTempLabel; {
	// need at least two characters in order to match
    if (self.string.length <= 2)
		return;
    
    NSRange selectedRange = self.selectedRange;
    
	// selection cannot have a length
	if (selectedRange.length > 0)
		return;
    // must be a temp label character to continue searching
    else if ([self.string characterAtIndex:selectedRange.location - 1] != '_')
		return;
	// dont highlight the temp labels themselves
	else if ([self.string lineRangeForRange:selectedRange].location == selectedRange.location - 1)
		return;
	
	// number of references (going forwards or backwards) we are looking for
	__block NSInteger numberOfReferences = 0;
	
	NSUInteger stringLength = self.string.length;
	NSInteger charIndex;
	
	// count of the number of references so we know how many temp labels to skip over
	for (charIndex = selectedRange.location - 2; charIndex > 0; charIndex--) {
		unichar charAtIndex = [[self string] characterAtIndex:charIndex];
		
		// '+' means search forward in the file
		if (charAtIndex == '+')
			numberOfReferences++;
		// '-' means seach backwards in the file
		else if (charAtIndex == '-')
			numberOfReferences--;
		// otherwise we are done counting references
		else
			break;
	}
	
	// if we didn't count any references, it's an underscore by itself
	if (!numberOfReferences) {
		static NSCharacterSet *delimiterCharSet;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			NSMutableCharacterSet *charSet = [[NSCharacterSet whitespaceCharacterSet] mutableCopy];
            
			[charSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
            
			delimiterCharSet = [charSet copy];
		});
		
		// we need to make sure it isn't part of another word before continuing the search
		if (![delimiterCharSet characterIsMember:[self.string characterAtIndex:selectedRange.location - 2]])
			return;
		
		// otherwise count it as a single forward reference
		numberOfReferences++;
	}
	
	// always enumerate by lines, adding the reverse flag when we have a negative number of references
	__block BOOL foundMatchingTempLabel = NO;
	NSStringEnumerationOptions options = NSStringEnumerationByLines;
    
	if (numberOfReferences < 0)
		options |= NSStringEnumerationReverse;
    
	// we want to search either from our selected index forward to the end of the file or backwards from our selected index to the beginning of the file
	NSRange enumRange = (numberOfReferences > 0)?NSMakeRange(selectedRange.location, stringLength-selectedRange.location):NSMakeRange(0, selectedRange.location);
	
	[self.string enumerateSubstringsInRange:enumRange options:options usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		// the first character has to be an underscore
		if (substringRange.length && [substring characterAtIndex:0] == '_') {
			// make sure the underscore isn't part of another symbol (i.e. a label)
			id value = [self.textStorage attribute:kTokenAttributeName atIndex:substringRange.location effectiveRange:NULL];
            if ([value boolValue])
                return;
			
			// decrement the number of references, checking for 0
			if (numberOfReferences > 0 && (!(--numberOfReferences))) {
				foundMatchingTempLabel = YES;
				*stop = YES;
				
				[self showFindIndicatorForRange:NSMakeRange(substringRange.location, 1)];
			}
			// increment the number of references, checking for 0
			else if (numberOfReferences < 0 && (!(++numberOfReferences))) {
				foundMatchingTempLabel = YES;
				*stop = YES;
				
				[self showFindIndicatorForRange:NSMakeRange(substringRange.location, 1)];
			}
		}
	}];
	
	// if we didn't find a matching temp label, beep at the user because we are angry
	if (!foundMatchingTempLabel)
		NSBeep();
}
- (void)_jumpToDefinitionForRange:(NSRange)range; {
    NSRange symbolRange = [self.string WC_symbolRangeForRange:range];
    
    if (symbolRange.location == NSNotFound) {
        NSBeep();
        return;
    }
    
    NSArray *symbols = [[self.delegate symbolScannerForTextView:self] symbolsSortedByLocationWithName:[self.string substringWithRange:symbolRange]];
    
    if (!symbols.count) {
        NSBeep();
        return;
    }
    else if (symbols.count == 1) {
        if ([self.delegate respondsToSelector:@selector(textView:jumpToDefinitionForSymbol:)])
            [self.delegate textView:self jumpToDefinitionForSymbol:symbols.lastObject];
    }
    else {
        NSMenu *menu = [[NSMenu alloc] initWithTitle:@"org.revsoft.wctextview.jump-to-definition-menu"];
        
        [menu setFont:[NSFont menuFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
        
        for (Symbol *symbol in symbols) {
            NSMenuItem *item = [menu addItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ \u2192 line %ld", nil),symbol.name,symbol.lineNumber.integerValue] action:@selector(_jumpToDefinitionMenuItemAction:) keyEquivalent:@""];
            
            [item setTarget:self];
            [item setRepresentedObject:symbol];
            [item setImage:[[WCSymbolImageManager sharedManager] imageForSymbol:symbol]];
            [item.image setSize:WC_NSSmallSize];
        }
        
        NSUInteger glyphIndex = [self.layoutManager glyphIndexForCharacterAtIndex:symbolRange.location];
        NSRect lineFragmentRect = [self.layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL];
        NSPoint glyphLocation = [self.layoutManager locationForGlyphAtIndex:glyphIndex];
        
        lineFragmentRect.origin.x += glyphLocation.x;
        lineFragmentRect.origin.y += NSHeight(lineFragmentRect);
        
        [menu popUpMenuPositioningItem:nil atLocation:lineFragmentRect.origin inView:self];
    }
}
#pragma mark Properties
- (void)setToolTipTimer:(NSTimer *)toolTipTimer {
    if (_toolTipTimer)
        [_toolTipTimer invalidate];
    
    _toolTipTimer = toolTipTimer;
}
- (void)setCurrentHoverLinkTrackingArea:(NSTrackingArea *)currentHoverLinkTrackingArea {
    if (_currentHoverLinkTrackingArea) {
        NSRange range = [[_currentHoverLinkTrackingArea.userInfo objectForKey:kHoverLinkTrackingAreaRangeUserInfoKey] rangeValue];
        
        [self.layoutManager removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:range];
        [self.layoutManager removeTemporaryAttribute:NSUnderlineStyleAttributeName forCharacterRange:range];
        [self.textStorage removeAttribute:NSCursorAttributeName range:range];
    }
    
    _currentHoverLinkTrackingArea = currentHoverLinkTrackingArea;
}

#pragma mark Actions
- (IBAction)_jumpToDefinitionMenuItemAction:(NSMenuItem *)sender {
    if ([self.delegate respondsToSelector:@selector(textView:jumpToDefinitionForSymbol:)])
        [self.delegate textView:self jumpToDefinitionForSymbol:sender.representedObject];
}
#pragma mark Callbacks
- (void)_toolTipTimerCallback:(NSTimer *)timer {
    if ((self.window.currentEvent.modifierFlags & NSDeviceIndependentModifierFlagsMask) > 0) {
        [self setToolTipTimer:nil];
        return;
    }
    
    NSPoint point = [self convertPoint:[[NSApplication sharedApplication] currentEvent].locationInWindow fromView:nil];
    NSUInteger charIndex = [self characterIndexForInsertionAtPoint:point];
    
    if (charIndex >= self.string.length) {
        [self setToolTipTimer:nil];
        return;
    }
    
    NSRange foldRange = [(WCTextStorage *)self.textStorage foldRangeForRange:NSMakeRange(charIndex, 0)];
    
    if (foldRange.location != NSNotFound) {
        NSUInteger glyphIndex = [self.layoutManager glyphIndexForCharacterAtIndex:foldRange.location];
        NSRect lineFragmentRect = [self.layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL];
        NSPoint glyphLocation = [self.layoutManager locationForGlyphAtIndex:glyphIndex];
        
        lineFragmentRect.origin.x += glyphLocation.x;
        lineFragmentRect.origin.y += NSHeight(lineFragmentRect);
        
        [[WCToolTipWindow sharedInstance] showString:[self.string substringWithRange:foldRange] atPoint:[self.window convertBaseToScreen:[self convertPoint:lineFragmentRect.origin toView:nil]]];
        return;
    }
    else if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[self.string characterAtIndex:charIndex]]) {
        [self setToolTipTimer:nil];
        return;
    }
    
    NSRange symbolRange = [self.string WC_symbolRangeForRange:NSMakeRange(charIndex, 0)];
    
    if (symbolRange.location == NSNotFound) {
        [self setToolTipTimer:nil];
        return;
    }
    
    NSArray *symbols = [[self.delegate symbolScannerForTextView:self] symbolsSortedByLocationWithName:[self.string substringWithRange:symbolRange]];
    
    if (!symbols.count) {
        [self setToolTipTimer:nil];
        return;
    }
    
    NSMutableString *string = [NSMutableString stringWithCapacity:0];
    
    for (Symbol *symbol in symbols) {
        if ([symbol respondsToSelector:@selector(arguments)]) {
            NSMutableString *value = [NSMutableString stringWithString:symbol.value];
            NSRange newlineRange = [value rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSLiteralSearch];
            
            if (newlineRange.length > 0 && NSMaxRange(newlineRange) < value.length) {
                __block NSUInteger toIndex = NSNotFound;
                __block NSUInteger lines = 5;
                
                [value enumerateSubstringsInRange:NSMakeRange(NSMaxRange(newlineRange), value.length - NSMaxRange(newlineRange)) options:NSStringEnumerationByLines|NSStringEnumerationSubstringNotRequired usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                    toIndex = NSMaxRange(substringRange);
                    
                    if (--lines == 0)
                        *stop = YES;
                }];
                
                [value deleteCharactersInRange:NSMakeRange(toIndex, value.length - toIndex)];
                [value appendString:NSLocalizedString(@" \u2026", nil)];
            }
            
            if (symbol.arguments)
                [string appendFormat:NSLocalizedString(@"%@(%@) \u2192 line %ld\n%@\n", nil),symbol.name,symbol.arguments,symbol.lineNumber.integerValue + 1,value];
            else
                [string appendFormat:NSLocalizedString(@"%@ \u2192 line %ld\n%@\n", nil),symbol.name,symbol.lineNumber.integerValue + 1,value];
        }
        else if ([symbol respondsToSelector:@selector(value)])
            [string appendFormat:NSLocalizedString(@"%@ = %@ \u2192 line %ld\n", nil),symbol.name,symbol.value,symbol.lineNumber.integerValue + 1];
        else
            [string appendFormat:NSLocalizedString(@"%@ \u2192 line %ld\n", nil),symbol.name,symbol.lineNumber.integerValue + 1];
    }
    
    [string deleteCharactersInRange:NSMakeRange(string.length - 1, 1)];
    
    NSUInteger glyphIndex = [self.layoutManager glyphIndexForCharacterAtIndex:symbolRange.location];
    NSRect lineFragmentRect = [self.layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL];
    NSPoint glyphLocation = [self.layoutManager locationForGlyphAtIndex:glyphIndex];
    
    lineFragmentRect.origin.x += glyphLocation.x;
    lineFragmentRect.origin.y += NSHeight(lineFragmentRect);
    
    [[WCToolTipWindow sharedInstance] showString:string atPoint:[self.window convertBaseToScreen:[self convertPoint:lineFragmentRect.origin toView:nil]]];
}

#pragma mark Notifications
- (void)_textViewDidChangeSelection:(NSNotification *)note {
    NSRange oldSelectedRange = [[note.userInfo objectForKey:@"NSOldSelectedCharacterRange"] rangeValue];
    
    if (!oldSelectedRange.length &&
		oldSelectedRange.location < self.selectedRange.location &&
		self.selectedRange.location - oldSelectedRange.location == 1) {
        
        [self _highlightMatchingBrace];
        [self _highlightMatchingTempLabel];
    }
    
    [self setNeedsDisplayInRect:self.visibleRect avoidAdditionalLayout:YES];
}
- (void)_viewBoundsDidChange:(NSNotification *)note {
    
}

@end
