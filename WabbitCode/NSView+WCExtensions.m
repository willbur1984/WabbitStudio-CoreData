//
//  NSView+WCExtensions.m
//  WabbitStudio
//
//  Created by William Towe on 10/7/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "NSView+WCExtensions.h"
#import "NSObject+WCExtensions.h"
#import "WCViewController.h"

#include <objc/runtime.h>

@interface NSView (WCExtensions_Private)
+ (void)_loadSupportForViewControllers;

- (void)WC_viewWillMoveToSuperview:(NSView *)superview;
- (void)WC_viewDidMoveToSuperview;

- (void)WC_viewWillMoveToWindow:(NSWindow *)window;
- (void)WC_viewDidMoveToWindow;

- (void)WC_setNextResponder:(NSResponder *)nextResponder;
@end

@implementation NSView (WCExtensions_Private)
+ (void)_loadSupportForViewControllers; {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self WC_swapMethod:@selector(viewWillMoveToSuperview:) withMethod:@selector(WC_viewWillMoveToSuperview:)];
        [self WC_swapMethod:@selector(viewDidMoveToSuperview) withMethod:@selector(WC_viewDidMoveToSuperview)];
        
        [self WC_swapMethod:@selector(viewWillMoveToWindow:) withMethod:@selector(WC_viewWillMoveToWindow:)];
        [self WC_swapMethod:@selector(viewDidMoveToWindow) withMethod:@selector(WC_viewDidMoveToWindow)];
        
        [self WC_swapMethod:@selector(setNextResponder:) withMethod:@selector(WC_setNextResponder:)];
    });
}

- (void)WC_viewWillMoveToSuperview:(NSView *)superview; {
    [self WC_viewWillMoveToSuperview:superview];
    
    if ([self.WC_viewController isKindOfClass:[WCViewController class]]) {
        WCViewController *viewController = (WCViewController *)self.WC_viewController;
        
        if (superview) {
            [viewController viewWillMoveToSuperview:superview];
            
            if (self.window)
                [viewController viewWillAppear];
        }
        else {
            [viewController viewWillBeRemovedFromSuperview];
            
            if (self.superview && self.window)
                [viewController viewWillDisappear];
        }
    }
}
- (void)WC_viewDidMoveToSuperview; {
    [self WC_viewDidMoveToSuperview];
    
    if ([self.WC_viewController isKindOfClass:[WCViewController class]]) {
        WCViewController *viewController = (WCViewController *)self.WC_viewController;
        
        if (self.superview) {
            [viewController viewDidMoveToSuperview];
            
            if (self.window)
                [viewController viewDidAppear];
        }
        else {
            [viewController viewWasRemovedFromSuperview];
            
            if (self.window == nil)
                [viewController viewDidDisappear];
        }
    }
}

- (void)WC_viewWillMoveToWindow:(NSWindow *)window; {
    [self WC_viewWillMoveToWindow:window];
    
    if ([self.WC_viewController isKindOfClass:[WCViewController class]]) {
        WCViewController *viewController = (WCViewController *)self.WC_viewController;
        
        if (window) {
            [viewController viewWillMoveToWindow:window];
            
            if (self.superview)
                [viewController viewWillAppear];
        }
        else {
            [viewController viewWillBeRemovedFromWindow];
            
            if(self.superview && self.window)
                [viewController viewWillDisappear];
        }
    }
}
- (void)WC_viewDidMoveToWindow; {
    [self WC_viewDidMoveToWindow];
    
    if ([self.WC_viewController isKindOfClass:[WCViewController class]]) {
        WCViewController *viewController = (WCViewController *)self.WC_viewController;
     
        if (self.window) {
            [viewController viewDidMoveToWindow];
            
            if (self.superview)
                [viewController viewDidAppear];
        }
        else {
            [viewController viewWasRemovedFromWindow];
            
            if (self.superview == nil)
                [viewController viewDidDisappear];
        }
    }
}

- (void)WC_setNextResponder:(NSResponder *)nextResponder; {
    if (self.WC_viewController != nil) {
        [self.WC_viewController setNextResponder:nextResponder];
        return;
    }
    
    [self WC_setNextResponder:nextResponder];
}
@end

@implementation NSView (WCExtensions)

- (BOOL)WC_makeFirstResponder; {
    return (self.acceptsFirstResponder && [self.window makeFirstResponder:self]);
}

static char kViewControllerKey;

- (NSViewController *)WC_viewController; {
    return (NSViewController *)objc_getAssociatedObject(self, &kViewControllerKey);
}
- (void)WC_setViewController:(NSViewController *)viewController; {
    [self.class _loadSupportForViewControllers];
    
    if (self.WC_viewController != nil) {
        NSResponder *nextResponder = self.WC_viewController.nextResponder;
        
        [self WC_setNextResponder:nextResponder];
        [self.WC_viewController setNextResponder:nil];
    }
    
    objc_setAssociatedObject(self, &kViewControllerKey, viewController, OBJC_ASSOCIATION_ASSIGN);
    
    if (viewController != nil) {
        NSResponder *nextResponder = self.nextResponder;
        
        [self WC_setNextResponder:self.WC_viewController];
        [self.WC_viewController setNextResponder:nextResponder];
    }
}

- (NSArray *)WC_flattenedSubviews; {
    NSMutableOrderedSet *retval = [NSMutableOrderedSet orderedSetWithCapacity:0];
    
    for (NSView *subview in self.subviews) {
        [retval addObject:subview];
        [retval addObjectsFromArray:[subview WC_flattenedSubviews]];
    }
    
    return retval.array;
}

@end
