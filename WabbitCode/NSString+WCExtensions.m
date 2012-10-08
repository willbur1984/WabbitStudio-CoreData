//
//  NSString+WCExtensions.m
//  WabbitStudio
//
//  Created by William Towe on 9/22/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "NSString+WCExtensions.h"
#import "WCSymbolScanner.h"
#import "WCGeometry.h"

@implementation NSString (WCExtensions)

+ (NSString *)WC_UUIDString; {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *retval = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    
    CFRelease(uuid);
    
    return retval;
}

- (NSRange)WC_symbolRangeForRange:(NSRange)range; {
    __block NSRange retval = WC_NSNotFoundRange;
    
    [[WCSymbolScanner symbolRegex] enumerateMatchesInString:self options:0 range:[self lineRangeForRange:range] usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (NSLocationInRange(range.location, result.range)) {
            retval = result.range;
            *stop = YES;
        }
    }];
    
    return retval;
}

- (NSUInteger)WC_lineNumberForRange:(NSRange)range; {
    __block NSUInteger retval = 0;
    
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByLines|NSStringEnumerationSubstringNotRequired usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if (NSLocationInRange(range.location, enclosingRange)) {
            *stop = YES;
            return;
        }
        
        retval++;
    }];
    
    return retval;
}
- (NSRange)WC_rangeForLineNumber:(NSUInteger)lineNumber; {
	__block NSRange range = WC_NSEmptyRange;
	__block NSInteger lineNumberCopy = lineNumber;
	
	[self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByLines|NSStringEnumerationSubstringNotRequired usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		if ((--lineNumberCopy) < 0) {
			range = enclosingRange;
			*stop = YES;
		}
	}];
	
	return range;
}

@end
