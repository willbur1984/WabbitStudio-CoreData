//
//  WCOpenQuicklyWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 11/13/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCOpenQuicklyWindowController.h"
#import "WCProjectDocument.h"
#import "WCSymbolIndex.h"
#import "Macro.h"
#import "WCJumpInCellView.h"
#import "WCDefines.h"
#import "WCTableView.h"
#import "WCOpenQuicklyItem.h"
#import "File.h"
#import "WCOpenQuicklyOperation.h"
#import "WCFindBarViewController.h"
#import "WCSourceFileDocument.h"
#import "WCProjectWindowController.h"
#import "WCTabViewController.h"
#import "WCTextViewController.h"
#import "WCTextView.h"
#import "NSObject+WCExtensions.h"

static char kWCOpenQuicklyWindowControllerObservingContext;

@interface WCOpenQuicklyWindowController () <NSWindowDelegate,NSTextFieldDelegate,NSTableViewDataSource,NSTableViewDelegate>

@property (weak,nonatomic) IBOutlet NSSearchField *searchField;
@property (weak,nonatomic) IBOutlet WCTableView *tableView;
@property (weak,nonatomic) IBOutlet NSPathControl *pathControl;
@property (weak,nonatomic) IBOutlet NSButton *openButton;
@property (weak,nonatomic) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak,nonatomic) IBOutlet NSTextField *statusTextField;

@property (readwrite,weak,nonatomic) WCProjectDocument *projectDocument;
@property (strong,nonatomic) NSOperationQueue *operationQueue;

- (void)_openQuicklyForOpenQuicklyItem:(WCOpenQuicklyItem *)openQuicklyItem;
- (void)_setupSearchFieldMenu;
@end

@implementation WCOpenQuicklyWindowController

- (id)init {
    if (!(self = [super initWithWindowNibName:self.windowNibName]))
        return nil;
    
    [self setOperationQueue:[[NSOperationQueue alloc] init]];
    [self.operationQueue setMaxConcurrentOperationCount:1];
    [self.operationQueue setName:@"org.revsoft.wabbitcode.open-quickly.queue"];
    [self.operationQueue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:&kWCOpenQuicklyWindowControllerObservingContext];
    
    return self;
}

- (NSString *)windowNibName {
    return @"WCOpenQuicklyWindow";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.window setDelegate:self];
    
    [self.tableView setEmptyString:NSLocalizedString(@"Type File or Symbol Name", nil)];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(_tableViewDoubleClick:)];
    
    [self.searchField setDelegate:self];
    [self _setupSearchFieldMenu];
    
    [self.pathControl setURL:nil];
    
    [self.openButton setEnabled:NO];
    
    [self.statusTextField setHidden:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &kWCOpenQuicklyWindowControllerObservingContext) {
        if ([keyPath isEqualToString:@"operationCount"]) {
            NSUInteger operationCount = [[change objectForKey:NSKeyValueChangeNewKey] unsignedIntegerValue];
            
            __unsafe_unretained typeof (self) weakSelf = self;
            
            if (operationCount == 0) {
                [self WC_performBlockOnMainThread:^{
                    [weakSelf.progressIndicator stopAnimation:nil];
                    [weakSelf.statusTextField setHidden:YES];
                }];
            }
            else {
                [self WC_performBlockOnMainThread:^{
                    [weakSelf.progressIndicator startAnimation:nil];
                    [weakSelf.statusTextField setHidden:NO];
                }];
            }
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.openQuicklyItems.count;
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    WCJumpInCellView *cell = (WCJumpInCellView *)[tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    if (!cell) {
        cell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    }
    
    WCOpenQuicklyItem *item = [self.openQuicklyItems objectAtIndex:row];
    
    [cell.imageView setImage:item.image];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:item.name];
    NSDictionary *attributes = [WCFindBarViewController findRangeAttributes];
    
    [item.ranges enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        [string addAttributes:attributes range:range];
    }];
    
    [cell.textField setAttributedStringValue:string];
    
    NSMutableString *pathString = [NSMutableString stringWithCapacity:0];
    File *file = [self.projectDocument fileWithUUID:item.fileUUID];
    
    do {
        
        [pathString insertString:[NSString stringWithFormat:NSLocalizedString(@" \u25B6 %@", nil),file.name] atIndex:0];
        
        file = file.file;
        
    } while (file.file);
    
    [pathString insertString:file.name atIndex:0];
    
    Symbol *symbol = [self.projectDocument.symbolIndex symbolWithObjectID:item.objectID];
    
    if (symbol) {
        [pathString appendFormat:NSLocalizedString(@" \u25B6 %@", nil),symbol.range];
    }
    
    [cell.pathTextField setStringValue:pathString];
    
    return cell;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if (self.tableView.selectedRow == -1)
        [self.pathControl setURL:nil];
    else {
        if (self.window.firstResponder != self.tableView)
            [self.tableView scrollRowToVisible:self.tableView.selectedRow];
        
        WCOpenQuicklyItem *item = [self.openQuicklyItems objectAtIndex:self.tableView.selectedRow];
        File *file = [self.projectDocument fileWithUUID:item.fileUUID];
        WCSourceFileDocument *sourceFileDocument = [self.projectDocument sourceFileDocumentForFile:file];
        
        [self.pathControl setURL:sourceFileDocument.fileURL];
    }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(cancelOperation:)) {
        [self _cancelAction:nil];
        return YES;
    }
    else if (commandSelector == @selector(insertNewline:)) {
        if (self.tableView.numberOfRows > 0) {
            [self _openQuicklyAction:nil];
            return YES;
        }
    }
    else if (commandSelector == @selector(moveUp:)) {
        if (self.tableView.numberOfRows == 0)
            NSBeep();
        else {
            [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:MAX(0, self.tableView.selectedRow - 1)] byExtendingSelection:NO];
        }
        return YES;
    }
    else if (commandSelector == @selector(moveDown:)) {
        if (self.tableView.numberOfRows == 0)
            NSBeep();
        else {
            [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:MIN(self.tableView.numberOfRows - 1, self.tableView.selectedRow + 1)] byExtendingSelection:NO];
        }
        return YES;
    }
    return NO;
}

+ (WCOpenQuicklyWindowController *)sharedWindowController; {
    static id retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[[self class] alloc] init];
    });
    return retval;
}

- (void)showOpenQuicklyWindowForProjectDocument:(WCProjectDocument *)projectDocument; {
    [self setProjectDocument:projectDocument];
    
    [self.window setTitle:[NSString stringWithFormat:NSLocalizedString(@"Open Quickly in \"%@\"", nil),projectDocument.displayName]];
    [self.window makeFirstResponder:self.searchField];
    
    [[NSApplication sharedApplication] runModalForWindow:self.window];
}
- (void)hideOpenQuicklyWindow; {
    [self.window orderOut:nil];
    [[NSApplication sharedApplication] stopModal];
    
    [self.searchField setStringValue:@""];
    [self.pathControl setURL:nil];
    [self setOpenQuicklyItems:nil];
    [self setProjectDocument:nil];
}

- (NSString *)searchString {
    return self.searchField.stringValue;
}

- (void)setOpenQuicklyItems:(NSArray *)openQuicklyItems {
    _openQuicklyItems = openQuicklyItems;
    
    [self.tableView reloadData];
    
    [self.openButton setEnabled:(openQuicklyItems.count > 0)];
}

- (void)_openQuicklyForOpenQuicklyItem:(WCOpenQuicklyItem *)openQuicklyItem; {
    NSParameterAssert(openQuicklyItem);
    
    // add our recents item
    NSMutableArray *recents = [self.searchField.recentSearches mutableCopy];
    
    [recents insertObject:self.searchField.stringValue atIndex:0];
    
    [self.searchField setRecentSearches:recents];
    
    // open the corresponding tab bar item
    File *file = [self.projectDocument fileWithUUID:openQuicklyItem.fileUUID];
    WCSourceFileDocument *sourceFileDocument = [self.projectDocument sourceFileDocumentForFile:file];
    WCTextViewController *textViewController = [self.projectDocument.projectWindowController.tabViewController selectTabBarItemForSourceFileDocument:sourceFileDocument];
    Symbol *symbol = [self.projectDocument.symbolIndex symbolWithObjectID:openQuicklyItem.objectID];
    
    if (symbol) {
        NSRange range = NSRangeFromString(symbol.range);
        
        [textViewController.textView setSelectedRange:range];
        [textViewController.textView scrollRangeToVisible:range];
    }
}
- (void)_setupSearchFieldMenu {
    NSMenu *searchMenu = [[NSMenu alloc] initWithTitle:@"org.revsoft.wabbitcode.open-quickly.search-menu"];
    
    // recent searches
    NSMenuItem *recentsTitleItem = [searchMenu addItemWithTitle:NSLocalizedString(@"Recent Searches", nil) action:NULL keyEquivalent:@""];
    
    [recentsTitleItem setTag:NSSearchFieldRecentsTitleMenuItemTag];
    
    NSMenuItem *recentsItem = [searchMenu addItemWithTitle:@"" action:NULL keyEquivalent:@""];
    
    [recentsItem setTag:NSSearchFieldRecentsMenuItemTag];
    
    NSMenuItem *noRecentsItem = [searchMenu addItemWithTitle:NSLocalizedString(@"No Recent Searches", nil) action:NULL keyEquivalent:@""];
    
    [noRecentsItem setTag:NSSearchFieldNoRecentsMenuItemTag];
    
    NSMenuItem *clearRecentsSeparator = [NSMenuItem separatorItem];
    
    [clearRecentsSeparator setTag:NSSearchFieldClearRecentsMenuItemTag];
    
    [searchMenu addItem:clearRecentsSeparator];
    
    NSMenuItem *clearRecentsItem = [searchMenu addItemWithTitle:NSLocalizedString(@"Clear Recent Searches", nil) action:NULL keyEquivalent:@""];
    
    [clearRecentsItem setTag:NSSearchFieldClearRecentsMenuItemTag];
    
    [(NSSearchFieldCell *)self.searchField.cell setSearchMenuTemplate:searchMenu];
}

- (IBAction)_openQuicklyAction:(id)sender; {
    if (self.tableView.selectedRow == -1) {
        NSBeep();
        return;
    }
    
    [self _openQuicklyForOpenQuicklyItem:[self.openQuicklyItems objectAtIndex:self.tableView.selectedRow]];
    [self hideOpenQuicklyWindow];
}
- (IBAction)_cancelAction:(id)sender; {
    [self hideOpenQuicklyWindow];
}
- (IBAction)_tableViewDoubleClick:(id)sender {
    if (self.tableView.clickedRow == -1) {
        NSBeep();
        return;
    }
    
    [self _openQuicklyForOpenQuicklyItem:[self.openQuicklyItems objectAtIndex:self.tableView.clickedRow]];
    [self hideOpenQuicklyWindow];
}
- (IBAction)_searchFieldAction:(id)sender; {
    [self.operationQueue cancelAllOperations];
    
    [self.operationQueue addOperation:[[WCOpenQuicklyOperation alloc] initWithOpenQuicklyWindowController:self]];
}

@end
