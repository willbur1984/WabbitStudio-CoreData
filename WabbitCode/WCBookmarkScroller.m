//
//  WCBookmarkScroller.m
//  WabbitStudio
//
//  Created by William Towe on 10/1/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCBookmarkScroller.h"
#import "WCBookmarkManager.h"
#import "Bookmark.h"
#import "WCDefines.h"

@implementation WCBookmarkScroller

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(NSRect)frameRect {
    if (!(self = [super initWithFrame:frameRect]))
        return nil;
    
    [self setEnabled:YES];
    
    return self;
}

- (void)setNeedsDisplayInRect:(NSRect)invalidRect {
    [super setNeedsDisplayInRect:self.bounds];
}

- (void)drawKnobSlotInRect:(NSRect)slotRect highlight:(BOOL)flag {
    [super drawKnobSlotInRect:slotRect highlight:flag];
    
    NSArray *bookmarks = [[self.delegate bookmarkManagerForBookmarkScroller:self] bookmarksSortedByLocation];
    
    if (bookmarks.count > 0) {
        NSTextView *textView = [self.delegate textViewForBookmarkScroller:self];
        CGFloat scaleY = NSHeight(textView.frame) / NSHeight(self.frame);
        
        for (Bookmark *bookmark in bookmarks) {
            NSRect lineRect = [textView.layoutManager lineFragmentRectForGlyphAtIndex:[textView.layoutManager glyphIndexForCharacterAtIndex:bookmark.location.integerValue] effectiveRange:NULL];
            NSRect bookmarkRect = NSInsetRect(NSMakeRect(NSMinX(slotRect), NSMinY(slotRect) + floor(NSMinY(lineRect) / scaleY), NSWidth(slotRect), 1), 1, 0);
            
            [[NSColor blueColor] setFill];
            NSRectFill(bookmarkRect);
        }
    }
}

- (void)setDelegate:(id<WCBookmarkScrollerDelegate>)delegate {
    _delegate = delegate;
    
    if (delegate) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_bookmarkManagerDidAddBookmark:) name:WCBookmarkManagerDidAddBookmarkNotification object:[delegate bookmarkManagerForBookmarkScroller:self]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_bookmarkManagerDidRemoveBookmark:) name:WCBookmarkManagerDidRemoveBookmarkNotification object:[delegate bookmarkManagerForBookmarkScroller:self]];
    }
}

- (void)_bookmarkManagerDidAddBookmark:(NSNotification *)note {
    [self setNeedsDisplay:YES];
}
- (void)_bookmarkManagerDidRemoveBookmark:(NSNotification *)note {
    [self setNeedsDisplay:YES];
}

@end
