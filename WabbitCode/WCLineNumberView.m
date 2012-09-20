//
//  WCLineNumberView.m
//  WabbitStudio
//
//  Created by William Towe on 9/18/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCLineNumberView.h"
#import "NSColor+WCExtensions.h"
#import "NSArray+WCExtensions.h"
#import "NSParagraphStyle+WCExtensions.h"

@interface WCLineNumberView ()
@property (readonly,nonatomic) NSTextView *textView;
@property (strong,nonatomic) NSMutableArray *lineStartIndexes;
@property (readwrite,assign,nonatomic) BOOL shouldRecalculateLineStartIndexes;
@property (assign,nonatomic) NSUInteger lineNumberToRecalculateFrom;

- (void)_calculateLineStartIndexes;
- (void)_calculateLineStartIndexesStartingAtLineNumber:(NSUInteger)lineNumber;
@end

@implementation WCLineNumberView

- (void)viewWillDraw {
	[super viewWillDraw];
	
	CGFloat newThickness = self.requiredThickness;
	
	if (fabs(self.ruleThickness - newThickness) > 1)
		[self setRuleThickness:newThickness];
}

static const CGFloat kStringMarginLeftRight = 4;
static const CGFloat kDefaultThickness = 30;

- (void)drawHashMarksAndLabelsInRect:(NSRect)rect {
    [[NSColor WC_colorWithHexadecimalString:@"f1f1f1"] setFill];
    NSRectFill(rect);
    
    NSRect dividerRect = NSMakeRect(NSMaxX(self.frame) - 1, 0, 1, NSHeight(self.frame));
    
    if (NSIntersectsRect(dividerRect, rect)) {
        [[NSColor WC_colorWithHexadecimalString:@"b3b3b3"] setFill];
        NSRectFill(dividerRect);
    }
    
    NSRange glyphRange = [self.textView.layoutManager glyphRangeForBoundingRect:self.textView.visibleRect inTextContainer:self.textView.textContainer];
    NSRange charRange = [self.textView.layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:NULL];
    NSUInteger lineNumber, lineStartIndex, numberOfLines = self.lineStartIndexes.count;
    NSRange selectedLineRange = [self.textView.string lineRangeForRange:self.textView.selectedRange];
    
    charRange.length++;
    
    for (lineNumber = [self.lineStartIndexes WC_lineNumberForRange:charRange]; lineNumber < numberOfLines; lineNumber++) {
        lineStartIndex = [[self.lineStartIndexes objectAtIndex:lineNumber] unsignedIntegerValue];
        
        if (NSLocationInRange(lineStartIndex, charRange)) {
            NSUInteger numberOfLineRects;
            NSRectArray lineRects = [self.textView.layoutManager rectArrayForCharacterRange:NSMakeRange(lineStartIndex, 0) withinSelectedCharacterRange:NSMakeRange(NSNotFound, 0) inTextContainer:self.textView.textContainer rectCount:&numberOfLineRects];
            
            if (numberOfLineRects) {
                NSDictionary *attributes = [self stringAttributesForLineNumber:lineNumber selectedLineRange:selectedLineRange];
                NSRect lineRect = lineRects[0];
                NSRect drawRect = NSMakeRect(NSMinX(self.frame), [self convertPoint:lineRect.origin fromView:self.clientView].y, NSWidth(self.frame) - kStringMarginLeftRight, NSHeight(lineRect));
                
                [[NSString stringWithFormat:@"%lu",lineNumber + 1] drawInRect:drawRect withAttributes:attributes];
            }
        }
        
        if (lineStartIndex > NSMaxRange(charRange))
			break;
    }
}

- (CGFloat)requiredThickness {
    NSUInteger lineCount = self.lineStartIndexes.count;
    NSMutableString *sampleString = [NSMutableString string];
    NSUInteger digits = (NSUInteger)log10(lineCount) + 1;
	NSUInteger i;
	
    for (i = 0; i < digits; i++)
        [sampleString appendString:@"8"];
    
    NSSize stringSize = [sampleString sizeWithAttributes:@{ NSFontAttributeName : [NSFont userFixedPitchFontOfSize:[NSFont systemFontSizeForControlSize:NSMiniControlSize]] }];
	
	return ceil(MAX(kDefaultThickness, stringSize.width + (kStringMarginLeftRight * 2)));
}

- (id)initWithTextView:(NSTextView *)textView; {
    NSAssert(textView.enclosingScrollView, @"text view must have an enclosing scroll view!");
    
    if (!(self = [super initWithScrollView:textView.enclosingScrollView orientation:NSVerticalRuler]))
        return nil;
    
    [self setClientView:textView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidProcessEditing:) name:NSTextStorageDidProcessEditingNotification object:textView.textStorage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textViewDidChangeSelection:) name:NSTextViewDidChangeSelectionNotification object:textView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_viewFrameDidChange:) name:NSViewFrameDidChangeNotification object:textView.enclosingScrollView.contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_viewFrameDidChange:) name:NSViewBoundsDidChangeNotification object:textView.enclosingScrollView.contentView];
    
    [self setLineStartIndexes:[NSMutableArray arrayWithObject:@0]];
    [self setLineNumberToRecalculateFrom:0];
    [self setShouldRecalculateLineStartIndexes:YES];
    
    return self;
}

- (NSDictionary *)stringAttributesForLineNumber:(NSUInteger)lineNumber selectedLineRange:(NSRange)selectedLineRange; {
    if (NSLocationInRange([[self.lineStartIndexes objectAtIndex:lineNumber] unsignedIntegerValue], selectedLineRange))
        return @{ NSFontAttributeName : [NSFont userFixedPitchFontOfSize:[NSFont systemFontSizeForControlSize:NSMiniControlSize]], NSForegroundColorAttributeName : [NSColor blackColor], NSParagraphStyleAttributeName : [NSParagraphStyle WC_rightAlignedParagraphStyle] };
    
    return @{ NSFontAttributeName : [NSFont userFixedPitchFontOfSize:[NSFont systemFontSizeForControlSize:NSMiniControlSize]], NSForegroundColorAttributeName : [NSColor WC_colorWithHexadecimalString:@"929292"], NSParagraphStyleAttributeName : [NSParagraphStyle WC_rightAlignedParagraphStyle] };
}

- (void)_calculateLineStartIndexes; {
	[self _calculateLineStartIndexesStartingAtLineNumber:0];
}

- (void)_calculateLineStartIndexesStartingAtLineNumber:(NSUInteger)lineNumber; {
	NSUInteger characterIndex = [[_lineStartIndexes objectAtIndex:lineNumber] unsignedIntegerValue], stringLength = self.textView.string.length, lineEnd, contentEnd;
	
	[_lineStartIndexes removeObjectsInRange:NSMakeRange(lineNumber, _lineStartIndexes.count - lineNumber)];
	
	do {
		[_lineStartIndexes addObject:@(characterIndex)];
		
		characterIndex = NSMaxRange([self.textView.string lineRangeForRange:NSMakeRange(characterIndex, 0)]);
		
	} while (characterIndex < stringLength);
	
	[self.textView.string getLineStart:NULL end:&lineEnd contentsEnd:&contentEnd forRange:NSMakeRange([_lineStartIndexes.lastObject unsignedIntegerValue], 0)];
    
	if (contentEnd < lineEnd)
		[_lineStartIndexes addObject:@(characterIndex)];
}

- (NSTextView *)textView {
    return (NSTextView *)self.clientView;
}

- (NSMutableArray *)lineStartIndexes {
    if (self.shouldRecalculateLineStartIndexes) {
		[self setShouldRecalculateLineStartIndexes:NO];
		
		[self _calculateLineStartIndexesStartingAtLineNumber:self.lineNumberToRecalculateFrom];
	}
    return _lineStartIndexes;
}

- (void)_textStorageDidProcessEditing:(NSNotification *)note {
    if (([note.object editedMask] & NSTextStorageEditedCharacters) == 0)
        return;
    
    NSUInteger lineNumber = [self.lineStartIndexes WC_lineNumberForRange:[note.object editedRange]];
    
    [self setLineNumberToRecalculateFrom:lineNumber];
    [self setShouldRecalculateLineStartIndexes:YES];
    [self setNeedsDisplay:YES];
}

- (void)_textViewDidChangeSelection:(NSNotification *)note {
    [self setNeedsDisplay:YES];
}
- (void)_viewFrameDidChange:(NSNotification *)note {
    [self setNeedsDisplay:YES];
}

@end
