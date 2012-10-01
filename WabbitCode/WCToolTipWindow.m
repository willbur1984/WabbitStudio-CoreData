//
//  WCToolTipWindow.m
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

#import "WCToolTipWindow.h"
#import "WCDefines.h"

@interface WCToolTipWindow ()
@property (strong,nonatomic) NSTextField *textField;
@property (strong,nonatomic) NSDate *orderedFrontDate;
@property (readonly,nonatomic) NSDictionary *defaultAttributes;
@property (weak,nonatomic) id eventMonitor;
@end

@implementation WCToolTipWindow

- (id)init {
    if (!(self = [super initWithContentRect:NSZeroRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO]))
        return nil;
    
    [self setReleasedWhenClosed:NO];
    [self setAlphaValue:0.97];
    [self setOpaque:NO];
    [self setBackgroundColor:[NSColor colorWithCalibratedRed:1.0 green:0.96 blue:0.76 alpha:1.0]];
    [self setHasShadow:YES];
    [self setLevel:NSStatusWindowLevel];
    [self setHidesOnDeactivate:YES];
    [self setIgnoresMouseEvents:YES];
    
    [self setTextField:[[NSTextField alloc] initWithFrame:NSZeroRect]];
    [self.textField setEditable:NO];
    [self.textField setSelectable:NO];
    [self.textField setBezeled:NO];
    [self.textField setBordered:NO];
    [self.textField setDrawsBackground:NO];
    [self.textField setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [self.textField setAttributedStringValue:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"This is a tool tip!", nil) attributes:self.defaultAttributes]];
    
    [self setContentView:self.textField];
    [self setFrame:[self frameRectForContentRect:self.textField.frame] display:NO];
    
    return self;
}

+ (WCToolTipWindow *)sharedInstance {
    static id retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[[self class] alloc] init];
    });
    return retval;
}

- (void)showString:(NSString *)string atPoint:(NSPoint)point; {
    WCAssert(string,@"tooltip string cannot be nil!");
    
    [self showAttributedString:[[NSAttributedString alloc] initWithString:string attributes:self.defaultAttributes] atPoint:point];
}

static const NSTimeInterval kDismissThreshold = 1.5;

- (void)showAttributedString:(NSAttributedString *)attributedString atPoint:(NSPoint)point; {
    WCAssert(attributedString,@"attributed tooltip string cannot be nil!");
    
    [self.textField setAttributedStringValue:attributedString];
    [self.textField sizeToFit];
    
    NSRect screenFrame = [NSScreen mainScreen].visibleFrame;
    NSRect windowFrame = [self frameRectForContentRect:self.textField.frame];
    
    windowFrame.size.width = MIN(NSWidth(windowFrame), NSWidth(screenFrame));
    windowFrame.size.height = MIN(NSHeight(windowFrame), NSHeight(screenFrame));
    
    [self setFrame:windowFrame display:NO];
    
    point.x = MAX(NSMinX(screenFrame), MIN(point.x, NSMaxX(screenFrame) - NSWidth(windowFrame)));
    point.y = MIN(MAX(NSMinY(screenFrame) + NSHeight(windowFrame), point.y), NSMaxY(screenFrame));
    
    [self setFrameTopLeftPoint:point];
    [self setAlphaValue:1];
    [self orderFront:nil];
    
    [self setOrderedFrontDate:[NSDate date]];
    
    __block typeof (self) blockSelf = self;
    
    id eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSLeftMouseDownMask|NSRightMouseDownMask|NSOtherMouseDownMask|NSMouseMovedMask|NSKeyDownMask|NSScrollWheelMask handler:^NSEvent *(NSEvent *event) {
        switch (event.type) {
            case NSMouseMoved:
                if ([[NSDate date] timeIntervalSinceDate:self.orderedFrontDate] > kDismissThreshold) {
                    [blockSelf hideToolTipWindow];
                }
                break;
            default:
                [blockSelf hideToolTipWindow];
                break;
        }
        return event;
    }];
    
    [self setEventMonitor:eventMonitor];
}

- (void)hideToolTipWindow; {
    if (!self.isVisible)
        return;
    
    __block typeof (self) blockSelf = self;
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setDuration:0.3];
        
        [blockSelf.animator setAlphaValue:0];
    } completionHandler:^{
        [blockSelf orderOut:nil];
    }];
    
    [blockSelf setEventMonitor:nil];
}

- (NSDictionary *)defaultAttributes {
    return @{NSFontAttributeName : [NSFont labelFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]], NSForegroundColorAttributeName : [NSColor blackColor]};
}

- (void)setEventMonitor:(id)eventMonitor {
    if (_eventMonitor)
        [NSEvent removeMonitor:_eventMonitor];
    
    _eventMonitor = eventMonitor;
}

@end
