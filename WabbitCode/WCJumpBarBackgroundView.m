//
//  WCJumpBarBackgroundView.m
//  WabbitStudio
//
//  Created by William Towe on 9/23/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCJumpBarBackgroundView.h"
#import "WCWindow.h"

@implementation WCJumpBarBackgroundView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    [super viewWillMoveToWindow:newWindow];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WCWindowFirstResponderDidChangeNotification object:nil];
    
    if (newWindow) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowDidBecomeKey:) name:NSWindowDidBecomeKeyNotification object:newWindow];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowDidResignKey:) name:NSWindowDidResignKeyNotification object:newWindow];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowFirstResponderDidChange:) name:WCWindowFirstResponderDidChangeNotification object:newWindow];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    static NSGradient *gradient, *keyGradient;
    static NSColor *fillColor, *keyFillColor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:209.0/255.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:244.0/255.0 alpha:1.0]];
        keyGradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:174.0/255.0 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:211.0/255.0 alpha:1.0]];
        keyFillColor = [NSColor colorWithCalibratedWhite:67.0/255.0 alpha:1.0];
        fillColor = [NSColor colorWithCalibratedWhite:109.0/255.0 alpha:1.0];
    });
    
    
    if (self.window.isKeyWindow &&
        [self.window.firstResponder isKindOfClass:[NSView class]] &&
        [(NSView *)self.window.firstResponder isDescendantOf:self.superview]) {
        
        [keyGradient drawInRect:self.bounds angle:90];
        [keyFillColor setFill];
    }
    else {
        [gradient drawInRect:self.bounds angle:90];
        [fillColor setFill];
    }
    
    NSRectFill(NSMakeRect(NSMinX(self.bounds), NSMinY(self.bounds), NSWidth(self.bounds), 1));
}

- (void)_windowDidBecomeKey:(NSNotification *)note {
    [self setNeedsDisplay:YES];
}
- (void)_windowDidResignKey:(NSNotification *)note {
    [self setNeedsDisplay:YES];
}
- (void)_windowFirstResponderDidChange:(NSNotification *)note {
    [self setNeedsDisplay:YES];
}

@end
