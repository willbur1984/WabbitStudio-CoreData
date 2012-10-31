//
//  WCNewProjectWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 10/31/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCNewProjectWindowController.h"
#import "WCDefines.h"
#import "WCDocumentController.h"

@interface WCNewProjectWindowController () <NSWindowDelegate>

@end

@implementation WCNewProjectWindowController
#pragma mark *** Subclass Overrides ***
- (id)init {
    if (!(self = [super initWithWindowNibName:self.windowNibName]))
        return nil;
    
    return self;
}

- (NSString *)windowNibName {
    return @"WCNewProjectWindow";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.window setDelegate:self];
    [self.window setTitle:NSLocalizedString(@"New Project", nil)];
}
#pragma mark NSWindowDelegate
- (BOOL)windowShouldClose:(id)sender {
    if (self.window.isModalPanel)
        [[NSApplication sharedApplication] stopModal];
    return YES;
}
#pragma mark *** Public Methods ***
+ (WCNewProjectWindowController *)sharedWindowController; {
    static id retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[[self class] alloc] init];
    });
    return retval;
}

- (void)showNewProjectWindow; {
    [[NSApplication sharedApplication] runModalForWindow:self.window];
}
#pragma mark Actions
- (IBAction)createFromFolderAction:(id)sender; {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel setTitle:NSLocalizedString(@"Create From Folder…", nil)];
    [openPanel setMessage:NSLocalizedString(@"Choose a folder to create your project from.", nil)];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        [openPanel orderOut:nil];
        
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *directoryURL = openPanel.URLs.lastObject;
            NSString *projectExtension = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)kProjectDocumentUTI, kUTTagClassFilenameExtension);
            NSURL *projectURL = [directoryURL URLByAppendingPathComponent:[directoryURL.lastPathComponent stringByAppendingPathExtension:projectExtension]];
            
            NSError *outError;
            if (![[WCDocumentController sharedDocumentController] makeProjectDocumentForURL:projectURL withContentsOfURL:directoryURL error:&outError]) {
                WCLogObject(outError);
                return;
            }
            
            [self cancelAction:nil];
            
            [[WCDocumentController sharedDocumentController] openDocumentWithContentsOfURL:projectURL display:YES completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
                if (!document)
                    WCLogObject(error);
            }];
        }
    }];
}
- (IBAction)cancelAction:(id)sender; {
    [self.window orderOut:nil];
    [[NSApplication sharedApplication] stopModal];
}

@end
