//
//  WCSyntaxHighlighter.h
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

#import <Foundation/Foundation.h>

extern NSString *const kMultilineCommentAttributeName;
extern NSString *const kCommentAttributeName;
extern NSString *const kTokenAttributeName;
extern NSString *const kSymbolAttributeName;

@protocol WCSyntaxHighlighterDelegate;

@interface WCSyntaxHighlighter : NSObject

@property (weak,nonatomic) id <WCSyntaxHighlighterDelegate> delegate;

- (id)initWithTextStorage:(NSTextStorage *)textStorage;

- (void)syntaxHighlightInRange:(NSRange)range;

+ (NSDictionary *)defaultAttributes;

+ (NSRegularExpression *)commentRegex;
+ (NSRegularExpression *)multilineCommentRegex;
+ (NSRegularExpression *)stringRegex;
+ (NSRegularExpression *)preProcessorRegex;
+ (NSRegularExpression *)numberRegex;
+ (NSRegularExpression *)binaryNumberRegex;
+ (NSRegularExpression *)hexadecimalNumberRegex;
+ (NSRegularExpression *)directiveRegex;
+ (NSRegularExpression *)registerRegex;
+ (NSRegularExpression *)conditionalRegisterRegex;
+ (NSRegularExpression *)operationalCodeRegex;

+ (NSRegularExpression *)labelRegex;
+ (NSRegularExpression *)equateRegex;
+ (NSRegularExpression *)defineRegex;
+ (NSRegularExpression *)macroRegex;

@end

@class WCSymbolHighlighter,WCSymbolScanner;

@protocol WCSyntaxHighlighterDelegate <NSObject>
- (WCSymbolHighlighter *)symbolHighlighterForSyntaxHighlighter:(WCSyntaxHighlighter *)syntaxHighlighter;
- (WCSymbolScanner *)symbolScannerForSyntaxHighligher:(WCSyntaxHighlighter *)syntaxHighlighter;
@end