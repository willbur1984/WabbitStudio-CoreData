//
//  WCStandardTextViewController.m
//  WabbitStudio
//
//  Created by William Towe on 12/27/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCStandardTextViewController.h"
#import "NSEvent+WCExtensions.h"
#import "NSView+WCExtensions.h"
#import "WCTextView.h"
#import "WCDefines.h"

@interface WCStandardTextViewController () <WCTextViewControllerDelegate,NSSplitViewDelegate>
@property (strong,nonatomic) NSMutableOrderedSet *assistantTextViewControllers;
@property (strong,nonatomic) NSMutableOrderedSet *assistantSplitViews;
@property (readonly,nonatomic) WCTextViewController *currentTextViewController;
@property (readonly,nonatomic) WCTextViewController *currentAssistantTextViewController;

- (void)_addAssistantEditorForTextViewController:(WCTextViewController *)textViewController;
- (void)_removeAssistantEditorForTextViewController:(WCTextViewController *)textViewController;
@end

@implementation WCStandardTextViewController

- (void)cleanup {
    [super cleanup];
    
    for (WCTextViewController *textViewController in self.assistantTextViewControllers)
        [textViewController cleanup];
}

- (id)initWithSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument {
    if (!(self = [super initWithSourceFileDocument:sourceFileDocument]))
        return nil;
    
    [self setShowAddRemoveAssistantEditorButtons:NO];
    [self setAssistantSplitViews:[NSMutableOrderedSet orderedSetWithCapacity:0]];
    [self setAssistantTextViewControllers:[NSMutableOrderedSet orderedSetWithCapacity:0]];
    
    return self;
}

- (void)addAssistantEditorForTextViewController:(WCTextViewController *)textViewController {
    [self _addAssistantEditorForTextViewController:textViewController];
}
- (void)removeAssistantEditorForTextViewController:(WCTextViewController *)textViewController {
    [self _removeAssistantEditorForTextViewController:textViewController];
}

- (IBAction)showStandardEditorAction:(id)sender; {
    if (self.assistantTextViewControllers.count == 0) {
        [self.textView WC_makeFirstResponder];
        return;
    }
    
    for (WCTextViewController *textViewController in self.assistantTextViewControllers)
        [textViewController cleanup];
    for (NSSplitView *splitView in self.assistantSplitViews)
        [splitView removeFromSuperviewWithoutNeedingDisplay];
    
    [self.assistantSplitViews removeAllObjects];
    [self.assistantTextViewControllers removeAllObjects];
    
    [self.containerView setFrame:self.view.bounds];
    [self.view addSubview:self.containerView];
    
    [self.textView WC_makeFirstResponder];
}
- (IBAction)showAssistantEditorAction:(id)sender; {
    if (self.assistantTextViewControllers.count > 0) {
        [[[self.assistantTextViewControllers objectAtIndex:0] textView] WC_makeFirstResponder];
        return;
    }
    
    BOOL vertical = [NSEvent WC_isOptionKeyPressed];
    NSSplitView *splitView = [[NSSplitView alloc] initWithFrame:self.containerView.bounds];
    
    [splitView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [splitView setVertical:vertical];
    [splitView setDividerStyle:(vertical) ? NSSplitViewDividerStyleThin : NSSplitViewDividerStylePaneSplitter];
    [splitView setDelegate:self];
    
    [self.assistantSplitViews addObject:splitView];
    
    WCTextViewController *textViewController = [[WCTextViewController alloc] initWithSourceFileDocument:self.sourceFileDocument];
    
    [textViewController setDelegate:self];
    
    [self.assistantTextViewControllers addObject:textViewController];
    
    [splitView addSubview:self.containerView];
    [splitView addSubview:textViewController.view];
    [splitView adjustSubviews];
    
    CGFloat amount = (vertical) ? NSWidth(splitView.frame) : NSHeight(splitView.frame);
    
    [splitView setPosition:floor((amount - splitView.dividerThickness) * 0.5) ofDividerAtIndex:0];
    
    [self.view addSubview:splitView];
    
    [textViewController.textView WC_makeFirstResponder];
}
- (IBAction)addAssistantEditorAction:(id)sender; {
    [self _addAssistantEditorForTextViewController:self.currentAssistantTextViewController];
}
- (IBAction)removeAssistantEditorAction:(id)sender; {
    [self _removeAssistantEditorForTextViewController:self.currentAssistantTextViewController];
}
- (IBAction)resetEditorAction:(id)sender; {
    
}

- (void)_addAssistantEditorForTextViewController:(WCTextViewController *)textViewController; {
    WCAssert(textViewController,@"textViewController cannot be nil!");
    
    NSSplitView *currentSplitView = (NSSplitView *)textViewController.view.superview;
    BOOL vertical = [NSEvent WC_isOptionKeyPressed];
    NSSplitView *splitView = [[NSSplitView alloc] initWithFrame:textViewController.view.bounds];
    
    [splitView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [splitView setVertical:vertical];
    [splitView setDividerStyle:(vertical) ? NSSplitViewDividerStyleThin : NSSplitViewDividerStylePaneSplitter];
    [splitView setDelegate:self];
    
    [self.assistantSplitViews insertObject:splitView atIndex:[self.assistantSplitViews indexOfObject:currentSplitView]];
    
    WCTextViewController *newTextViewController = [[WCTextViewController alloc] initWithSourceFileDocument:self.sourceFileDocument];
    
    [newTextViewController setDelegate:self];
    
    [self.assistantTextViewControllers insertObject:newTextViewController atIndex:[self.assistantTextViewControllers indexOfObject:textViewController] + 1];
    
    [splitView addSubview:newTextViewController.view];
    [splitView addSubview:textViewController.view];
    [splitView adjustSubviews];
    
    CGFloat amount = (vertical) ? NSWidth(splitView.frame) : NSHeight(splitView.frame);
    
    [splitView setPosition:floor((amount - splitView.dividerThickness) * 0.5) ofDividerAtIndex:0];
    [currentSplitView addSubview:splitView];
    
    [newTextViewController.textView WC_makeFirstResponder];
}
- (void)_removeAssistantEditorForTextViewController:(WCTextViewController *)textViewController; {
    if (self.assistantTextViewControllers.count == 1) {
        [self showStandardEditorAction:nil];
        return;
    }
    
    NSSplitView *currentSplitView = (NSSplitView *)textViewController.view.superview;
    NSSplitView *parentSplitView = (NSSplitView *)currentSplitView.superview;
    WCTextViewController *textViewControllerToKeep = nil;
    
    for (NSView *subview in currentSplitView.subviews) {
        if (textViewController != [subview WC_viewController])
            textViewControllerToKeep = (WCTextViewController *)[subview WC_viewController];
    }
    
    WCAssert(textViewControllerToKeep,@"tvc to keep cannot be nil!");
    
    [currentSplitView removeFromSuperviewWithoutNeedingDisplay];
    [textViewController cleanup];
    
    [parentSplitView addSubview:textViewControllerToKeep.view];
    
    [textViewControllerToKeep.textView WC_makeFirstResponder];
    
    [self.assistantSplitViews removeObject:currentSplitView];
    [self.assistantTextViewControllers removeObject:textViewController];
}
- (WCTextViewController *)currentTextViewController {
    id firstResponder = self.view.window.firstResponder;
    
    for (WCTextViewController *textViewController in self.assistantTextViewControllers) {
        if ([firstResponder isDescendantOf:textViewController.view])
            return textViewController;
    }
    
    return self;
}
- (WCTextViewController *)currentAssistantTextViewController {
    id firstResponder = self.view.window.firstResponder;
    
    for (WCTextViewController *textViewController in self.assistantTextViewControllers) {
        if ([firstResponder isDescendantOf:textViewController.view])
            return textViewController;
    }
    
    return self.assistantTextViewControllers.lastObject;
}

@end
