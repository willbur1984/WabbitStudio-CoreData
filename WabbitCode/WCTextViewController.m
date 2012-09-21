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
#import "WCLineNumberView.h"
#import "WCSyntaxHighlighter.h"

@interface WCTextViewController ()
@property (assign,nonatomic) IBOutlet WCTextView *textView;

@property (weak,nonatomic) NSTextStorage *textStorage;
@end

@implementation WCTextViewController

- (NSString *)nibName {
    return @"WCTextView";
}

- (void)loadView {
    [super loadView];
    
    [self.view setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    
    [self.textView setTypingAttributes:[WCSyntaxHighlighter defaultAttributes]];
    [self.textView.layoutManager replaceTextStorage:self.textStorage];
    
    WCLineNumberView *lineNumberView = [[WCLineNumberView alloc] initWithTextView:self.textView];
    
    [self.textView.enclosingScrollView setVerticalRulerView:lineNumberView];
    [self.textView.enclosingScrollView setHasHorizontalRuler:NO];
    [self.textView.enclosingScrollView setHasVerticalRuler:YES];
    [self.textView.enclosingScrollView setRulersVisible:YES];
}

- (id)initWithTextStorage:(NSTextStorage *)textStorage; {
    if (!(self = [super init]))
        return nil;
    
    [self setTextStorage:textStorage];
    
    return self;
}

- (IBAction)showToolTip:(id)sender; {
    [self.textView showToolTip:nil];
}

@end
