//
//  WCTextStorage.m
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

#import "WCTextStorage.h"
#import "WCFoldCell.h"
#import "WCGeometry.h"
#import "WCBookmarkManager.h"
#import "NSObject+WCExtensions.h"
#import "WCTextView.h"
#import "NSUserDefaults+WCExtensions.h"
#import "WCSyntaxHighlighter.h"

NSString *const WCTextStorageFoldAttributeName = @"WCTextStorageFoldAttributeName";

NSString *const WCTextStorageDidFoldNotification = @"WCTextStorageDidFoldNotification";
NSString *const WCTextStorageDidUnfoldNotification = @"WCTextStorageDidUnfoldNotification";
NSString *const WCTextStorageFoldRangeUserInfoKey = @"WCTextStorageFoldRangeUserInfoKey";

static char kWCTextStorageObservingContext;

@interface WCTextStorage ()
@property (strong,nonatomic) NSMutableAttributedString *attributedString;
@property (readwrite,strong,nonatomic) WCBookmarkManager *bookmarkManager;
@end

@implementation WCTextStorage
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
    [self WC_stopObservingUserDefaultsKeysWithContext:&kWCTextStorageObservingContext];
}

- (id)initWithString:(NSString *)str attributes:(NSDictionary *)attrs {
    if (!(self = [super init]))
        return nil;
    
    NSMutableDictionary *temp = [attrs mutableCopy];
    
    [temp setObject:self.paragraphStyle forKey:NSParagraphStyleAttributeName];
    
    [self setAttributedString:[[NSMutableAttributedString alloc] initWithString:str attributes:temp]];
    [self setBookmarkManager:[[WCBookmarkManager alloc] initWithTextStorage:self]];
    
    [self WC_startObservingUserDefaultsKeysWithOptions:NSKeyValueObservingOptionNew context:&kWCTextStorageObservingContext];
    
    return self;
}

- (NSString *)string {
    return self.attributedString.string;
}
- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range {
    NSDictionary *retval = [self.attributedString attributesAtIndex:location effectiveRange:range];
    
    if (self.isFolding) {
        id value = [retval objectForKey:WCTextStorageFoldAttributeName];
        
        if ([value boolValue]) {
            NSRange effectiveRange;
            [self.attributedString attribute:WCTextStorageFoldAttributeName atIndex:location longestEffectiveRange:&effectiveRange inRange:NSMakeRange(0, self.attributedString.length)];
			
            if (location == effectiveRange.location) { // beginning of a folded range
                NSMutableDictionary *dict = [retval mutableCopy];
				
				static NSTextAttachment *attachment;
				static WCFoldCell *cell;
				static dispatch_once_t onceToken;
				dispatch_once(&onceToken, ^{
					attachment = [[NSTextAttachment alloc] init];
					cell = [[WCFoldCell alloc] initTextCell:@""];
					
					[attachment setAttachmentCell:cell];
				});
				
				[dict setObject:attachment forKey:NSAttachmentAttributeName];
				
                retval = dict;
				
                effectiveRange.length = 1;
            } else {
                ++(effectiveRange.location);
				--(effectiveRange.length);
            }
			
            if (range)
				*range = effectiveRange;
        }
    }
    
    return retval;
}
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)aString {
    [self.attributedString replaceCharactersInRange:range withString:aString];
    [self edited:NSTextStorageEditedCharacters range:range changeInLength:aString.length - range.length];
}
- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range {
    [self.attributedString setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
}

- (void)fixAttachmentAttributeInRange:(NSRange)range {
	NSRange effectiveRange;
	id value;
    
	while (range.length) {
		if ((value = [self attribute:NSAttachmentAttributeName atIndex:range.location longestEffectiveRange:&effectiveRange inRange:range])) {
			for (NSUInteger charIndex=effectiveRange.location; charIndex<NSMaxRange(effectiveRange); charIndex++) {
				if ([self.string characterAtIndex:charIndex] != NSAttachmentCharacter)
					[self removeAttribute:NSAttachmentAttributeName range:NSMakeRange(charIndex, 1)];
			}
		}
		
		range = NSMakeRange(NSMaxRange(effectiveRange),NSMaxRange(range)-NSMaxRange(effectiveRange));
	}
}

+ (NSSet *)WC_userDefaultsKeysToObserve {
    return [NSSet setWithObjects:WCTextViewWrapLinesUserDefaultsKey,WCTextViewIndentWrappedLinesUserDefaultsKey,WCTextViewIndentWrappedLinesNumberOfSpacesUserDefaultsKey, nil];
}

#pragma mark NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &kWCTextStorageObservingContext) {
        if ([keyPath isEqualToString:[@"values." stringByAppendingString:WCTextViewWrapLinesUserDefaultsKey]]) {
            [self addAttribute:NSParagraphStyleAttributeName value:self.paragraphStyle range:NSMakeRange(0, self.length)];
        }
        else if ([keyPath isEqualToString:[@"values." stringByAppendingString:WCTextViewIndentWrappedLinesUserDefaultsKey]]) {
            [self addAttribute:NSParagraphStyleAttributeName value:self.paragraphStyle range:NSMakeRange(0, self.length)];
        }
        else if ([keyPath isEqualToString:[@"values." stringByAppendingString:WCTextViewIndentWrappedLinesNumberOfSpacesUserDefaultsKey]]) {
            [self addAttribute:NSParagraphStyleAttributeName value:self.paragraphStyle range:NSMakeRange(0, self.length)];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark *** Public Methods ***
+ (NSParagraphStyle *)defaultParagraphStyle; {
    NSMutableParagraphStyle *retval = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:WCTextViewWrapLinesUserDefaultsKey] &&
        [[NSUserDefaults standardUserDefaults] boolForKey:WCTextViewIndentWrappedLinesUserDefaultsKey]) {
        
        NSUInteger spaces = [[NSUserDefaults standardUserDefaults] WC_unsignedIntegerForKey:WCTextViewIndentWrappedLinesNumberOfSpacesUserDefaultsKey];
        NSMutableString *temp = [NSMutableString stringWithCapacity:spaces];
        
        for (NSUInteger tempIndex=0; tempIndex<spaces; tempIndex++)
            [temp appendString:@" "];
        
        NSSize tempSize = [temp sizeWithAttributes:[WCSyntaxHighlighter defaultAttributes]];
        
        [retval setHeadIndent:tempSize.width];
    }
    
    return retval;
}

- (void)foldRange:(NSRange)range; {
    [self addAttribute:WCTextStorageFoldAttributeName value:@true range:range];
    [self addAttribute:NSCursorAttributeName value:[NSCursor arrowCursor] range:range];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WCTextStorageDidFoldNotification object:self userInfo:@{ WCTextStorageFoldRangeUserInfoKey : [NSValue valueWithRange:range] }];
}
- (BOOL)unfoldRange:(NSRange)range effectiveRange:(NSRangePointer)effectiveRange; {
    NSRange foldRange = [self foldRangeForRange:range];
    
    if (foldRange.location == NSNotFound)
        return NO;
    
    [self removeAttribute:WCTextStorageFoldAttributeName range:foldRange];
    [self removeAttribute:NSCursorAttributeName range:foldRange];
    
    if (effectiveRange)
        *effectiveRange = foldRange;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WCTextStorageDidUnfoldNotification object:self userInfo:@{ WCTextStorageFoldRangeUserInfoKey : [NSValue valueWithRange:foldRange] }];
    
    return YES;
}
- (NSRange)foldRangeForRange:(NSRange)range; {
    NSRange effectiveRange;
    id attribute = [self attribute:WCTextStorageFoldAttributeName atIndex:range.location longestEffectiveRange:&effectiveRange inRange:NSMakeRange(0, self.length)];
    
    if ([attribute boolValue])
        return effectiveRange;
    
    return WC_NSNotFoundRange;
}
#pragma mark Properties
- (id<WCTextStorageDelegate>)delegate {
    return (id<WCTextStorageDelegate>)[super delegate];
}
- (void)setDelegate:(id<WCTextStorageDelegate>)delegate {
    [super setDelegate:delegate];
}

- (NSParagraphStyle *)paragraphStyle {
    return [self.class defaultParagraphStyle];
}
@end
