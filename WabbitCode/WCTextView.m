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

@interface WCTextView ()
- (void)_highlightMatchingBrace;
@end

@implementation WCTextView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;
    
    //[self.layoutManager setAllowsNonContiguousLayout:NO];
    [self setAutomaticSpellingCorrectionEnabled:NO];
    [self setAutomaticTextReplacementEnabled:NO];
    [self setContinuousSpellCheckingEnabled:NO];
    [self setUsesFindBar:YES];
    [self setIncrementalSearchingEnabled:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textViewDidChangeSelection:) name:NSTextViewDidChangeSelectionNotification object:self];
    
    return self;
}

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

- (void)setSelectedRanges:(NSArray *)ranges affinity:(NSSelectionAffinity)affinity stillSelecting:(BOOL)stillSelectingFlag {
    [super setSelectedRanges:ranges affinity:affinity stillSelecting:stillSelectingFlag];
    
    // hack to update our line number ruler view while selecting with the mouse :(
    if (stillSelectingFlag) {
        [self.enclosingScrollView.verticalRulerView setNeedsDisplay:YES];
    }
}

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

- (void)_textViewDidChangeSelection:(NSNotification *)note {
    NSRange oldSelectedRange = [[note.userInfo objectForKey:@"NSOldSelectedCharacterRange"] rangeValue];
    
    if (!oldSelectedRange.length &&
		oldSelectedRange.location < self.selectedRange.location &&
		self.selectedRange.location - oldSelectedRange.location == 1) {
        
        [self _highlightMatchingBrace];
    }
}

@end
