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

@interface WCSourceFileDocument ()
@property (strong,nonatomic) NSTextStorage *textStorage;
@property (assign,nonatomic) NSStringEncoding stringEncoding;
@property (strong,nonatomic) WCSyntaxHighlighter *syntaxHighlighter;
@property (strong,nonatomic) WCTextViewController *textViewController;

@end

@implementation WCSourceFileDocument

- (id)initWithType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    if (!(self = [super initWithType:typeName error:outError]))
        return nil;
    
    [self setStringEncoding:NSUTF8StringEncoding];
    [self setTextStorage:[[NSTextStorage alloc] initWithString:@"" attributes:[WCSyntaxHighlighter defaultAttributes]]];
    [self setSyntaxHighlighter:[[WCSyntaxHighlighter alloc] initWithTextStorage:self.textStorage]];
    
    return self;
}

- (NSString *)windowNibName {
    return @"WCSourceFileDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
    [super windowControllerDidLoadNib:windowController];
    
    [self setTextViewController:[[WCTextViewController alloc] initWithTextStorage:self.textStorage]];
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
    
    [self.undoManager enableUndoRegistration];
    
    return YES;
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    return [self.textStorage.string writeToURL:url atomically:YES encoding:self.stringEncoding error:outError];
}

- (IBAction)showToolTip:(id)sender; {
    [self.textViewController showToolTip:nil];
}

@end
