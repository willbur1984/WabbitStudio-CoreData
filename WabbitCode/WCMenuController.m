//
//  WCMenuController.m
//  WabbitStudio
//
//  Created by William Towe on 10/6/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCMenuController.h"
#import "WCSourceFileDocument.h"
#import "WCTextStorage.h"
#import "WCBookmarkManager.h"
#import "Bookmark.h"
#import "WCSourceFileWindowController.h"
#import "WCTextViewController.h"
#import "WCTextView.h"
#import "NSString+WCExtensions.h"

@interface WCMenuController () <NSMenuDelegate>
@property (weak,nonatomic) IBOutlet NSMenu *goToBookmarkMenu;
@end

@implementation WCMenuController
#pragma mark NSMenuDelegate
- (void)menuNeedsUpdate:(NSMenu *)menu {
    if (menu == self.goToBookmarkMenu) {
        [menu removeAllItems];
        
        id currentDocument = [[NSDocumentController sharedDocumentController] currentDocument];
        
        if (!currentDocument) {
            [menu addItemWithTitle:NSLocalizedString(@"No Bookmarks", nil) action:NULL keyEquivalent:@""];
        }
        else if ([currentDocument isKindOfClass:[WCSourceFileDocument class]]) {
            WCTextStorage *textStorage = [(WCSourceFileDocument *)currentDocument textStorage];
            WCBookmarkManager *bookmarkManager = textStorage.bookmarkManager;
            NSArray *bookmarks = bookmarkManager.bookmarksSortedByLocation;
            
            if (bookmarks.count > 0) {
                [bookmarks enumerateObjectsUsingBlock:^(Bookmark *bookmark, NSUInteger bookmarkIndex, BOOL *stop) {
                    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"%lu: %@", nil),[textStorage.string WC_lineNumberForRange:NSRangeFromString(bookmark.range)] + 1, bookmark.name];
                    NSMenuItem *item = [menu addItemWithTitle:title action:@selector(_goToBookmarkMenuItemAction:) keyEquivalent:@""];
                    
                    [item setTag:bookmarkIndex];
                    [item setTarget:self];
                }];
                
                [menu addItem:[NSMenuItem separatorItem]];
                
                NSMenuItem *removeAllItem = [menu addItemWithTitle:NSLocalizedString(@"Remove All Bookmarks", nil) action:@selector(_removeAllBookmarksAction:) keyEquivalent:@""];
                
                [removeAllItem setTarget:self];
            }
            else {
                [menu addItemWithTitle:NSLocalizedString(@"No Bookmarks", nil) action:NULL keyEquivalent:@""];
            }
        }
        else {
            [menu addItemWithTitle:NSLocalizedString(@"No Bookmarks", nil) action:NULL keyEquivalent:@""];
        }
    }
}

- (BOOL)menuHasKeyEquivalent:(NSMenu *)menu forEvent:(NSEvent *)event target:(__autoreleasing id *)target action:(SEL *)action {
    *target = nil;
    *action = NULL;
    return NO;
}
#pragma mark Actions
- (IBAction)_goToBookmarkMenuItemAction:(NSMenuItem *)sender {
    WCSourceFileDocument *currentDocument = [[NSDocumentController sharedDocumentController] currentDocument];
    WCBookmarkManager *bookmarkManager = currentDocument.textStorage.bookmarkManager;
    NSArray *bookmarks = bookmarkManager.bookmarksSortedByLocation;
    Bookmark *bookmark = [bookmarks objectAtIndex:sender.tag];
    WCTextViewController *textViewController = currentDocument.sourceFileWindowController.currentTextViewController;
    
    if (!textViewController)
        return;
    
    [textViewController.textView setSelectedRange:NSRangeFromString(bookmark.range)];
    [textViewController.textView scrollRangeToVisible:textViewController.textView.selectedRange];
}
- (IBAction)_removeAllBookmarksAction:(id)sender {
    WCSourceFileDocument *currentDocument = [[NSDocumentController sharedDocumentController] currentDocument];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:WCBookmarkManagerShowRemoveAllWarningUserDefaultsKey]) {
        [currentDocument.textStorage.bookmarkManager removeAllBookmarks];
        return;
    }
    
    NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Remove All Bookmarks", nil) defaultButton:NSLocalizedString(@"Remove All", nil) alternateButton:NSLocalizedString(@"Cancel", nil) otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Are you sure you want to remove all bookmarks? This operation cannot be undone.", nil)];
    
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert setShowsSuppressionButton:YES];
    
    [alert beginSheetModalForWindow:currentDocument.windowForSheet modalDelegate:self didEndSelector:@selector(_removeAllBookmarksAlert:code:context:) contextInfo:(__bridge void *)currentDocument];
}
#pragma mark Callbacks
- (void)_removeAllBookmarksAlert:(NSAlert *)alert code:(NSInteger)code context:(void *)context {
    if (code == NSAlertDefaultReturn) {
        if (alert.suppressionButton.state == NSOnState)
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:WCBookmarkManagerShowRemoveAllWarningUserDefaultsKey];
        
        WCSourceFileDocument *currentDocument = (__bridge WCSourceFileDocument *)context;
        
        [currentDocument.textStorage.bookmarkManager removeAllBookmarks];
    }
}

@end
