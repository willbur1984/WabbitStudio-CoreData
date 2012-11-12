//
//  WCFindBarBackgroundView.m
//  WabbitStudio
//
//  Created by William Towe on 11/10/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCFindBarBackgroundView.h"

@implementation WCFindBarBackgroundView

- (void)drawRect:(NSRect)dirtyRect {
    static NSGradient *fillGradient;
	static NSColor *bottomFillColor;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		fillGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:236.0/255.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:197.0/255.0 alpha:1.0]];
		bottomFillColor = [NSColor colorWithCalibratedWhite:135.0/255.0 alpha:1.0];
	});
	
	[fillGradient drawInRect:[self bounds] angle:270.0];
	
	[bottomFillColor setFill];
	NSRectFill(NSMakeRect(NSMinX([self bounds]), NSMinY([self bounds]), NSWidth([self bounds]), 1.0));
}

@end
