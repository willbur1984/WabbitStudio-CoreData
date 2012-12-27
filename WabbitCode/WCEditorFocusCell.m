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
#import "WCTextViewController.h"
#import "WCTextView.h"
#import "NSBezierPath+MCAdditions.h"
#import "NSShadow+MCAdditions.h"

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
    [self setNeedsDisplay:YES];
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent {
    [self interpretKeyEvents:@[theEvent]];
}
- (void)moveLeft:(id)sender {
    if (self.highlightedTabIndex != -1) {
        NSInteger temp = MAX(0, self.highlightedTabIndex - 1);
        
        [self setHighlightedTabIndex:temp];
    }
}
- (void)moveRight:(id)sender {
    if (self.highlightedTabIndex != -1) {
        NSUInteger numberOfTabs = self.tabViewController.tabBarView.numberOfTabViewItems;
        NSInteger temp = MIN(numberOfTabs - 1, self.highlightedTabIndex + 1);
        
        [self setHighlightedTabIndex:temp];
    }
}
- (void)moveUp:(id)sender {
    if (self.highlightedTextViewControllerIndex == 0) {
        [self setHighlightedTabIndex:0];
        [self setHighlightedTextViewControllerIndex:-1];
    }
}
- (void)moveDown:(id)sender {
    if (self.highlightedTextViewControllerIndex == -1) {
        [self setHighlightedTabIndex:-1];
        [self setHighlightedTextViewControllerIndex:0];
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
            else if (self.selectedTabIndex == index) {
                [[NSBezierPath bezierPathWithRect:NSMakeRect(frameX - width + 1, NSMaxY(self.bounds) - height, width - 1, height)] fillWithInnerShadow:[[NSShadow alloc] initWithColor:[NSColor blackColor] offset:NSZeroSize blurRadius:15]];
            }
            
            [[NSColor blackColor] setFill];
            NSRectFill(NSMakeRect(frameX, NSMaxY(self.bounds) - height, 1, height));
            
            frameX += width;
        }
        
        [[NSColor blackColor] setFill];
        NSRectFill(NSMakeRect(NSMinX(self.bounds), NSMaxY(self.bounds) - height, NSWidth(self.frame), 1));
        
        if (self.highlightedTabIndex == -1 && self.highlightedTextViewControllerIndex != -1) {
            [[NSColor alternateSelectedControlColor] setFill];
            NSRectFill(NSMakeRect(NSMinX(self.bounds), NSMinY(self.bounds), NSWidth(self.frame), NSHeight(self.frame) - height));
        }
    }
    
    [[NSColor whiteColor] setStroke];
    [path strokeInside];
}

- (void)setTabViewController:(WCTabViewController *)tabViewController {
    _tabViewController = tabViewController;
    
    if (tabViewController.tabBarView.numberOfTabViewItems == 0) {
        _selectedTabIndex = -1;
        _highlightedTabIndex = -1;
        _highlightedTextViewControllerIndex = -1;
    }
    else {
        _selectedTabIndex = [tabViewController.tabBarView.tabView indexOfTabViewItem:tabViewController.tabBarView.tabView.selectedTabViewItem];
        _highlightedTabIndex = -1;
        _highlightedTextViewControllerIndex = 0;
    }
    
    [self setNeedsDisplay:YES];
}
- (void)setSelectedTabIndex:(NSInteger)selectedTabIndex {
    _selectedTabIndex = selectedTabIndex;
    
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
