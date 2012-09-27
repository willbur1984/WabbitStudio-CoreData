//
//  NSArray+WCExtensions.m
//  WabbitStudio
//
//  Created by William Towe on 9/18/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "NSArray+WCExtensions.h"
#import "Symbol.h"
#import "WCGeometry.h"

@implementation NSArray (WCExtensions)

- (NSUInteger)WC_lineNumberForRange:(NSRange)range; {
    NSUInteger left = 0, right = self.count, middle, lineStartIndex;
    
    while ((right - left) > 1) {
        middle = (right + left) / 2;
        lineStartIndex = [[self objectAtIndex:middle] unsignedIntegerValue];
        
        if (range.location < lineStartIndex)
            right = middle;
        else if (range.location > lineStartIndex)
            left = middle;
        else
            return middle;
    }
    return left;
}

- (NSUInteger)WC_symbolIndexForRange:(NSRange)range; {
    NSUInteger left = 0, right = self.count, middle, lineStartIndex;
    
    while ((right - left) > 1) {
        middle = (right + left) / 2;
        lineStartIndex = [[(Symbol *)[self objectAtIndex:middle] location] unsignedIntegerValue];
        
        if (range.location < lineStartIndex)
            right = middle;
        else if (range.location > lineStartIndex)
            left = middle;
        else
            return middle;
    }
    return left;
}

- (NSRange)WC_rangeForRange:(NSRange)range; {
    NSUInteger left = 0, right = self.count, middle, lineStartIndex;
    
    while ((right - left) > 1) {
        middle = (right + left) / 2;
        lineStartIndex = [[self objectAtIndex:middle] rangeValue].location;
        
        if (range.location < lineStartIndex)
            right = middle;
        else if (range.location > lineStartIndex)
            left = middle;
        else
            return [[self objectAtIndex:middle] rangeValue];
    }
    return (self.count) ? [[self objectAtIndex:left] rangeValue] : WC_NSNotFoundRange;
}

@end
