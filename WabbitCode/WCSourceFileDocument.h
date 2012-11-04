//
//  WCDocument.h
//  WabbitCode
//
//  Created by William Towe on 9/18/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//

#import "WCDocument.h"
#import "MMTabBarItem.h"

extern NSString *const WCSourceFileDocumentSelectedRangeAttributeName;
extern NSString *const WCSourceFileDocumentBookmarksAttributeName;

extern NSString *const WCSourceFileDocumentEditedDidChangeNotification;

@class WCSyntaxHighlighter,WCSymbolScanner,WCFoldScanner,WCSymbolHighlighter,WCTextStorage,WCSourceFileWindowController,WCProjectDocument;

@interface WCSourceFileDocument : WCDocument <MMTabBarItem>

@property (readonly,strong,nonatomic) WCSyntaxHighlighter *syntaxHighlighter;
@property (readonly,strong,nonatomic) WCSymbolHighlighter *symbolHighlighter;
@property (readonly,strong,nonatomic) WCSymbolScanner *symbolScanner;
@property (readonly,strong,nonatomic) WCFoldScanner *foldScanner;
@property (readonly,strong,nonatomic) WCTextStorage *textStorage;
@property (readonly,nonatomic) WCSourceFileWindowController *sourceFileWindowController;
@property (weak,nonatomic) WCProjectDocument *projectDocument;

@end
