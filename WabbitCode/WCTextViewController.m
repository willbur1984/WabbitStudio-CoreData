//
//  WCTextViewController.m
//  WabbitStudio
//
//  Created by William Towe on 9/21/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCTextViewController.h"
#import "WCTextView.h"
#import "WCFoldView.h"
#import "WCSyntaxHighlighter.h"
#import "WCJumpBarControl.h"
#import "WCDefines.h"
#import "WCJumpBarComponentCell.h"
#import "WCSymbolScanner.h"
#import "WCSymbolImageManager.h"
#import "WCArgumentPlaceholderCell.h"
#import "Symbol.h"
#import "NSArray+WCExtensions.h"
#import "File.h"
#import "NSURL+WCExtensions.h"
#import "WCGeometry.h"
#import "WCLayoutManager.h"
#import "WCTextStorage.h"
#import "WCSymbolHighlighter.h"
#import "NSTextView+WCExtensions.h"

@interface WCTextViewController () <WCTextViewDelegate,WCJumpBarControlDataSource,WCJumpBarControlDelegate,WCFoldViewDelegate,NSMenuDelegate>

@property (readwrite,assign,nonatomic) IBOutlet WCTextView *textView;
@property (weak,nonatomic) IBOutlet WCJumpBarControl *jumpBarControl;
@property (weak,nonatomic) IBOutlet NSPopUpButton *relatedFilesPopUpButton;

@property (weak,nonatomic) WCTextStorage *textStorage;

@property (strong,nonatomic) NSArray *jumpBarControlMenuSymbols;

@property (strong,nonatomic) NSArray *recentFileURLs;
@property (weak,nonatomic) NSMenu *recentFilesMenu;
@end

@implementation WCTextViewController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)nibName {
    return @"WCTextView";
}

- (void)loadView {
    [super loadView];
    
    // text view
    [self.textView.textContainer replaceLayoutManager:[[WCLayoutManager alloc] init]];
    [self.textView setTypingAttributes:[WCSyntaxHighlighter defaultAttributes]];
    [self.textView.layoutManager replaceTextStorage:self.textStorage];
    
    WCFoldView *lineNumberView = [[WCFoldView alloc] initWithTextView:self.textView];
    
    [lineNumberView setDelegate:self];
    
    [self.textView.enclosingScrollView setVerticalRulerView:lineNumberView];
    [self.textView.enclosingScrollView setHasHorizontalRuler:NO];
    [self.textView.enclosingScrollView setHasVerticalRuler:YES];
    [self.textView.enclosingScrollView setRulersVisible:YES];
    
    [self.textView setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidProcessEditing:) name:NSTextStorageDidProcessEditingNotification object:self.textStorage];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidFold:) name:WCTextStorageDidFoldNotification object:self.textStorage];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidUnfold:) name:WCTextStorageDidUnfoldNotification object:self.textStorage];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_viewBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:self.textView.enclosingScrollView.contentView];
    
    // jump bar control
    [self.jumpBarControl setDataSource:self];
    [self.jumpBarControl setDelegate:self];
    
    // related files pop up button
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"org.revsoft.text-view-controller.related-files-menu"];
    NSMenuItem *actionItem = [menu addItemWithTitle:@"" action:NULL keyEquivalent:@""];
    
    [actionItem setImage:[NSImage imageNamed:NSImageNameActionTemplate]];
    [actionItem setHidden:YES];
    
    NSMenuItem *recentFilesItem = [menu addItemWithTitle:NSLocalizedString(@"Recent Files", nil) action:NULL keyEquivalent:@""];
    NSMenu *recentFilesMenu = [[NSMenu alloc] initWithTitle:@"org.revsoft.text-view-controller.related-files.recent-files-menu"];
    
    [self setRecentFilesMenu:recentFilesMenu];
    [self.recentFilesMenu setDelegate:self];
    [recentFilesItem setSubmenu:self.recentFilesMenu];
    
    [self.relatedFilesPopUpButton setMenu:menu];
}

#pragma mark NSMenuDelegate
- (NSInteger)numberOfItemsInMenu:(NSMenu *)menu {
    if (menu == self.recentFilesMenu) {
        if (!self.recentFileURLs) {
            [self setRecentFileURLs:[[NSDocumentController sharedDocumentController] recentDocumentURLs]];
        }
        return self.recentFileURLs.count;
    }
    return 0;
}
- (BOOL)menu:(NSMenu *)menu updateItem:(NSMenuItem *)item atIndex:(NSInteger)index shouldCancel:(BOOL)shouldCancel {
    if (menu == self.recentFilesMenu) {
        NSURL *recentURL = [self.recentFileURLs objectAtIndex:index];
        
        [item setTitle:recentURL.lastPathComponent];
        [item setImage:[recentURL WC_effectiveIcon]];
        [item.image setSize:WC_NSSmallSize];
        [item setTarget:self];
        [item setTag:index];
        [item setAction:@selector(_recentFilesMenuItemAction:)];
    }
    return YES;
}

- (BOOL)menuHasKeyEquivalent:(NSMenu *)menu forEvent:(NSEvent *)event target:(__autoreleasing id *)target action:(SEL *)action {
    *target = nil;
    *action = NULL;
    return NO;
}
- (void)menu:(NSMenu *)menu willHighlightItem:(NSMenuItem *)item {
    if (menu == self.recentFilesMenu) {
        NSMenuItem *highlightedItem = menu.highlightedItem;
        
        [highlightedItem setRepresentedObject:nil];
        
        if (item) {
            NSURL *recentURL = [self.recentFileURLs objectAtIndex:item.tag];
            
            [item setRepresentedObject:recentURL];
        }
    }
}
- (void)menuDidClose:(NSMenu *)menu {
    [self setRecentFileURLs:nil];
}

#pragma mark NSTextViewDelegate
- (void)textViewDidChangeSelection:(NSNotification *)note {
    [self.jumpBarControl reloadSymbolPathComponentCell];
}

- (void)textView:(NSTextView *)textView clickedOnCell:(id<NSTextAttachmentCell>)cell inRect:(NSRect)cellFrame atIndex:(NSUInteger)charIndex {
    if ([cell isKindOfClass:[WCArgumentPlaceholderCell class]]) {
        [textView setSelectedRange:NSMakeRange(charIndex, 1)];
    }
}
- (void)textView:(NSTextView *)textView doubleClickedOnCell:(id<NSTextAttachmentCell>)cell inRect:(NSRect)cellFrame atIndex:(NSUInteger)charIndex {
    if ([cell isKindOfClass:[WCArgumentPlaceholderCell class]]) {
        WCArgumentPlaceholderCell *placeholderCell = (WCArgumentPlaceholderCell *)cell;
        
        [textView insertText:placeholderCell.stringValue replacementRange:NSMakeRange(charIndex, 1)];
        [textView setSelectedRange:NSMakeRange(charIndex, placeholderCell.stringValue.length)];
    }
}

- (NSUndoManager *)undoManagerForTextView:(NSTextView *)view {
    return [self.delegate undoManagerForTextViewController:self];
}

#pragma mark WCTextViewDelegate
- (WCSymbolScanner *)symbolScannerForTextView:(WCTextView *)textView {
    return [self.delegate symbolScannerForTextViewController:self];
}
- (void)textView:(WCTextView *)textView jumpToDefinitionForSymbol:(Symbol *)symbol {
    [textView setSelectedRange:NSRangeFromString(symbol.range)];
    [textView scrollRangeToVisible:textView.selectedRange];
}
#pragma mark WCFoldViewDelegate
- (WCFoldScanner *)foldScannerForFoldView:(WCFoldView *)foldView {
    return [self.delegate foldScannerForTextViewController:self];
}

#pragma mark WCJumpBarControlDataSource
- (NSArray *)jumpBarComponentCellsForJumpBarControl:(WCJumpBarControl *)jumpBarControl {
    NSURL *fileURL = [self.delegate fileURLForTextViewController:self];
    WCJumpBarComponentCell *cell;
    
    if (fileURL)
        cell = [[WCJumpBarComponentCell alloc] initTextCell:fileURL.path.lastPathComponent];
    else
        cell = [[WCJumpBarComponentCell alloc] initTextCell:[self.delegate displayNameForTextViewController:self]];
    
    NSImage *image;
    
    if ([fileURL getResourceValue:&image forKey:NSURLEffectiveIconKey error:NULL])
        [cell setImage:image];
    
    return @[ cell ];
}
- (WCJumpBarComponentCell *)symbolPathComponentCellForJumpBarControl:(WCJumpBarControl *)jumpBarControl {
    WCSymbolScanner *symbolScanner = [self.delegate symbolScannerForTextViewController:self];
    Symbol *symbol = [symbolScanner symbolForRange:self.textView.selectedRange];
    WCJumpBarComponentCell *cell;
    
    if (!symbol) {
        cell = [[WCJumpBarComponentCell alloc] initTextCell:NSLocalizedString(@"No Selection", nil)];
        
        return cell;
    }
    
    cell = [[WCJumpBarComponentCell alloc] initTextCell:symbol.name];
    
    [cell setImage:[[WCSymbolImageManager sharedManager] imageForSymbol:symbol]];
    [cell setRepresentedObject:symbol];
    
    return cell;
}
#pragma mark WCJumpBarControlDelegate
- (BOOL)jumpBarControl:(WCJumpBarControl *)jumpBarControl shouldPopUpMenuForPathComponentCell:(WCJumpBarComponentCell *)pathComponentCell {
    return (jumpBarControl.pathComponentCells.lastObject == pathComponentCell);
}
- (NSInteger)jumpBarControl:(WCJumpBarControl *)jumpBarControl numberOfItemsInMenuForPathComponentCell:(WCJumpBarComponentCell *)pathComponentCell {
    if (!self.jumpBarControlMenuSymbols) {
        WCSymbolScanner *symbolScanner = [self.delegate symbolScannerForTextViewController:self];
        
        [self setJumpBarControlMenuSymbols:symbolScanner.symbolsSortedByLocation];
    }
    return self.jumpBarControlMenuSymbols.count;
}
- (void)jumpBarControl:(WCJumpBarControl *)jumpBarControl updateItem:(NSMenuItem *)item atIndex:(NSInteger)index forPathComponentCell:(WCJumpBarComponentCell *)pathComponentCell {
    Symbol *symbol = [self.jumpBarControlMenuSymbols objectAtIndex:index];
    
    [item setImage:[[WCSymbolImageManager sharedManager] imageForSymbol:symbol]];
    [item setTitle:symbol.name];
}

- (NSInteger)jumpBarControl:(WCJumpBarControl *)jumpBarControl highlightedItemIndexForPathComponentCell:(WCJumpBarComponentCell *)pathComponentCell {
    return [self.jumpBarControlMenuSymbols WC_symbolIndexForRange:self.textView.selectedRange];
}
- (void)jumpBarControl:(WCJumpBarControl *)jumpBarControl menuDidCloseForPathComponentCell:(WCJumpBarComponentCell *)pathComponentCell {
    [self setJumpBarControlMenuSymbols:nil];
}
- (void)jumpBarControl:(WCJumpBarControl *)jumpBarControl didSelectItem:(NSMenuItem *)item atIndex:(NSUInteger)index forPathComponentCell:(WCJumpBarComponentCell *)pathComponentCell {
    Symbol *symbol = [self.jumpBarControlMenuSymbols objectAtIndex:index];
    
    [self.textView setSelectedRange:NSRangeFromString(symbol.range)];
    [self.textView scrollRangeToVisible:self.textView.selectedRange];
}

- (NSString *)jumpBarControl:(WCJumpBarControl *)jumpBarControl toolTipForPathComponentCell:(WCJumpBarComponentCell *)pathComponentCell atIndex:(NSUInteger)index {
    if (jumpBarControl.pathComponentCells.lastObject == pathComponentCell) {
        Symbol *symbol = pathComponentCell.representedObject;
        
        if (symbol)
            return [NSString stringWithFormat:NSLocalizedString(@"%@ \u2192 %@:%ld", nil),symbol.name,symbol.file.path.lastPathComponent,symbol.lineNumber.longValue];
        return nil;
    }
    return [self.delegate fileURLForTextViewController:self].path;
}

#pragma mark *** Public Methods ***
- (id)initWithTextStorage:(WCTextStorage *)textStorage; {
    if (!(self = [super init]))
        return nil;
    
    [self setTextStorage:textStorage];
    
    return self;
}

- (void)setDelegate:(id<WCTextViewControllerDelegate>)delegate {
    _delegate = delegate;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WCSymbolScannerDidFinishScanningSymbolsNotification object:nil];
    
    if (_delegate) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_symbolScannerDidFinishScanningSymbols:) name:WCSymbolScannerDidFinishScanningSymbolsNotification object:[delegate symbolScannerForTextViewController:self]];
    }
}
#pragma mark *** Private Methods ***

#pragma mark Actions
- (IBAction)_recentFilesMenuItemAction:(NSMenuItem *)sender {
    NSURL *recentURL = sender.representedObject;
    
    if (recentURL)
        [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:recentURL display:YES completionHandler:nil];
}

#pragma mark Notifications
- (void)_symbolScannerDidFinishScanningSymbols:(NSNotification *)note {
    [self.jumpBarControl reloadSymbolPathComponentCell];
}
- (void)_textStorageDidProcessEditing:(NSNotification *)note {
    if (self.textView.window.firstResponder != self.textView)
        return;
    else if (([note.object editedMask] & NSTextStorageEditedCharacters) == 0)
        return;
    else if ([self.textView.undoManager isRedoing] ||
        [self.textView.undoManager isUndoing] ||
        [note.object changeInLength] != 1) {
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self.textView selector:@selector(complete:) object:nil];
        return;
    }
    
    static NSCharacterSet *kLegalCharacters;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableCharacterSet *temp = [[NSCharacterSet letterCharacterSet] mutableCopy];
        
        [temp formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
        [temp formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"_!?.#"]];
        
        kLegalCharacters = [temp copy];
    });
    
    if (![kLegalCharacters characterIsMember:[self.textView.string characterAtIndex:[note.object editedRange].location]]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self.textView selector:@selector(complete:) object:nil];
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self.textView selector:@selector(complete:) object:nil];
    [self.textView performSelector:@selector(complete:) withObject:nil afterDelay:0.35];
}
- (void)_textStorageDidFold:(NSNotification *)note {
    [self.textView setNeedsDisplay:YES];
}
- (void)_textStorageDidUnfold:(NSNotification *)note {
    [self.textView setNeedsDisplay:YES];
}
- (void)_viewBoundsDidChange:(NSNotification *)note {
    WCSymbolHighlighter *symbolHighlighter = [self.delegate symbolHighlighterForTextViewController:self];
    
    [symbolHighlighter symbolHighlightInRange:[self.textView WC_visibleRange]];
}

@end
