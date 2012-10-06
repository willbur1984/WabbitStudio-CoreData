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

@interface WCSourceFileWindowController () <WCTextViewControllerDelegate,NSSplitViewDelegate>

@property (readonly,nonatomic) WCSourceFileDocument *sourceFileDocument;
@property (strong,nonatomic) WCTextViewController *textViewController;
@property (strong,nonatomic) WCTextViewController *assistantTextViewController;
@property (weak,nonatomic) WCTextStorage *textStorage;
@property (strong,nonatomic) NSSplitView *splitView;

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
    
    [self setSplitView:[[NSSplitView alloc] initWithFrame:NSZeroRect]];
    [self.splitView setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
    [self.splitView setDelegate:self];
    
    [self setTextViewController:[[WCTextViewController alloc] initWithTextStorage:self.textStorage]];
    [self.textViewController setDelegate:self];
    [self.textViewController.view setFrame:[self.window.contentView bounds]];
    [self.window.contentView addSubview:self.textViewController.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowWillStartLiveResize:) name:NSWindowWillStartLiveResizeNotification object:self.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowDidEndLiveResize:) name:NSWindowDidEndLiveResizeNotification object:self.window];
}
#pragma mark NSSplitViewDelegate
- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    return NO;
}
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return proposedMinimumPosition + floor(NSHeight(splitView.frame) * 0.25);
}
- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return proposedMaximumPosition - floor(NSHeight(splitView.frame) * 0.25);
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
- (NSString *)displayNameForTextViewController:(WCTextViewController *)textViewController {
    return self.sourceFileDocument.displayName;
}
- (NSURL *)fileURLForTextViewController:(WCTextViewController *)textViewController {
    return self.sourceFileDocument.fileURL;
}
- (NSUndoManager *)undoManagerForTextViewController:(WCTextViewController *)textViewController {
    return self.sourceFileDocument.undoManager;
}
#pragma mark *** Public Methods ***
- (id)initWithTextStorage:(WCTextStorage *)textStorage; {
    if (!(self = [super initWithWindowNibName:self.windowNibName]))
        return nil;
    
    [self setTextStorage:textStorage];
    
    return self;
}

#pragma mark Actions
- (IBAction)showStandardEditorAction:(id)sender; {
    
}
- (IBAction)showRelatedItemsAction:(id)sender; {
    
}
- (IBAction)showDocumentItemsAction:(id)sender; {
    
}

- (IBAction)showAssistantEditorAction:(id)sender; {
    if (self.assistantTextViewController) {
        if ([self.assistantTextViewController.textView acceptsFirstResponder])
            [self.window makeFirstResponder:self.assistantTextViewController.textView];
        return;
    }
    
    [self.splitView setFrame:[self.window.contentView bounds]];
    [self.splitView setDividerStyle:NSSplitViewDividerStylePaneSplitter];
    
    [self setAssistantTextViewController:[[WCTextViewController alloc] initWithTextStorage:self.textStorage]];
    [self.assistantTextViewController setDelegate:self];
    
    [self.splitView addSubview:self.textViewController.view];
    [self.splitView addSubview:self.assistantTextViewController.view];
    [self.splitView adjustSubviews];
    [self.splitView setPosition:floor((NSHeight(self.splitView.frame) - self.splitView.dividerThickness) * 0.5) ofDividerAtIndex:0];
    
    [self.window.contentView addSubview:self.splitView];
    
    if ([self.assistantTextViewController.textView acceptsFirstResponder])
        [self.window makeFirstResponder:self.assistantTextViewController.textView];
}
- (IBAction)addAssistantEditorAction:(id)sender; {
    
}
- (IBAction)removeAssistantEditorAction:(id)sender; {
    
}
- (IBAction)resetEditorAction:(id)sender; {
    
}
#pragma mark Properties
- (WCTextViewController *)currentTextViewController {
    id firstResponder = self.window.firstResponder;
    
    if (![firstResponder isKindOfClass:[NSView class]])
        return nil;
    
    NSView *view = (NSView *)firstResponder;
    
    if ([view isDescendantOf:self.textViewController.view])
        return self.textViewController;
    else if ([view isDescendantOf:self.assistantTextViewController.view])
        return self.assistantTextViewController;
    else
        return nil;
}

#pragma mark *** Private Methods ***
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
