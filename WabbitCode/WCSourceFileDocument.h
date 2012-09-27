//
//  WCDocument.h
//  WabbitCode
//
//  Created by William Towe on 9/18/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WCSyntaxHighlighter,WCSymbolScanner;

@interface WCSourceFileDocument : NSDocument

@property (readonly,strong,nonatomic) WCSyntaxHighlighter *syntaxHighlighter;
@property (readonly,strong,nonatomic) WCSymbolScanner *symbolScanner;

@end
