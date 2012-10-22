//
//  WCDocument.m
//  WabbitCode
//
//  Created by William Towe on 9/18/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//

#import "WCSourceFileDocument.h"
#import "WCSyntaxHighlighter.h"
#import "WCSymbolScanner.h"
#import "WCDefines.h"
#import "WCSourceFileWindowController.h"
#import "WCTextStorage.h"
#import "WCFoldScanner.h"
#import "WCSymbolHighlighter.h"
#import "WCExtendedAttributesManager.h"
#import "WCTextViewController.h"
#import "WCTextView.h"
#import "WCBookmarkManager.h"
#import "Bookmark.h"

NSString *const WCSourceFileDocumentSelectedRangeAttributeName = @"org.revsoft.source-file-document.selected-range";
NSString *const WCSourceFileDocumentBookmarksAttributeName = @"org.revsoft.source-file-document.bookmarks";

NSString *const WCSourceFileDocumentEditedDidChangeNotification = @"WCSourceFileDocumentEditedDidChangeNotification";

@interface WCSourceFileDocument () <WCSymbolScannerDelegate,WCSyntaxHighlighterDelegate,WCSymbolHighlighterDelegate>

@property (readwrite,strong,nonatomic) WCTextStorage *textStorage;
@property (assign,nonatomic) NSStringEncoding stringEncoding;
@property (readwrite,strong,nonatomic) WCSyntaxHighlighter *syntaxHighlighter;
@property (readwrite,strong,nonatomic) WCSymbolScanner *symbolScanner;
@property (readwrite,strong,nonatomic) WCFoldScanner *foldScanner;
@property (readwrite,strong,nonatomic) WCSymbolHighlighter *symbolHighlighter;

@end

@implementation WCSourceFileDocument

- (id)initWithType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    if (!(self = [super initWithType:typeName error:outError]))
        return nil;
    
    [self setStringEncoding:NSUTF8StringEncoding];
    [self setTextStorage:[[WCTextStorage alloc] initWithString:@"" attributes:[WCSyntaxHighlighter defaultAttributes]]];
    [self setSyntaxHighlighter:[[WCSyntaxHighlighter alloc] initWithTextStorage:self.textStorage]];
    [self setSymbolHighlighter:[[WCSymbolHighlighter alloc] initWithTextStorage:self.textStorage]];
    [self.symbolHighlighter setDelegate:self];
    [self setSymbolScanner:[[WCSymbolScanner alloc] initWithTextStorage:self.textStorage]];
    [self.syntaxHighlighter setDelegate:self];
    [self.symbolScanner setDelegate:self];
    [self setFoldScanner:[[WCFoldScanner alloc] initWithTextStorage:self.textStorage]];
    
    return self;
}

- (void)makeWindowControllers {
    WCSourceFileWindowController *windowController = [[WCSourceFileWindowController alloc] initWithTextStorage:self.textStorage];
    
    [self addWindowController:windowController];
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    [self.undoManager disableUndoRegistration];
    
    NSStringEncoding usedEncoding = NSUTF8StringEncoding;
    NSString *string = [NSString stringWithContentsOfURL:url encoding:usedEncoding error:outError];
    
    if (!string) {
        string = [NSString stringWithContentsOfURL:url usedEncoding:&usedEncoding error:outError];
        
        if (!string)
            return NO;
    }
    
    [self setStringEncoding:usedEncoding];
    [self setTextStorage:[[WCTextStorage alloc] initWithString:string attributes:[WCSyntaxHighlighter defaultAttributes]]];
    [self setSyntaxHighlighter:[[WCSyntaxHighlighter alloc] initWithTextStorage:self.textStorage]];
    [self setSymbolHighlighter:[[WCSymbolHighlighter alloc] initWithTextStorage:self.textStorage]];
    [self.symbolHighlighter setDelegate:self];
    [self setSymbolScanner:[[WCSymbolScanner alloc] initWithTextStorage:self.textStorage]];
    [self.syntaxHighlighter setDelegate:self];
    [self.symbolScanner setDelegate:self];
    [self setFoldScanner:[[WCFoldScanner alloc] initWithTextStorage:self.textStorage]];
    
    NSArray *bookmarks = [[WCExtendedAttributesManager sharedManager] objectForAttribute:WCSourceFileDocumentBookmarksAttributeName atURL:url];
    
    for (NSString *rangeString in bookmarks)
        [self.textStorage.bookmarkManager addBookmarkForRange:NSRangeFromString(rangeString) name:nil];
    
    [self.undoManager enableUndoRegistration];
    
    return YES;
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    NSData *data = [self.textStorage.string dataUsingEncoding:NSUTF8StringEncoding];
    
    if (![data writeToURL:url options:NSAtomicWrite error:outError])
        return NO;
    
    NSRange selectedRange = self.sourceFileWindowController.currentTextViewController.textView.selectedRange;
    
    [[WCExtendedAttributesManager sharedManager] setString:NSStringFromRange(selectedRange) forAttribute:WCSourceFileDocumentSelectedRangeAttributeName atURL:url];
    [[WCExtendedAttributesManager sharedManager] setObject:@(self.stringEncoding) forAttribute:WCExtendedAttributesManagerAppleTextEncodingAttributeName atPath:url.path];
    
    NSArray *bookmarks = self.textStorage.bookmarkManager.bookmarks;
    
    if (bookmarks.count > 0) {
        NSMutableArray *rangeStrings = [NSMutableArray arrayWithCapacity:bookmarks.count];
        
        for (Bookmark *bookmark in bookmarks)
            [rangeStrings addObject:bookmark.range];
        
        [[WCExtendedAttributesManager sharedManager] setObject:rangeStrings forAttribute:WCSourceFileDocumentBookmarksAttributeName atURL:url];
    }
    else
        [[WCExtendedAttributesManager sharedManager] removeAttribute:WCSourceFileDocumentBookmarksAttributeName atURL:url];
    
    return YES;
}

- (void)saveToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation completionHandler:(void (^)(NSError *))completionHandler {
    if (saveOperation != NSAutosaveElsewhereOperation) {
        for (NSLayoutManager *layoutManager in self.textStorage.layoutManagers) {
            for (NSTextContainer *textContainer in layoutManager.textContainers) {
                if (textContainer.textView.isCoalescingUndo) {
                    [textContainer.textView breakUndoCoalescing];
                }
            }
        }
    }
    
    [super saveToURL:url ofType:typeName forSaveOperation:saveOperation completionHandler:^(NSError *outError) {
        
        completionHandler(outError);
    }];
}

- (void)updateChangeCount:(NSDocumentChangeType)change {
    BOOL edited = self.isDocumentEdited;
    
    [super updateChangeCount:change];
    
    if (edited != self.isDocumentEdited)
        [[NSNotificationCenter defaultCenter] postNotificationName:WCSourceFileDocumentEditedDidChangeNotification object:self];
}

- (NSURL *)fileURLForSymbolScanner:(WCSymbolScanner *)symbolScanner {
    return self.fileURL;
}

- (WCSymbolHighlighter *)symbolHighlighterForSyntaxHighlighter:(WCSyntaxHighlighter *)syntaxHighlighter {
    return self.symbolHighlighter;
}
- (WCSymbolScanner *)symbolScannerForSyntaxHighligher:(WCSyntaxHighlighter *)syntaxHighlighter {
    return self.symbolScanner;
}

- (WCSymbolScanner *)symbolScannerForSymbolHighlighter:(WCSymbolHighlighter *)symbolHighlighter {
    return self.symbolScanner;
}

- (WCSourceFileWindowController *)sourceFileWindowController {
    return self.windowControllers.lastObject;
}

@end
