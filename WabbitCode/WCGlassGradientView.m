//
//  WCGlassGradientView.m
//  WabbitStudio
//
//  Created by William Towe on 12/25/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCGlassGradientView.h"
#import "WCDefines.h"

@implementation WCGlassGradientView

- (void)drawRect:(NSRect)dirtyRect {
    static NSGradient *gradient;
    static NSColor *topFillColor;
    static NSColor *bottomFillColor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gradient = [[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedWhite:(253.0f / 255.0f) alpha:1],0.0,[NSColor colorWithCalibratedWhite:(242.0f / 255.0f) alpha:1],0.45454,[NSColor colorWithCalibratedWhite:(230.0f / 255.0f) alpha:1],0.45454,[NSColor colorWithCalibratedWhite:(230.0f / 255.0f) alpha:1],1.0,nil];
        topFillColor = [NSColor colorWithCalibratedWhite:(180.0/255.0) alpha:1.0];
        bottomFillColor = [NSColor colorWithCalibratedWhite:(180.0/255.0) alpha:1.0];
    });
    
    [gradient drawInRect:self.bounds angle:270];
    
    WCGlassGradientViewEdges edges = self.edges;
    
    if ((edges & WCGlassGradientViewEdgesMinX) != 0) {
        [bottomFillColor setFill];
        NSRectFill(NSMakeRect(NSMinX(self.bounds), NSMinY(self.bounds), 1, NSHeight(self.frame)));
    }
    if ((edges & WCGlassGradientViewEdgesMaxX) != 0) {
        [bottomFillColor setFill];
        NSRectFill(NSMakeRect(NSMaxX(self.bounds) - 1, NSMinY(self.bounds), 1, NSHeight(self.frame)));
    }
    if ((edges & WCGlassGradientViewEdgesMinY) != 0) {
        [bottomFillColor setFill];
        NSRectFill(NSMakeRect(NSMinX(self.bounds), NSMinY(self.bounds), NSWidth(self.frame), 1));
    }
    if ((edges & WCGlassGradientViewEdgesMaxY) > 0) {
        [topFillColor setFill];
        NSRectFill(NSMakeRect(NSMinX(self.bounds), NSMaxY(self.bounds) - 1, NSWidth(self.frame), 1));
    }
}

- (void)setEdges:(WCGlassGradientViewEdges)edges {
    _edges = edges;
    
    [self setNeedsDisplay:YES];
}

@end
