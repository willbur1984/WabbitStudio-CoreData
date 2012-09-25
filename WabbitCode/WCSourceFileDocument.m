//
//  WCDocument.m
//  WabbitCode
//
//  Created by William Towe on 9/18/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//

#import "WCSourceFileDocument.h"
#import "WCLineNumberView.h"
#import "WCTextViewController.h"
#import "WCSyntaxHighlighter.h"
#import "WCSymbolScanner.h"
#import "WCDefines.h"

@interface WCSourceFileDocument () <WCTextViewControllerDelegate,WCSymbolScannerDelegate>

@property (strong,nonatomic) NSTextStorage *textStorage;
@property (assign,nonatomic) NSStringEncoding stringEncoding;
@property (strong,nonatomic) WCSyntaxHighlighter *syntaxHighlighter;
@property (strong,nonatomic) WCSymbolScanner *symbolScanner;
@property (strong,nonatomic) WCTextViewController *textViewController;

@end

@implementation WCSourceFileDocument

- (id)initWithType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    if (!(self = [super initWithType:typeName error:outError]))
        return nil;
    
    [self setStringEncoding:NSUTF8StringEncoding];
    [self setTextStorage:[[NSTextStorage alloc] initWithString:@"" attributes:[WCSyntaxHighlighter defaultAttributes]]];
    [self setSyntaxHighlighter:[[WCSyntaxHighlighter alloc] initWithTextStorage:self.textStorage]];
    [self setSymbolScanner:[[WCSymbolScanner alloc] initWithTextStorage:self.textStorage]];
    [self.symbolScanner setDelegate:self];
    
    return self;
}

- (NSString *)windowNibName {
    return @"WCSourceFileDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
    [super windowControllerDidLoadNib:windowController];
    
    [self setTextViewController:[[WCTextViewController alloc] initWithTextStorage:self.textStorage]];
    [self.textViewController setDelegate:self];
    [self.textViewController.view setFrame:[windowController.window.contentView bounds]];
    [windowController.window.contentView addSubview:self.textViewController.view];
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
    [self setTextStorage:[[NSTextStorage alloc] initWithString:string attributes:[WCSyntaxHighlighter defaultAttributes]]];
    [self setSyntaxHighlighter:[[WCSyntaxHighlighter alloc] initWithTextStorage:self.textStorage]];
    [self setSymbolScanner:[[WCSymbolScanner alloc] initWithTextStorage:self.textStorage]];
    [self.symbolScanner setDelegate:self];
    
    [self.undoManager enableUndoRegistration];
    
    return YES;
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    return [self.textStorage.string writeToURL:url atomically:YES encoding:self.stringEncoding error:outError];
}

- (WCSymbolScanner *)symbolScannerForTextViewController:(WCTextViewController *)textViewController {
    return self.symbolScanner;
}
- (NSURL *)fileURLForTextViewController:(WCTextViewController *)textViewController {
    return self.fileURL;
}

- (NSURL *)fileURLForSymbolScanner:(WCSymbolScanner *)symbolScanner {
    return self.fileURL;
}

@end
