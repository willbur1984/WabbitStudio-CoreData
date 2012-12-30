//
//  WCEditorFocusCell.m
//  WabbitStudio
//
//  Created by William Towe on 12/26/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCEditorFocusCell.h"
#import "NSColor+WCExtensions.h"
#import "NSBezierPath+StrokeExtensions.h"
#import "WCTabViewController.h"
#import "MMTabBarView.h"
#import "WCDefines.h"
#import "WCStandardTextViewController.h"
#import "WCTextView.h"
#import "NSBezierPath+MCAdditions.h"
#import "NSShadow+MCAdditions.h"

@interface WCEditorFocusCell ()

@end

@implementation WCEditorFocusCell

- (id)initWithFrame:(NSRect)frameRect {
    if (!(self = [super initWithFrame:frameRect]))
        return nil;
    
    [self setWantsLayer:YES];
    
    CGColorRef color = [[NSColor blackColor] WC_CGColorCreate];
    
    [self.layer setShadowColor:color];
    
    CGColorRelease(color);
    
    [self.layer setShadowOffset:CGSizeZero];
    [self.layer setShadowOpacity:0.75];
    [self.layer setShadowRadius:5];
    [self.layer setMasksToBounds:NO];
    
    _selectedTabIndex = -1;
    _highlightedTabIndex = -1;
    _highlightedTextViewControllerIndex = -1;
    
    return self;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}
- (BOOL)becomeFirstResponder {
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent {
    [self interpretKeyEvents:@[theEvent]];
}
- (void)moveLeft:(id)sender {
    if (self.highlightedTabIndex != -1) {
        NSInteger temp = MAX(0, self.highlightedTabIndex - 1);
        
        [self setHighlightedTabIndex:temp];
        [self setSelectedTabIndex:temp];
    }
}
- (void)moveRight:(id)sender {
    if (self.highlightedTabIndex != -1) {
        NSUInteger numberOfTabs = self.tabViewController.tabBarView.numberOfTabViewItems;
        NSInteger temp = MIN(numberOfTabs - 1, self.highlightedTabIndex + 1);
        
        [self setHighlightedTabIndex:temp];
        [self setSelectedTabIndex:temp];
    }
}
- (void)moveUp:(id)sender {
    if (self.highlightedTextViewControllerIndex == 0) {
        [self setHighlightedTabIndex:self.selectedTabIndex];
        [self setHighlightedTextViewControllerIndex:-1];
    }
    else {
        NSInteger temp = MAX(-1, self.highlightedTextViewControllerIndex - 1);
        
        [self setHighlightedTextViewControllerIndex:temp];
    }
}
- (void)moveDown:(id)sender {
    if (self.highlightedTextViewControllerIndex == -1) {
        [self setHighlightedTabIndex:-1];
        [self setHighlightedTextViewControllerIndex:0];
    }
    else {
        WCStandardTextViewController *textViewController = [self.tabViewController standardTextViewControllerForTabViewItemAtIndex:self.selectedTabIndex];
        NSUInteger numberOfTextViewControllers = [textViewController.textViewControllers count];
        NSInteger temp = MIN(numberOfTextViewControllers - 1, self.highlightedTextViewControllerIndex + 1);
        
        [self setHighlightedTextViewControllerIndex:temp];
    }
}
- (void)insertNewline:(id)sender {
    if ([self.delegate respondsToSelector:@selector(editorFocusCellDidPressReturn:)])
        [self.delegate editorFocusCellDidPressReturn:self];
}
- (void)mouseDown:(NSEvent *)theEvent {
    if (theEvent.clickCount == 2) {
        if ([self.delegate respondsToSelector:@selector(editorFocusCellDidDoubleClick:)])
            [self.delegate editorFocusCellDidDoubleClick:self];
    }
    else {
        
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    // TODO: draw according to the split views, so it looks like xcodes view
    
    static NSGradient *gradient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gradient = [[NSGradient alloc] initWithStartingColor:[NSColor WC_colorWithHexadecimalString:@"6a6a6a"] endingColor:[NSColor WC_colorWithHexadecimalString:@"262626"]];
    });
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:5 yRadius:5];
    
    [gradient drawInBezierPath:path angle:-90];
    
    [path addClip];
    
    NSUInteger numberOfTabs = self.tabViewController.tabBarView.numberOfTabViewItems;
    
    if (numberOfTabs > 0) {
        CGFloat width = ceil(NSWidth(self.frame) / (CGFloat)numberOfTabs);
        const CGFloat height = 20;
        CGFloat frameX = NSMinX(self.bounds) + width;
        
        for (NSUInteger index=0; index<numberOfTabs; index++) {
            if (self.highlightedTabIndex == index) {
                [[NSColor alternateSelectedControlColor] setFill];
                NSRectFill(NSMakeRect(frameX - width + 1, NSMaxY(self.bounds) - height, width - 1, height));
            }
            if (self.selectedTabIndex == index) {
                [[NSBezierPath bezierPathWithRect:NSMakeRect(frameX - width + 1, NSMaxY(self.bounds) - height, width - 1, height)] fillWithInnerShadow:[[NSShadow alloc] initWithColor:[NSColor blackColor] offset:NSZeroSize blurRadius:15]];
            }
            
            [[NSColor blackColor] setFill];
            NSRectFill(NSMakeRect(frameX, NSMaxY(self.bounds) - height, 1, height));
            
            frameX += width;
        }
        
        [[NSColor blackColor] setFill];
        NSRectFill(NSMakeRect(NSMinX(self.bounds), NSMaxY(self.bounds) - height, NSWidth(self.frame), 1));

        NSArray *textViewControllers = [self.tabViewController standardTextViewControllerForTabViewItemAtIndex:self.selectedTabIndex].textViewControllers;
        CGFloat tvcHeight = ceil((NSHeight(self.frame) - height) / (CGFloat)textViewControllers.count);
        CGFloat frameY = NSMaxY(self.bounds) - height - tvcHeight;
        
        for (NSUInteger index=0; index<textViewControllers.count; index++) {
            if (self.highlightedTextViewControllerIndex == index) {
                [[NSColor alternateSelectedControlColor] setFill];
                NSRectFill(NSMakeRect(NSMinX(self.bounds), frameY, NSWidth(self.frame), tvcHeight));
            }
            
            [[NSColor blackColor] setFill];
            NSRectFill(NSMakeRect(NSMinX(self.bounds), frameY, NSWidth(self.frame), 1));
            
            frameY -= tvcHeight;
        }
    }
    
    [[NSColor whiteColor] setStroke];
    [path strokeInside];
}

- (void)setTabViewController:(WCTabViewController *)tabViewController {
    _tabViewController = tabViewController;
    
    if (tabViewController.tabBarView.numberOfTabViewItems == 0) {
        [self setSelectedTabIndex:-1];
        [self setHighlightedTabIndex:-1];
        [self setHighlightedTextViewControllerIndex:-1];
    }
    else {
        [self setSelectedTabIndex:[tabViewController.tabBarView.tabView indexOfTabViewItem:tabViewController.tabBarView.tabView.selectedTabViewItem]];
        [self setHighlightedTabIndex:-1];
        [self setHighlightedTextViewControllerIndex:0];
    }
    
    [self setNeedsDisplay:YES];
}
- (void)setSelectedTabIndex:(NSInteger)selectedTabIndex {
    _selectedTabIndex = selectedTabIndex;
    
    if ([self.delegate respondsToSelector:@selector(editorFocusCell:didChangeSelectedTabIndex:)])
        [self.delegate editorFocusCell:self didChangeSelectedTabIndex:selectedTabIndex];
    
    [self setNeedsDisplay:YES];
}
- (void)setHighlightedTabIndex:(NSInteger)highlightedTabIndex {
    _highlightedTabIndex = highlightedTabIndex;
    
    [self setNeedsDisplay:YES];
}
- (void)setHighlightedTextViewControllerIndex:(NSInteger)highlightedTextViewControllerIndex {
    _highlightedTextViewControllerIndex = highlightedTextViewControllerIndex;
    
    [self setNeedsDisplay:YES];
}

@end
