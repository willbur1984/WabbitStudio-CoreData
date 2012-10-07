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

@interface WCTextView ()
@property (weak,nonatomic) NSTimer *toolTipTimer;

- (void)_highlightMatchingBrace;
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
#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;
    
    [self setAutomaticSpellingCorrectionEnabled:NO];
    [self setAutomaticTextReplacementEnabled:NO];
    [self setContinuousSpellCheckingEnabled:NO];
    [self setUsesFindBar:YES];
    [self setIncrementalSearchingEnabled:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textViewDidChangeSelection:) name:NSTextViewDidChangeSelectionNotification object:self];
    
    return self;
}
#pragma mark NSResponder
- (void)mouseExited:(NSEvent *)theEvent {
    [super mouseExited:theEvent];
    
    [[WCToolTipWindow sharedInstance] hideToolTipWindow];
}

- (void)mouseMoved:(NSEvent *)theEvent {
    [super mouseMoved:theEvent];
    
    NSPoint point = [self convertPoint:theEvent.locationInWindow fromView:nil];
    NSUInteger charIndex = [self characterIndexForInsertionAtPoint:point];
    
    if (charIndex >= self.string.length) {
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
    
    const NSTimeInterval kToolTipDelayInterval = 1;
    
    if (self.toolTipTimer && [[WCToolTipWindow sharedInstance] isVisible])
        [self _toolTipTimerCallback:nil];
    else
        [self setToolTipTimer:[NSTimer scheduledTimerWithTimeInterval:kToolTipDelayInterval target:self selector:@selector(_toolTipTimerCallback:) userInfo:nil repeats:NO]];
}

#pragma mark NSView
- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    [super viewWillMoveToWindow:newWindow];
    
    [self setToolTipTimer:nil];
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
}
#pragma mark NSTextView
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
    return [self.string WC_symbolRangeForRange:[super rangeForUserCompletion]];
}

- (IBAction)complete:(id)sender {
    [[WCCompletionWindow sharedInstance] showCompletionWindowForTextView:self];
}
#pragma mark *** Public Methods ***
@dynamic delegate;
- (id<WCTextViewDelegate>)delegate {
    return (id<WCTextViewDelegate>)[super delegate];
}
- (void)setDelegate:(id<WCTextViewDelegate>)delegate {
    [super setDelegate:delegate];
}
#pragma mark Actions
- (IBAction)jumpToDefinitionAction:(id)sender; {
    NSRange symbolRange = [self.string WC_symbolRangeForRange:self.selectedRange];
    
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
#pragma mark Properties
- (void)setToolTipTimer:(NSTimer *)toolTipTimer {
    if (_toolTipTimer)
        [_toolTipTimer invalidate];
    
    _toolTipTimer = toolTipTimer;
}

#pragma mark Actions
- (IBAction)_jumpToDefinitionMenuItemAction:(NSMenuItem *)sender {
    if ([self.delegate respondsToSelector:@selector(textView:jumpToDefinitionForSymbol:)])
        [self.delegate textView:self jumpToDefinitionForSymbol:sender.representedObject];
}
#pragma mark Callbacks
- (void)_toolTipTimerCallback:(NSTimer *)timer {
    NSPoint point = [self convertPoint:[[NSApplication sharedApplication] currentEvent].locationInWindow fromView:nil];
    NSUInteger charIndex = [self characterIndexForInsertionAtPoint:point];
    
    if (charIndex >= self.string.length) {
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
    
    for (Symbol *symbol in symbols)
        [string appendFormat:NSLocalizedString(@"%@ \u2192 line %lu\n", nil),symbol.name,symbol.lineNumber.integerValue + 1];
    
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
    }
}

@end
