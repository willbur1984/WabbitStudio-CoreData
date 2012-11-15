//
//  WCJumpInWindowController.m
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

#import "WCJumpInWindowController.h"
#import "NSString+WCExtensions.h"
#import "WCDefines.h"
#import "WCTableView.h"
#import "WCJumpInCellView.h"
#import "WCSourceFileDocument.h"
#import "WCProjectDocument.h"
#import "File.h"

@interface WCJumpInWindowController () <NSWindowDelegate,NSTableViewDataSource,NSTableViewDelegate,NSTextFieldDelegate>

@property (weak,nonatomic) IBOutlet NSSearchField *searchField;
@property (weak,nonatomic) IBOutlet WCTableView *tableView;

@property (assign,nonatomic) NSTextView *textView;
@property (assign,nonatomic) NSInteger lineNumber;

- (IBAction)_jumpInAction:(id)sender;
- (IBAction)_cancelAction:(id)sender;
- (IBAction)_searchFieldAction:(id)sender;
@end

@implementation WCJumpInWindowController

- (NSString *)windowNibName {
    return @"WCJumpInWindow";
}

- (id)init {
    if (!(self = [super initWithWindowNibName:self.windowNibName]))
        return nil;
    
    [self setLineNumber:NSNotFound];
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.window setDelegate:self];
    
    [self.tableView setEmptyString:NSLocalizedString(@"Type Line Number", nil)];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(_tableViewDoubleClick:)];
    
    [self.searchField setDelegate:self];
}

- (BOOL)windowShouldClose:(id)sender {
    if (self.window.isModalPanel)
        [[NSApplication sharedApplication] stopModal];
    return YES;
}
- (void)windowWillClose:(NSNotification *)notification {
    [self.searchField setStringValue:@""];
    [self setLineNumber:NSNotFound];
    [self setTextView:nil];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return (self.lineNumber == NSNotFound) ? 0 : 1;
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    WCJumpInCellView *cell = (WCJumpInCellView *)[tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    if (!cell) {
        cell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    }
    
    WCSourceFileDocument *sourceFileDocument = [self.delegate sourceFileDocumentForJumpInWindowController:self];
    
    [cell.imageView setImage:[[NSWorkspace sharedWorkspace] iconForFile:sourceFileDocument.fileURL.path]];
    [cell.textField setStringValue:sourceFileDocument.displayName];
    
    NSMutableString *string = [NSMutableString stringWithCapacity:0];
    
    if (sourceFileDocument.projectDocument) {
        File *file = [sourceFileDocument.projectDocument fileForSourceFileDocument:sourceFileDocument];
        
        do {
            
            [string insertString:[NSString stringWithFormat:NSLocalizedString(@" \u25B6 %@", nil),file.name] atIndex:0];
            
            file = file.file;
            
        } while (file.file);
        
        [string insertString:file.name atIndex:0];
    }
    else {
        if (sourceFileDocument.fileURL)
            [string appendString:[sourceFileDocument.fileURL.path.pathComponents componentsJoinedByString:@" \u25B6 "]];
        else
            [string appendString:sourceFileDocument.displayName];
    }
    
    if (self.lineNumber != NSNotFound)
        [string appendFormat:NSLocalizedString(@":%ld", nil),self.lineNumber + 1];
    
    [cell.pathTextField setStringValue:string];
    
    return cell;
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(cancelOperation:)) {
        [self _cancelAction:nil];
        return YES;
    }
    else if (commandSelector == @selector(insertNewline:)) {
        if (self.lineNumber != NSNotFound) {
            [self _jumpInAction:nil];
            return YES;
        }
    }
    return NO;
}

+ (WCJumpInWindowController *)sharedWindowController; {
    static id retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[[self class] alloc] init];
    });
    return retval;
}

- (void)showJumpInWindowForTextView:(NSTextView *)textView; {
    [self setTextView:textView];
    
    [self.window setTitle:[NSString stringWithFormat:NSLocalizedString(@"Jump in \"%@\"", nil),[[self.delegate sourceFileDocumentForJumpInWindowController:self] displayName]]];
    
    [[NSApplication sharedApplication] runModalForWindow:self.window];
}
- (void)hideJumpInWindow; {
    [self.window performClose:nil];
    [[NSApplication sharedApplication] stopModal];
}

- (IBAction)_jumpInAction:(id)sender; {
    NSRange range = [self.textView.string WC_rangeForLineNumber:self.lineNumber];
    
    [self.textView setSelectedRange:NSMakeRange(range.location, 0)];
    [self.textView scrollRangeToVisible:self.textView.selectedRange];
    
    [self hideJumpInWindow];
}
- (IBAction)_cancelAction:(id)sender; {
    [self hideJumpInWindow];
}
- (IBAction)_searchFieldAction:(id)sender; {
    static NSRegularExpression *kNumberRegex;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kNumberRegex = [[NSRegularExpression alloc] initWithPattern:@"[0-9]+" options:0 error:NULL];
    });
    
    __block NSInteger lineNumber = NSNotFound;
    NSString *string = self.searchField.stringValue;
    
    [kNumberRegex enumerateMatchesInString:string options:0 range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        
        NSInteger tmp;
        NSScanner *scanner = [NSScanner scannerWithString:[string substringWithRange:result.range]];
        
        if (![scanner scanInteger:&tmp])
            return;
        
        lineNumber = MAX(0, --tmp);
        *stop = YES;
    }];
    
    [self setLineNumber:lineNumber];
}
- (IBAction)_tableViewDoubleClick:(id)sender {
    if (self.tableView.clickedRow == -1) {
        NSBeep();
        return;
    }
    
    [self _jumpInAction:nil];
}

- (void)setLineNumber:(NSInteger)lineNumber {
    _lineNumber = lineNumber;
    
    [self.tableView reloadData];
}

@end
