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

@interface WCSourceFileWindowController () <WCTextViewControllerDelegate>

@property (readonly,nonatomic) WCSourceFileDocument *sourceFileDocument;
@property (strong,nonatomic) WCTextViewController *textViewController;
@property (weak,nonatomic) NSTextStorage *textStorage;

@end

@implementation WCSourceFileWindowController

- (NSString *)windowNibName {
    return @"WCSourceFileWindow";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self setTextViewController:[[WCTextViewController alloc] initWithTextStorage:self.textStorage]];
    [self.textViewController setDelegate:self];
    [self.textViewController.view setFrame:[self.window.contentView bounds]];
    [self.window.contentView addSubview:self.textViewController.view];
}

- (WCSymbolScanner *)symbolScannerForTextViewController:(WCTextViewController *)textViewController {
    return self.sourceFileDocument.symbolScanner;
}
- (NSURL *)fileURLForTextViewController:(WCTextViewController *)textViewController {
    return self.sourceFileDocument.fileURL;
}
- (NSUndoManager *)undoManagerForTextViewController:(WCTextViewController *)textViewController {
    return self.sourceFileDocument.undoManager;
}

- (id)initWithTextStorage:(NSTextStorage *)textStorage; {
    if (!(self = [super initWithWindowNibName:self.windowNibName]))
        return nil;
    
    [self setTextStorage:textStorage];
    
    return self;
}

- (WCSourceFileDocument *)sourceFileDocument {
    return (WCSourceFileDocument *)self.document;
}

@end
