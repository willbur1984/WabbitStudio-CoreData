//
//  WCTextStorage.h
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

#import <Cocoa/Cocoa.h>

extern NSString *const WCTextStorageFoldAttributeName;

extern NSString *const WCTextStorageDidFoldNotification;
extern NSString *const WCTextStorageDidUnfoldNotification;
extern NSString *const WCTextStorageFoldRangeUserInfoKey;

@class WCBookmarkManager;
@protocol WCTextStorageDelegate;

@interface WCTextStorage : NSTextStorage

@property (unsafe_unretained,nonatomic) id <WCTextStorageDelegate> delegate;

@property (readonly,strong,nonatomic) WCBookmarkManager *bookmarkManager;

@property (assign,nonatomic,getter = isFolding) BOOL folding;
- (void)foldRange:(NSRange)range;
- (BOOL)unfoldRange:(NSRange)range effectiveRange:(NSRangePointer)effectiveRange;
- (NSRange)foldRangeForRange:(NSRange)range;

@property (readonly,nonatomic) NSParagraphStyle *paragraphStyle;

+ (NSParagraphStyle *)defaultParagraphStyle;

@end

@protocol WCTextStorageDelegate <NSTextStorageDelegate>

@end