//
//  WCDocument.m
//  WabbitCode
//
//  Created by William Towe on 9/18/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//

#import "WCSourceFileDocument.h"
#import "WCLineNumberView.h"

@interface WCSourceFileDocument ()
@property (assign,nonatomic) IBOutlet NSTextView *textView;

@property (strong) NSTextStorage *textStorage;
@property (assign) NSStringEncoding stringEncoding;
@property (readonly,nonatomic) NSDictionary *defaultAttributes;
@end

@implementation WCSourceFileDocument

- (id)initWithType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    if (!(self = [super initWithType:typeName error:outError]))
        return nil;
    
    [self setStringEncoding:NSUTF8StringEncoding];
    [self setTextStorage:[[NSTextStorage alloc] initWithString:@"" attributes:self.defaultAttributes]];
    
    return self;
}

- (NSString *)windowNibName {
    return @"WCSourceFileDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
    [super windowControllerDidLoadNib:windowController];
    
    [self.textView setTypingAttributes:self.defaultAttributes];
    [self.textView.layoutManager replaceTextStorage:self.textStorage];
    
    WCLineNumberView *lineNumberView = [[WCLineNumberView alloc] initWithTextView:self.textView];
    
    [self.textView.enclosingScrollView setVerticalRulerView:lineNumberView];
    [self.textView.enclosingScrollView setHasHorizontalRuler:NO];
    [self.textView.enclosingScrollView setHasVerticalRuler:YES];
    [self.textView.enclosingScrollView setRulersVisible:YES];
}

+ (BOOL)canConcurrentlyReadDocumentsOfType:(NSString *)typeName {
    return YES;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    NSStringEncoding usedEncoding = NSUTF8StringEncoding;
    NSString *string = [NSString stringWithContentsOfURL:url encoding:usedEncoding error:outError];
    
    if (!string) {
        string = [NSString stringWithContentsOfURL:url usedEncoding:&usedEncoding error:outError];
        
        if (!string)
            return NO;
    }
    
    [self setStringEncoding:usedEncoding];
    [self setTextStorage:[[NSTextStorage alloc] initWithString:string attributes:self.defaultAttributes]];
    
    return YES;
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    return [self.textStorage.string writeToURL:url atomically:YES encoding:self.stringEncoding error:outError];
}

- (NSDictionary *)defaultAttributes {
    return @{ NSFontAttributeName : [NSFont userFixedPitchFontOfSize:13] };
}

@end
