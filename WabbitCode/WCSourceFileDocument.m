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
#import "NSTextView+WCExtensions.h"
#import "NSURL+WCExtensions.h"
#import "NSImage+WCExtensions.h"
#import "WCGeometry.h"
#import "NSString+WCExtensions.h"
#import "WCProjectDocument.h"
#import "WCSymbolIndex.h"

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

- (void)_startWatchingDocument;
- (void)_stopWatchingDocument;
- (void)_reloadDocumentFromDisk;
@end

@implementation WCSourceFileDocument {
    dispatch_source_t _source;
}
#pragma mark *** Subclass Overrides ***
- (id)initWithType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    if (!(self = [super initWithType:typeName error:outError]))
        return nil;
    
    [self setStringEncoding:NSUTF8StringEncoding];
    [self setTextStorage:[[WCTextStorage alloc] initWithString:@"" attributes:[WCSyntaxHighlighter defaultAttributes]]];
    [self setSyntaxHighlighter:[[WCSyntaxHighlighter alloc] initWithTextStorage:self.textStorage]];
    [self setSymbolHighlighter:[[WCSymbolHighlighter alloc] initWithTextStorage:self.textStorage]];
    [self.symbolHighlighter setDelegate:self];
    [self setSymbolScanner:[[WCSymbolScanner alloc] initWithSourceFileDocument:self]];
    [self.syntaxHighlighter setDelegate:self];
    [self.symbolScanner setDelegate:self];
    [self setFoldScanner:[[WCFoldScanner alloc] initWithTextStorage:self.textStorage]];
    
    return self;
}

- (void)makeWindowControllers {
    WCSourceFileWindowController *windowController = [[WCSourceFileWindowController alloc] initWithTextStorage:self.textStorage];
    
    [self addWindowController:windowController];
}

- (void)close {
    [super close];
    
    [self _stopWatchingDocument];
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
    
    if (!self.UUID)
        [self setUUID:[NSString WC_UUIDString]];
    
    [self setStringEncoding:usedEncoding];
    [self setTextStorage:[[WCTextStorage alloc] initWithString:string attributes:[WCSyntaxHighlighter defaultAttributes]]];
    [self setSyntaxHighlighter:[[WCSyntaxHighlighter alloc] initWithTextStorage:self.textStorage]];
    [self setSymbolHighlighter:[[WCSymbolHighlighter alloc] initWithTextStorage:self.textStorage]];
    [self.symbolHighlighter setDelegate:self];
    [self setSymbolScanner:[[WCSymbolScanner alloc] initWithSourceFileDocument:self]];
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
    for (NSLayoutManager *layoutManager in self.textStorage.layoutManagers) {
        for (NSTextContainer *textContainer in layoutManager.textContainers) {
            if (textContainer.textView.isCoalescingUndo) {
                [textContainer.textView breakUndoCoalescing];
            }
        }
    }
    
    [super saveToURL:url ofType:typeName forSaveOperation:saveOperation completionHandler:^(NSError *outError) {
        
        completionHandler(outError);
    }];
}

- (void)updateChangeCount:(NSDocumentChangeType)change {
    BOOL edited = self.isDocumentEdited;
    
    [self willChangeValueForKey:@"icon"];
    [self willChangeValueForKey:@"isEdited"];
    [super updateChangeCount:change];
    [self didChangeValueForKey:@"icon"];
    [self didChangeValueForKey:@"isEdited"];
    
    if (edited != self.isDocumentEdited)
        [[NSNotificationCenter defaultCenter] postNotificationName:WCSourceFileDocumentEditedDidChangeNotification object:self];
}

- (void)setFileURL:(NSURL *)url {
    [self willChangeValueForKey:@"title"];
    [super setFileURL:url];
    [self didChangeValueForKey:@"title"];
    
    [self _startWatchingDocument];
}
#pragma mark MMTabBarItem
- (NSString *)title {
    return self.displayName;
}
- (NSImage *)icon {
    NSImage *retval = [self.fileURL WC_effectiveIcon];
    
    if (self.isDocumentEdited)
        retval = [retval WC_unsavedImageIcon];
    
    [retval setSize:WC_NSSmallSize];
    
    return retval;
}
- (BOOL)isEdited {
    return self.isDocumentEdited;
}
- (BOOL)hasCloseButton {
    return YES;
}

#pragma mark WCSymbolScannerDelegate
- (NSURL *)fileURLForSymbolScanner:(WCSymbolScanner *)symbolScanner {
    return self.fileURL;
}
#pragma mark WCSyntaxHighlighterDelegate
- (WCSymbolHighlighter *)symbolHighlighterForSyntaxHighlighter:(WCSyntaxHighlighter *)syntaxHighlighter {
    return self.symbolHighlighter;
}
- (WCSymbolScanner *)symbolScannerForSyntaxHighligher:(WCSyntaxHighlighter *)syntaxHighlighter {
    return self.symbolScanner;
}
#pragma mark WCSymbolHighlighterDelegate
- (id<WCSymbolsProvider>)symbolsProviderForSymbolHighlighter:(WCSymbolHighlighter *)symbolHighlighter {
    return self.symbolScanner;
}
#pragma mark *** Public Methods ***
- (id)initWithContentsOfURL:(NSURL *)url ofType:(NSString *)typeName projectDocument:(WCProjectDocument *)projectDocument UUID:(NSString *)UUID error:(NSError *__autoreleasing *)outError; {
    [self setProjectDocument:projectDocument];
    [self setUUID:UUID];
    
    return [self initWithContentsOfURL:url ofType:typeName error:outError];
}
#pragma mark Properties
- (WCSourceFileWindowController *)sourceFileWindowController {
    return self.windowControllers.lastObject;
}
#pragma mark *** Private Methods ***
- (void)_startWatchingDocument; {
    [self _stopWatchingDocument];
    
    if (!self.fileURL)
        return;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    int fd = open(self.fileURL.path.fileSystemRepresentation, O_EVTONLY);
    __weak typeof (self) weakSelf = self;
    _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fd, DISPATCH_VNODE_DELETE|DISPATCH_VNODE_RENAME|DISPATCH_VNODE_WRITE|DISPATCH_VNODE_EXTEND, queue);
    __block dispatch_source_t source = _source;
    
    dispatch_source_set_event_handler(source, ^{
        unsigned long flags = dispatch_source_get_data(source);
        
        if (flags & DISPATCH_VNODE_DELETE) {
            dispatch_source_cancel(source);
            [weakSelf _startWatchingDocument];
        }
        
        [weakSelf _reloadDocumentFromDisk];
    });
    
    dispatch_source_set_cancel_handler(source, ^{
        close(fd);
    });
    
    dispatch_resume(source);
}
- (void)_stopWatchingDocument; {
    if (_source)
        dispatch_source_cancel(_source);
}
- (void)_reloadDocumentFromDisk; {
    NSError *outError;
    NSStringEncoding usedEncoding = NSUTF8StringEncoding;
    NSString *string = [NSString stringWithContentsOfURL:self.fileURL encoding:usedEncoding error:&outError];
    
    if (!string) {
        string = [NSString stringWithContentsOfURL:self.fileURL usedEncoding:&usedEncoding error:&outError];
        
        if (!string)
            return;
    }
    
    NSMutableArray *selectedRanges = [NSMutableArray arrayWithCapacity:0];
    
    for (NSLayoutManager *layoutManager in self.textStorage.layoutManagers)
        [selectedRanges addObject:[NSValue valueWithRange:layoutManager.firstTextView.selectedRange]];
    
    [self.textStorage replaceCharactersInRange:NSMakeRange(0, self.textStorage.length) withString:string];
    [self setFileModificationDate:[self.fileURL WC_contentModificationDate]];
    
    [self.textStorage.layoutManagers enumerateObjectsUsingBlock:^(NSLayoutManager *layoutManager, NSUInteger lmIndex, BOOL *stop) {
        NSRange selectedRange = [[selectedRanges objectAtIndex:lmIndex] rangeValue];
        
        [layoutManager.firstTextView WC_setSelectedRangeSafely:selectedRange];
    }];
}

@end
