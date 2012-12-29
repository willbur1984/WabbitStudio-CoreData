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
#import "WCStandardTextViewController.h"
#import "WCTextStorage.h"
#import "WCSymbolHighlighter.h"
#import "WCDefines.h"
#import "NSTextView+WCExtensions.h"
#import "WCTextView.h"
#import "NSEvent+WCExtensions.h"
#import "WCExtendedAttributesManager.h"
#import "NSView+WCExtensions.h"

@interface WCSourceFileWindowController () <WCTextViewControllerDelegate,NSSplitViewDelegate,NSUserInterfaceValidations,NSWindowDelegate>

@property (readonly,nonatomic) WCSourceFileDocument *sourceFileDocument;
@property (strong,nonatomic) WCTextViewController *textViewController;
@property (weak,nonatomic) WCTextStorage *textStorage;

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
    
    [self setTextViewController:[[WCStandardTextViewController alloc] initWithSourceFileDocument:self.sourceFileDocument]];
    [self.textViewController setDelegate:self];
    [self.textViewController.view setFrame:[self.window.contentView bounds]];
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
    if ([item action] == @selector(jumpInAction:)) {
        if ([(id<NSObject>)item isKindOfClass:[NSMenuItem class]]) {
            NSMenuItem *menuItem = (NSMenuItem *)item;
            
            [menuItem setTitle:[NSString stringWithFormat:NSLocalizedString(@"Jump in \"%@\"\u2026", nil),self.sourceFileDocument.displayName]];
        }
    }
    return YES;
}
#pragma mark NSWindowDelegate
- (void)windowWillClose:(NSNotification *)notification {
    [self.textViewController cleanup];
}

#pragma mark WCTextViewControllerDelegate
- (void)addAssistantEditorForTextViewController:(WCTextViewController *)textViewController {

}
- (void)removeAssistantEditorForTextViewController:(WCTextViewController *)textViewController {

}
#pragma mark *** Public Methods ***
- (id)initWithTextStorage:(WCTextStorage *)textStorage; {
    if (!(self = [super initWithWindowNibName:self.windowNibName]))
        return nil;
    
    [self setTextStorage:textStorage];
    
    return self;
}

#pragma mark Actions


#pragma mark Properties
- (WCTextViewController *)currentTextViewController {
    return self.textViewController;
}
- (WCTextViewController *)currentAssistantTextViewController {
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
