//
//  WCUnsavedFilesWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 12/9/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCUnsavedFilesWindowController.h"
#import "WCProjectDocument.h"
#import "WCSourceFileDocument.h"
#import "File.h"

@interface WCUnsavedFilesWindowController () <NSWindowDelegate>
@property (weak,nonatomic) IBOutlet NSTableView *tableView;

@property (weak,nonatomic) WCProjectDocument *projectDocument;

- (IBAction)_dontSaveAction:(id)sender;
- (IBAction)_saveSelectedAction:(id)sender;
- (IBAction)_cancelAction:(id)sender;
@end

@implementation WCUnsavedFilesWindowController

- (id)init {
    if (!(self = [super initWithWindowNibName:self.windowNibName]))
        return nil;
    
    return self;
}

- (NSString *)windowNibName {
    return @"WCUnsavedFilesWindow";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.window setDelegate:self];
    [self.window setTitle:NSLocalizedString(@"Unsaved Files", nil)];
}

+ (WCUnsavedFilesWindowController *)sharedWindowController; {
    static id retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[[self class] alloc] init];
    });
    return retval;
}

- (void)showUnsavedFilesWindowForProjectDocument:(WCProjectDocument *)projectDocument; {
    [self setProjectDocument:projectDocument];
    
    [[NSApplication sharedApplication] runModalForWindow:self.window];
}
- (void)closeUnsavedFilesWindow; {
    [self.window performClose:nil];
    [[NSApplication sharedApplication] stopModal];
}

- (IBAction)_dontSaveAction:(id)sender; {
    [self closeUnsavedFilesWindow];
    [[NSApplication sharedApplication] replyToApplicationShouldTerminate:YES];
}
- (IBAction)_saveSelectedAction:(id)sender; {
    [self closeUnsavedFilesWindow];
    [[NSApplication sharedApplication] replyToApplicationShouldTerminate:YES];
}
- (IBAction)_cancelAction:(id)sender; {
    [self closeUnsavedFilesWindow];
    [[NSApplication sharedApplication] replyToApplicationShouldTerminate:NO];
}

@end
