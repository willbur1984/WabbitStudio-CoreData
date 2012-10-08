//
//  WCSearchFieldBackgroundView.m
//  WabbitStudio
//
//  Created by William Towe on 10/7/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCSearchFieldBackgroundView.h"
#import "NSColor+WCExtensions.h"

@implementation WCSearchFieldBackgroundView

- (void)drawRect:(NSRect)dirtyRect {
    static NSGradient *kGradient;
    static NSColor *kFillColor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kGradient = [[NSGradient alloc] initWithStartingColor:[NSColor WC_colorWithHexadecimalString:@"d1d1d1"] endingColor:[NSColor WC_colorWithHexadecimalString:@"f0f0f0"]];
        kFillColor = [NSColor WC_colorWithHexadecimalString:@"999999"];
    });
    
    [kGradient drawInRect:self.bounds angle:90];
    
    [kFillColor setFill];
    NSRectFill(NSMakeRect(0, NSMinY(self.bounds), NSWidth(self.bounds), 1));
}

@end
