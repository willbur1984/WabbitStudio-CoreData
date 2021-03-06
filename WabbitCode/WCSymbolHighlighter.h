//
//  WCSymbolHighlighter.h
//  WabbitStudio
//
//  Created by William Towe on 9/30/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "WCSymbolsProvider.h"

extern NSString *const WCSymbolHighlighterMacroTemporaryAttributeName;
extern NSString *const WCSymbolHighlighterDefineTemporaryAttributeName;
extern NSString *const WCSymbolHighlighterEquateTemporaryAttributeName;
extern NSString *const WCSymbolHighlighterLabelTemporaryAttributeName;

@protocol WCSymbolHighlighterDelegate;

@interface WCSymbolHighlighter : NSObject

@property (weak,nonatomic) id <WCSymbolHighlighterDelegate> delegate;

- (id)initWithTextStorage:(NSTextStorage *)textStorage;

- (void)symbolHighlightInVisibleRange;
- (void)symbolHighlightInRange:(NSRange)range;

@end

@class WCSymbolScanner,WCSyntaxHighlighter,WCSymbolIndex;

@protocol WCSymbolHighlighterDelegate <NSObject>
@required
- (id<WCSymbolsProvider>)symbolsProviderForSymbolHighlighter:(WCSymbolHighlighter *)symbolHighlighter;
@end