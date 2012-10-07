//
//  NSTextView+WCExtensions.m
//  WabbitEdit
//
//  Created by William Towe on 12/23/11.
//  Copyright (c) 2011 Revolution Software.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "NSTextView+WCExtensions.h"

@implementation NSTextView (WCExtensions)
- (NSRange)WC_visibleRange; {
	if (![[self string] length])
		return NSMakeRange(0, 0);
	
	NSRect visibleRect = [self visibleRect];
	NSRange visibleRange = [[self layoutManager] glyphRangeForBoundingRect:visibleRect inTextContainer:[self textContainer]];
	NSRange charRange = [[self layoutManager] characterRangeForGlyphRange:visibleRange actualGlyphRange:NULL];
	NSUInteger firstChar = [[self string] lineRangeForRange:NSMakeRange(charRange.location, 0)].location;
	NSUInteger lastChar = NSMaxRange([[self string] lineRangeForRange:NSMakeRange(NSMaxRange(charRange), 0)]);
	
	return NSMakeRange(firstChar, lastChar-firstChar);
}

- (void)WC_setSelectedRangeSafely:(NSRange)range; {
    if (NSMaxRange(range) >= self.string.length) {
        [self setSelectedRange:NSMakeRange(self.string.length, 0)];
        return;
    }
    
    [self setSelectedRange:range];
}

- (void)WC_appendString:(NSString *)string; {
    [self replaceCharactersInRange:NSMakeRange(self.string.length, 0) withString:string];
}
- (void)WC_appendAttributedString:(NSAttributedString *)attributedString; {
    [self.textStorage replaceCharactersInRange:NSMakeRange(self.string.length, 0) withAttributedString:attributedString];
}

- (void)WC_appendNewline; {
    [self replaceCharactersInRange:NSMakeRange(self.string.length, 0) withString:@"\n"];
}
@end
