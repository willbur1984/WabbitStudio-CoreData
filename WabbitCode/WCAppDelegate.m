//
//  WCAppDelegate.m
//  WabbitStudio
//
//  Created by William Towe on 9/18/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCAppDelegate.h"
#import "WCBookmarkManager.h"
#import "WCPreferencesWindowController.h"
#import "WCTextView.h"
#import "WCFoldView.h"
#import "WCNewProjectWindowController.h"
#import "WCProjectDocument.h"
#import "WCUnsavedFilesWindowController.h"
#import "WCDocumentController.h"

@interface WCAppDelegate () <NSApplicationDelegate>
@property (strong,nonatomic) WCPreferencesWindowController *preferencesWindowController;
@end

@implementation WCAppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{ WCBookmarkManagerShowRemoveAllWarningUserDefaultsKey : @true, WCTextViewPageGuideColumnUserDefaultsKey : @80, WCTextViewWrapLinesUserDefaultsKey : @true, WCTextViewIndentWrappedLinesUserDefaultsKey : @false, WCTextViewIndentWrappedLinesNumberOfSpacesUserDefaultsKey : @0, WCTextViewHighlightInstancesOfSelectedSymbolUserDefaultsKey : @true, WCTextViewHighlightInstancesOfSelectedSymbolDelayUserDefaultsKey : @0.35, WCFoldViewLineNumbersUserDefaultsKey : @true, WCFoldViewCodeFoldingRibbonUserDefaultsKey : @true, WCTextViewTabWidthUserDefaultsKey : @4 }];
}
- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    return NO;
}
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    WCProjectDocument *currentProjectDocument = [[WCDocumentController sharedDocumentController] currentProjectDocument];
    
    if (currentProjectDocument) {
        if (currentProjectDocument.unsavedSourceFileDocuments.count > 0) {
            [[WCUnsavedFilesWindowController sharedWindowController] showUnsavedFilesWindowForProjectDocument:currentProjectDocument];
            
            return NSTerminateLater;
        }
    }
    return NSTerminateNow;
}

- (IBAction)newProjectAction:(id)sender; {
    [[WCNewProjectWindowController sharedWindowController] showNewProjectWindow];
}

- (IBAction)preferencesAction:(id)sender; {
    if (!self.preferencesWindowController)
        [self setPreferencesWindowController:[[WCPreferencesWindowController alloc] init]];
    
    [self.preferencesWindowController showWindow:nil];
}

@end
