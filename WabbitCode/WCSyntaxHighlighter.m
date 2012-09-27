//
//  WCSyntaxHighlighter.m
//  WabbitStudio
//
//  Created by William Towe on 9/21/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCSyntaxHighlighter.h"
#import "NSColor+WCExtensions.h"
#import "WCDefines.h"

static NSString *const kMultilineCommentAttributeName = @"kMultilineCommentAttributeName";

@interface WCSyntaxHighlighter () <NSTextStorageDelegate>
@property (weak,nonatomic) NSTextStorage *textStorage;

- (void)_syntaxHighlightInRangeValue:(NSValue *)rangeValue;
@end

@implementation WCSyntaxHighlighter

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (id)initWithTextStorage:(NSTextStorage *)textStorage; {
    if (!(self = [super init]))
        return nil;
    
    [self setTextStorage:textStorage];
    [self syntaxHighlightInRange:NSMakeRange(0, self.textStorage.length)];
    [self.textStorage setDelegate:self];
    
    return self;
}

- (void)syntaxHighlightInRange:(NSRange)range; {
    if (!range.length)
        return;
    
    [self.textStorage beginEditing];
    
    [self.textStorage addAttributes:[self.class defaultAttributes] range:range];
    
    [[WCSyntaxHighlighter operationalCodeRegex] enumerateMatchesInString:self.textStorage.string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:result.range];
    }];
    
    [[WCSyntaxHighlighter registerRegex] enumerateMatchesInString:self.textStorage.string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:result.range];
    }];
    
    [[WCSyntaxHighlighter conditionalRegisterRegex] enumerateMatchesInString:self.textStorage.string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedRed:0 green:1 blue:1 alpha:1] range:[result rangeAtIndex:1]];
    }];
    
    [[WCSyntaxHighlighter numberRegex] enumerateMatchesInString:self.textStorage.string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:result.range];
    }];
    
    [[WCSyntaxHighlighter binaryNumberRegex] enumerateMatchesInString:self.textStorage.string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedRed:0 green:0.75 blue:0.75 alpha:1] range:result.range];
    }];
    
    [[WCSyntaxHighlighter hexadecimalNumberRegex] enumerateMatchesInString:self.textStorage.string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor magentaColor] range:result.range];
    }];
    
    [[WCSyntaxHighlighter directiveRegex] enumerateMatchesInString:self.textStorage.string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor orangeColor] range:result.range];
    }];
    
    [[WCSyntaxHighlighter preProcessorRegex] enumerateMatchesInString:self.textStorage.string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor brownColor] range:result.range];
    }];
    
    [[WCSyntaxHighlighter labelRegex] enumerateMatchesInString:self.textStorage.string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result.range.length == 1 &&
            [self.textStorage.string characterAtIndex:result.range.location] == '_')
            return;
        
        [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0 alpha:1] range:result.range];
    }];
    
    [[WCSyntaxHighlighter equateRegex] enumerateMatchesInString:self.textStorage.string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedRed:0 green:0.5 blue:0.5 alpha:1] range:[result rangeAtIndex:1]];
    }];
    
    [[WCSyntaxHighlighter defineRegex] enumerateMatchesInString:self.textStorage.string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor brownColor] range:[result rangeAtIndex:1]];
    }];
    
    [[WCSyntaxHighlighter macroRegex] enumerateMatchesInString:self.textStorage.string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedRed:1 green:0.4 blue:0.4 alpha:1] range:[result rangeAtIndex:1]];
    }];
    
    [[WCSyntaxHighlighter stringRegex] enumerateMatchesInString:self.textStorage.string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor purpleColor] range:result.range];
    }];
    
    [[WCSyntaxHighlighter commentRegex] enumerateMatchesInString:self.textStorage.string options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [self.textStorage addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithCalibratedRed:0 green:0.5 blue:0 alpha:1] range:result.range];
    }];
    
    [[WCSyntaxHighlighter multilineCommentRegex] enumerateMatchesInString:self.textStorage.string options:0 range:NSMakeRange(0, self.textStorage.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [self.textStorage addAttributes:@{NSForegroundColorAttributeName : [NSColor colorWithCalibratedRed:0 green:0.5 blue:0 alpha:1], kMultilineCommentAttributeName : @true} range:result.range];
        
        if (NSMaxRange(result.range) > NSMaxRange(range))
            *stop = YES;
    }];
    
    [self.textStorage endEditing];
}

+ (NSDictionary *)defaultAttributes; {
    return @{ NSFontAttributeName : [NSFont userFixedPitchFontOfSize:13], NSForegroundColorAttributeName : [NSColor blackColor], kMultilineCommentAttributeName : @false};
}

+ (NSRegularExpression *)commentRegex; {
    static NSRegularExpression *retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[NSRegularExpression alloc] initWithPattern:@";+.*" options:0 error:NULL];
    });
    return retval;
}
+ (NSRegularExpression *)multilineCommentRegex; {
    static NSRegularExpression *retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[NSRegularExpression alloc] initWithPattern:@"#comment.*?#endcomment" options:NSRegularExpressionDotMatchesLineSeparators error:NULL];
    });
    return retval;
}
+ (NSRegularExpression *)stringRegex; {
    static NSRegularExpression *retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[NSRegularExpression alloc] initWithPattern:@"\".*?\"" options:0 error:NULL];
    });
    return retval;
}
+ (NSRegularExpression *)preProcessorRegex; {
    static NSRegularExpression *retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[NSRegularExpression alloc] initWithPattern:@"#(?:define|defcont|elif|else|endif|endmacro|if|ifdef|ifndef|import|include|macro|undef|undefine)\\b" options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    return retval;
}
+ (NSRegularExpression *)numberRegex; {
    static NSRegularExpression *retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[NSRegularExpression alloc] initWithPattern:@"(?:^|(?<=[^$%]\\b))[0-9]+\\b" options:0 error:NULL];
    });
    return retval;
}
+ (NSRegularExpression *)binaryNumberRegex; {
    static NSRegularExpression *retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[NSRegularExpression alloc] initWithPattern:@"(?:%[01]+\\b)|(?:(?:^|(?<=[^$%]\\b))[01]+(?:b|B)\\b)" options:0 error:NULL];
    });
    return retval;
}
+ (NSRegularExpression *)hexadecimalNumberRegex; {
    static NSRegularExpression *retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[NSRegularExpression alloc] initWithPattern:@"(?:\\$[A-Fa-f0-9]+\\b)|(?:(?:^|(?<=[^$%]\\b))[0-9a-fA-F]+(?:h|H)\\b)" options:0 error:NULL];
    });
    return retval;
}
+ (NSRegularExpression *)directiveRegex; {
    static NSRegularExpression *retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[NSRegularExpression alloc] initWithPattern:@"\\.(?:db|dw|end|org|byte|word|fill|block|addinstr|echo|error|list|nolist|equ|show|option|seek)\\b" options:NSRegularExpressionCaseInsensitive error:NULL];
    });
    return retval;
}
+ (NSRegularExpression *)registerRegex; {
    static NSRegularExpression *retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[NSRegularExpression alloc] initWithPattern:@"(?:\\baf')|(?:\\b(?:ixh|iyh|ixl|iyl|sp|af|pc|bc|de|hl|ix|iy|a|f|b|c|d|e|h|l|r|i)\\b)" options:0 error:NULL];
    });
    return retval;
}
+ (NSRegularExpression *)conditionalRegisterRegex; {
    static NSRegularExpression *retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[NSRegularExpression alloc] initWithPattern:@"(?:call|jp|jr|ret)\\s+(nz|nv|nc|po|pe|c|p|m|n|z|v)\\b" options:0 error:NULL];
    });
    return retval;
}
+ (NSRegularExpression *)operationalCodeRegex; {
    static NSRegularExpression *retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[NSRegularExpression alloc] initWithPattern:@"\\b(?:adc|add|and|bit|call|ccf|cpdr|cpd|cpir|cpi|cpl|cp|daa|dec|di|djnz|ei|exx|ex|halt|im|inc|indr|ind|inir|ini|in|jp|jr|lddr|ldd|ldir|ldi|ld|neg|nop|or|otdr|otir|outd|outi|out|pop|push|res|reti|retn|ret|rla|rlca|rlc|rld|rl|rra|rrca|rrc|rrd|rr|rst|sbc|scf|set|sla|sll|sra|srl|sub|xor)\\b" options:NSRegularExpressionAnchorsMatchLines error:NULL];
    });
    return retval;
}

+ (NSRegularExpression *)labelRegex; {
    static NSRegularExpression *retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[NSRegularExpression alloc] initWithPattern:@"^[A-Za-z0-9_!?]+" options:NSRegularExpressionAnchorsMatchLines error:NULL];
    });
    return retval;
}
+ (NSRegularExpression *)equateRegex; {
    static NSRegularExpression *retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[NSRegularExpression alloc] initWithPattern:@"^([A-Za-z0-9_!?]+)(?:(?:\\s*=)|(?:\\s+\\.(?:equ|EQU))|(?:\\s+(?:equ|EQU)))" options:NSRegularExpressionAnchorsMatchLines error:NULL];
    });
    return retval;
}
+ (NSRegularExpression *)defineRegex; {
    static NSRegularExpression *retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[NSRegularExpression alloc] initWithPattern:@"(?:#define|DEFINE)\\s+([A-Za-z0-9_.!?]+)" options:0 error:NULL];
    });
    return retval;
}
+ (NSRegularExpression *)macroRegex; {
    static NSRegularExpression *retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[NSRegularExpression alloc] initWithPattern:@"(?:#macro|MACRO)\\s+([A-Za-z0-9_.!?]+)" options:0 error:NULL];
    });
    return retval;
}

- (void)textStorageDidProcessEditing:(NSNotification *)note {
    if (([note.object editedMask] & NSTextStorageEditedCharacters) == 0)
        return;
    
    NSRange editedRange = [note.object editedRange];
    NSUInteger charIndex = editedRange.location;
    NSRange highlightRange = editedRange;
    
    if (charIndex < self.textStorage.length) {
        id attribute = [self.textStorage attribute:kMultilineCommentAttributeName atIndex:charIndex effectiveRange:NULL];
        
        if ([attribute boolValue])
            [self.textStorage attribute:kMultilineCommentAttributeName atIndex:charIndex longestEffectiveRange:&highlightRange inRange:NSMakeRange(0, self.textStorage.length)];
    }
    
    [self performSelector:@selector(_syntaxHighlightInRangeValue:) withObject:[NSValue valueWithRange:[self.textStorage.string lineRangeForRange:highlightRange]] afterDelay:0];
}

- (void)_syntaxHighlightInRangeValue:(NSValue *)rangeValue; {
    [self syntaxHighlightInRange:rangeValue.rangeValue];
}

@end
