//
//  WCEditorFocusContentView.m
//  WabbitStudio
//
//  Created by William Towe on 12/26/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCEditorFocusContentView.h"
#import "NSColor+WCExtensions.h"
#import "WCDefines.h"
#import "NSBezierPath+StrokeExtensions.h"

@implementation WCEditorFocusContentView

- (id)initWithFrame:(NSRect)frameRect {
    if (!(self = [super initWithFrame:frameRect]))
        return nil;
    
    [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    static NSGradient *gradient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gradient = [[NSGradient alloc] initWithStartingColor:[NSColor WC_colorWithHexadecimalString:@"6a6a6a"] endingColor:[NSColor WC_colorWithHexadecimalString:@"262626"]];
    });
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:5 yRadius:5];
    
    [gradient drawInBezierPath:path angle:-90];
    
    [[NSColor whiteColor] setStroke];
    [path strokeInside];
}

@end
