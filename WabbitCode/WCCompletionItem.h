//
//  WCCompletionItem.h
//  WabbitStudio
//
//  Created by William Towe on 9/24/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>

@protocol WCCompletionItemDataSource;

@interface WCCompletionItem : NSObject

@property (readonly,strong,nonatomic) id <WCCompletionItemDataSource> dataSource;
@property (readonly,copy,nonatomic) NSAttributedString *displayString;

- (id)initWithDataSource:(id<WCCompletionItemDataSource>)dataSource;

@end

@protocol WCCompletionItemDataSource <NSObject>
- (NSString *)name;
- (NSImage *)image;
@optional

@property (nonatomic,retain) NSNumber *priority;

- (NSString *)arguments;
- (NSString *)format;
- (NSNumber *)lineNumber;
- (NSString *)path;
           
@end