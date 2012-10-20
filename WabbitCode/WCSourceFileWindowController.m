//
//  WCSourceFileWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 9/27/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCSourceFileWindowController.h"
#import "WCSourceFileDocument.h"
#import "WCTextViewController.h"
#import "WCTextStorage.h"
#import "WCSymbolHighlighter.h"
#import "WCDefines.h"
#import "NSTextView+WCExtensions.h"
#import "WCTextView.h"
#import "NSEvent+WCExtensions.h"
#import "WCExtendedAttributesManager.h"
#import "NSView+WCExtensions.h"
#import "WCJumpInWindowController.h"

@interface WCSourceFileWindowController () <WCTextViewControllerDelegate,NSSplitViewDelegate,NSUserInterfaceValidations,NSWindowDelegate>

@property (readonly,nonatomic) WCSourceFileDocument *sourceFileDocument;
@property (strong,nonatomic) WCTextViewController *textViewController;
@property (strong,nonatomic) WCTextViewController *assistantTextViewController;
@property (weak,nonatomic) WCTextStorage *textStorage;
@property (strong,nonatomic) NSMutableSet *assistantSplitViews;
@property (strong,nonatomic) NSMutableSet *assistantTextViewControllers;

- (void)_addAssistantEditorForTextViewController:(WCTextViewController *)currentTextViewController;
- (void)_removeAssistantEditorForTextViewController:(WCTextViewController *)currentTextViewController;
@end

@implementation WCSourceFileWindowController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)windowNibName {
    return @"WCSourceFileWindow";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.window setDelegate:self];
    
    [self setTextViewController:[[WCTextViewController alloc] initWithTextStorage:self.textStorage]];
    [self.textViewController setDelegate:self];
    [self.textViewController.view setFrame:[self.window.contentView bounds]];
    [self.textViewController setShowAddRemoveAssistantEditorButtons:NO];
    [self.window.contentView addSubview:self.textViewController.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowWillStartLiveResize:) name:NSWindowWillStartLiveResizeNotification object:self.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowDidEndLiveResize:) name:NSWindowDidEndLiveResizeNotification object:self.window];
    
    if (self.sourceFileDocument.fileURL) {
        NSString *selectedRangeString = [[WCExtendedAttributesManager sharedManager] stringForAttribute:WCSourceFileDocumentSelectedRangeAttributeName atURL:self.sourceFileDocument.fileURL];
        
        [self.textViewController.textView WC_setSelectedRangeSafely:NSRangeFromString(selectedRangeString)];
        [self.textViewController.textView scrollRangeToVisible:self.textViewController.textView.selectedRange];
    }
}
#pragma mark NSValidatedUserInterfaceItem
- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)item {
    if ([item action] == @selector(addAssistantEditorAction:)) {
        return (self.assistantTextViewControllers.count >= 1);
    }
    else if ([item action] == @selector(removeAssistantEditorAction:)) {
        return (self.assistantTextViewControllers.count >= 2);
    }
    else if ([item action] == @selector(jumpInAction:)) {
        if ([(id<NSObject>)item isKindOfClass:[NSMenuItem class]]) {
            NSMenuItem *menuItem = (NSMenuItem *)item;
            
            [menuItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Jump in \"%@\"\u2026", nil),self.sourceFileDocument.displayName]];
        }
    }
    return YES;
}
#pragma mark NSWindowDelegate
- (void)windowWillClose:(NSNotification *)notification {
    for (WCTextViewController *viewController in self.assistantTextViewControllers)
        [viewController cleanup];
    
    [self.textViewController cleanup];
}

#pragma mark NSSplitViewDelegate
- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    return NO;
}
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if ([self.assistantSplitViews containsObject:splitView]) {
        CGFloat amount = (splitView.isVertical) ? NSWidth(splitView.frame) : NSHeight(splitView.frame);
        
        return proposedMinimumPosition + floor(amount * 0.25);
    }
    return proposedMinimumPosition;
}
- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if ([self.assistantSplitViews containsObject:splitView]) {
        CGFloat amount = (splitView.isVertical) ? NSWidth(splitView.frame) : NSHeight(splitView.frame);
        
        return proposedMaximumPosition - floor(amount * 0.25);
    }
    return proposedMaximumPosition;
}

#pragma mark WCTextViewControllerDelegate
- (WCSymbolScanner *)symbolScannerForTextViewController:(WCTextViewController *)textViewController {
    return self.sourceFileDocument.symbolScanner;
}
- (WCFoldScanner *)foldScannerForTextViewController:(WCTextViewController *)textViewController {
    return self.sourceFileDocument.foldScanner;
}
- (WCSymbolHighlighter *)symbolHighlighterForTextViewController:(WCTextViewController *)textViewController {
    return self.sourceFileDocument.symbolHighlighter;
}
- (NSDocument *)documentForTextViewController:(WCTextViewController *)textViewController {
    return self.document;
}
- (NSUndoManager *)undoManagerForTextViewController:(WCTextViewController *)textViewController {
    return self.sourceFileDocument.undoManager;
}

- (void)addAssistantEditorForTextViewController:(WCTextViewController *)textViewController {
    [self _addAssistantEditorForTextViewController:textViewController];
}
- (void)removeAssistantEditorForTextViewController:(WCTextViewController *)textViewController {
    [self _removeAssistantEditorForTextViewController:textViewController];
}
#pragma mark *** Public Methods ***
- (id)initWithTextStorage:(WCTextStorage *)textStorage; {
    if (!(self = [super initWithWindowNibName:self.windowNibName]))
        return nil;
    
    [self setTextStorage:textStorage];
    [self setAssistantSplitViews:[NSMutableSet setWithCapacity:0]];
    [self setAssistantTextViewControllers:[NSMutableSet setWithCapacity:0]];
    
    return self;
}

#pragma mark Actions
- (IBAction)showStandardEditorAction:(id)sender; {
    if (self.assistantSplitViews.count == 0) {
        [self.textViewController.textView WC_makeFirstResponder];
        return;
    }
    
    for (WCTextViewController *textViewController in self.assistantTextViewControllers)
        [textViewController cleanup];
    for (NSSplitView *splitView in self.assistantSplitViews)
        [splitView removeFromSuperviewWithoutNeedingDisplay];
    [self.assistantSplitViews removeAllObjects];
    [self.assistantTextViewControllers removeAllObjects];
    [self setAssistantTextViewController:nil];
    
    [self.textViewController.view setFrame:[self.window.contentView bounds]];
    [self.window.contentView addSubview:self.textViewController.view];
    
    [self.textViewController.textView WC_makeFirstResponder];
}

- (IBAction)showAssistantEditorAction:(id)sender; {
    if (self.assistantTextViewController) {
        [self.assistantTextViewController.textView WC_makeFirstResponder];
        return;
    }
    
    BOOL vertical = NO;
    NSSplitView *splitView = [[NSSplitView alloc] initWithFrame:[self.window.contentView bounds]];
    
    [splitView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [splitView setVertical:vertical];
    [splitView setDividerStyle:(vertical)?NSSplitViewDividerStyleThin:NSSplitViewDividerStylePaneSplitter];
    [splitView setDelegate:self];
    
    [self.assistantSplitViews addObject:splitView];
    
    WCTextViewController *textViewController = [[WCTextViewController alloc] initWithTextStorage:self.textStorage];
    
    [textViewController setDelegate:self];
    
    [self.assistantTextViewControllers addObject:textViewController];
    [self setAssistantTextViewController:textViewController];
    
    [splitView addSubview:self.textViewController.view];
    [splitView addSubview:textViewController.view];
    [splitView adjustSubviews];
    
    CGFloat amount = (vertical) ? NSWidth(splitView.frame) : NSHeight(splitView.frame);
    
    [splitView setPosition:floor((amount - splitView.dividerThickness) * 0.5) ofDividerAtIndex:0];
    
    [self.window.contentView addSubview:splitView];
    
    [self.assistantTextViewController.textView WC_makeFirstResponder];
}
- (IBAction)addAssistantEditorAction:(id)sender; {
    [self _addAssistantEditorForTextViewController:self.currentAssistantTextViewController];
}
- (IBAction)removeAssistantEditorAction:(id)sender; {
    [self _removeAssistantEditorForTextViewController:self.currentAssistantTextViewController];
}
- (IBAction)resetEditorAction:(id)sender; {
    // TODO: what should this method do? what exactly does Xcode do?
}

- (IBAction)jumpInAction:(id)sender; {
    [[WCJumpInWindowController sharedWindowController] showJumpInWindowForTextView:self.currentTextViewController.textView];
}
#pragma mark Properties
- (WCTextViewController *)currentTextViewController {
    id firstResponder = self.window.firstResponder;
    
    if (![firstResponder isKindOfClass:[NSView class]])
        return nil;
    
    NSView *view = (NSView *)firstResponder;
    
    if ([view isDescendantOf:self.textViewController.view])
        return self.textViewController;
    else  {
        for (WCTextViewController *textViewController in self.assistantTextViewControllers) {
            if ([view isDescendantOf:textViewController.view])
                return textViewController;
        }
    }
    return self.textViewController;
}
- (WCTextViewController *)currentAssistantTextViewController {
    WCTextViewController *retval = self.currentTextViewController;
    
    if (retval == self.textViewController)
        retval = self.assistantTextViewController;
    
    return retval;
}

#pragma mark *** Private Methods ***
- (void)_addAssistantEditorForTextViewController:(WCTextViewController *)currentTextViewController; {
    NSSplitView *currentSplitView = (NSSplitView *)currentTextViewController.view.superview;
    
    BOOL vertical = [NSEvent WC_isOptionKeyPressed];
    NSSplitView *splitView = [[NSSplitView alloc] initWithFrame:currentTextViewController.view.bounds];
    
    [splitView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [splitView setVertical:vertical];
    [splitView setDividerStyle:(vertical)?NSSplitViewDividerStyleThin:NSSplitViewDividerStylePaneSplitter];
    [splitView setDelegate:self];
    
    [self.assistantSplitViews addObject:splitView];
    
    WCTextViewController *textViewController = [[WCTextViewController alloc] initWithTextStorage:self.textStorage];
    
    [textViewController setDelegate:self];
    
    [self.assistantTextViewControllers addObject:textViewController];
    
    [splitView addSubview:currentTextViewController.view];
    [splitView addSubview:textViewController.view];
    [splitView adjustSubviews];
    
    CGFloat amount = (vertical) ? NSWidth(splitView.frame) : NSHeight(splitView.frame);
    
    [splitView setPosition:floor((amount - splitView.dividerThickness) * 0.5) ofDividerAtIndex:0];
    
    [currentSplitView addSubview:splitView];
    
    [textViewController.textView WC_makeFirstResponder];
}
- (void)_removeAssistantEditorForTextViewController:(WCTextViewController *)currentTextViewController; {
    if (currentTextViewController == self.assistantTextViewController &&
        self.assistantTextViewControllers.count == 1) {
        
        [self showStandardEditorAction:nil];
        return;
    }
    
    WCTextViewController *textViewController;
    
    NSSplitView *currentSplitView = (NSSplitView *)currentTextViewController.view.superview;
    NSSplitView *parentSplitView = (NSSplitView *)currentSplitView.superview;
    
    for (NSView *view in currentSplitView.subviews) {
        if ([view WC_viewController] != currentTextViewController) {
            textViewController = (WCTextViewController *)[view WC_viewController];
            break;
        }
    }
    
    WCAssert(textViewController,@"textViewController cannot be nil!");
    
    [currentSplitView removeFromSuperviewWithoutNeedingDisplay];
    [currentTextViewController cleanup];
    
    [parentSplitView addSubview:textViewController.view];
    
    [textViewController.textView WC_makeFirstResponder];
    
    [self.assistantSplitViews removeObject:currentSplitView];
    [self.assistantTextViewControllers removeObject:currentTextViewController];
    
    if (currentTextViewController == self.assistantTextViewController)
        [self setAssistantTextViewController:textViewController];
}
#pragma mark Properties
- (WCSourceFileDocument *)sourceFileDocument {
    return (WCSourceFileDocument *)self.document;
}

#pragma mark Notifications
- (void)_windowWillStartLiveResize:(NSNotification *)note {

}
- (void)_windowDidEndLiveResize:(NSNotification *)note {
    WCSymbolHighlighter *symbolHighlighter = self.sourceFileDocument.symbolHighlighter;
    
    [symbolHighlighter symbolHighlightInRange:[self.textViewController.textView WC_visibleRange]];
}

@end
