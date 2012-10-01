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

NSString *const WCTextStorageFoldAttributeName = @"WCTextStorageFoldAttributeName";

NSString *const WCTextStorageDidFoldNotification = @"WCTextStorageDidFoldNotification";
NSString *const WCTextStorageDidUnfoldNotification = @"WCTextStorageDidUnfoldNotification";
NSString *const WCTextStorageFoldRangeUserInfoKey = @"WCTextStorageFoldRangeUserInfoKey";

@interface WCTextStorage ()
@property (strong,nonatomic) NSMutableAttributedString *attributedString;

@end

@implementation WCTextStorage

- (id)initWithString:(NSString *)str attributes:(NSDictionary *)attrs {
    if (!(self = [super init]))
        return nil;
    
    [self setAttributedString:[[NSMutableAttributedString alloc] initWithString:str attributes:attrs]];
    
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

- (void)foldRange:(NSRange)range; {
    [self addAttribute:WCTextStorageFoldAttributeName value:@true range:range];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WCTextStorageDidFoldNotification object:self userInfo:@{ WCTextStorageFoldRangeUserInfoKey : [NSValue valueWithRange:range] }];
}
- (BOOL)unfoldRange:(NSRange)range effectiveRange:(NSRangePointer)effectiveRange; {
    NSRange foldRange = [self foldRangeForRange:range];
    
    if (foldRange.location == NSNotFound)
        return NO;
    
    [self removeAttribute:WCTextStorageFoldAttributeName range:foldRange];
    
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

- (id<WCTextStorageDelegate>)delegate {
    return (id<WCTextStorageDelegate>)[super delegate];
}
- (void)setDelegate:(id<WCTextStorageDelegate>)delegate {
    [super setDelegate:delegate];
}
@end
