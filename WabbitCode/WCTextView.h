//
//  WCTextView.h
//  WabbitStudio
//
//  Created by William Towe on 9/19/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Cocoa/Cocoa.h>

@protocol WCTextViewDelegate;

@interface WCTextView : NSTextView

@property (weak,nonatomic) id <WCTextViewDelegate> delegate;

+ (NSRegularExpression *)completionRegex;

- (IBAction)jumpToDefinitionAction:(id)sender;

- (IBAction)foldAction:(id)sender;
- (IBAction)unfoldAction:(id)sender;

- (IBAction)toggleBookmarkAction:(id)sender;
- (IBAction)nextBookmarkAction:(id)sender;
- (IBAction)previousBookmarkAction:(id)sender;

- (IBAction)jumpToNextPlaceholderAction:(id)sender;
- (IBAction)jumpToPreviousPlaceholderAction:(id)sender;

@end

@class WCSymbolScanner,Symbol,WCFoldScanner;

@protocol WCTextViewDelegate <NSTextViewDelegate>
- (WCSymbolScanner *)symbolScannerForTextView:(WCTextView *)textView;
- (WCFoldScanner *)foldScannerForTextView:(WCTextView *)textView;
@optional
- (void)textView:(WCTextView *)textView jumpToDefinitionForSymbol:(Symbol *)symbol;
@end