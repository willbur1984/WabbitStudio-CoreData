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

@interface WCSourceFileDocument () <WCSymbolScannerDelegate>

@property (strong,nonatomic) WCTextStorage *textStorage;
@property (assign,nonatomic) NSStringEncoding stringEncoding;
@property (readwrite,strong,nonatomic) WCSyntaxHighlighter *syntaxHighlighter;
@property (readwrite,strong,nonatomic) WCSymbolScanner *symbolScanner;
@property (readwrite,strong,nonatomic) WCFoldScanner *foldScanner;

@end

@implementation WCSourceFileDocument

- (id)initWithType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    if (!(self = [super initWithType:typeName error:outError]))
        return nil;
    
    [self setStringEncoding:NSUTF8StringEncoding];
    [self setTextStorage:[[WCTextStorage alloc] initWithString:@"" attributes:[WCSyntaxHighlighter defaultAttributes]]];
    [self setSyntaxHighlighter:[[WCSyntaxHighlighter alloc] initWithTextStorage:self.textStorage]];
    [self setSymbolScanner:[[WCSymbolScanner alloc] initWithTextStorage:self.textStorage]];
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
    [self setSymbolScanner:[[WCSymbolScanner alloc] initWithTextStorage:self.textStorage]];
    [self.symbolScanner setDelegate:self];
    [self setFoldScanner:[[WCFoldScanner alloc] initWithTextStorage:self.textStorage]];
    
    [self.undoManager enableUndoRegistration];
    
    return YES;
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    return [self.textStorage.string writeToURL:url atomically:YES encoding:self.stringEncoding error:outError];
}

- (NSURL *)fileURLForSymbolScanner:(WCSymbolScanner *)symbolScanner {
    return self.fileURL;
}

@end
