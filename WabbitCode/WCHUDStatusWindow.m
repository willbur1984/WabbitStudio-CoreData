//
//  WCHUDStatusWindow.m
//  WabbitStudio
//
//  Created by William Towe on 10/6/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCHUDStatusWindow.h"
#import "WCHUDStatusContentView.h"
#import "WCGeometry.h"

@interface WCHUDStatusWindow ()
@property (weak,nonatomic) NSTimer *fadeTimer;
@property (strong,nonatomic) NSImageView *imageView;
@property (assign,nonatomic) BOOL shouldOrderOutAfterFade;
@end

@implementation WCHUDStatusWindow

- (id)init {
    if (!(self = [super initWithContentRect:NSZeroRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO]))
        return nil;
    
    [self setReleasedWhenClosed:NO];
    [self setOpaque:NO];
    [self setBackgroundColor:[NSColor clearColor]];
    [self setHasShadow:NO];
    [self setLevel:NSStatusWindowLevel];
    [self setHidesOnDeactivate:YES];
    [self setIgnoresMouseEvents:YES];
    
    [self setContentView:[[WCHUDStatusContentView alloc] initWithFrame:NSZeroRect]];
    
    [self setImageView:[[NSImageView alloc] initWithFrame:NSZeroRect]];
    [self.imageView setImageAlignment:NSImageAlignCenter];
    [self.imageView setImageFrameStyle:NSImageFrameNone];
    [self.imageView setImageScaling:NSImageScaleNone];
    [self.contentView addSubview:self.imageView];
    
    return self;
}

+ (WCHUDStatusWindow *)sharedInstance; {
    static id retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[[self class] alloc] init];
    });
    return retval;
}

- (void)showImage:(NSImage *)image inView:(NSView *)view; {
    [self showImage:image inView:view drawBackground:YES];
}
- (void)showImage:(NSImage *)image inView:(NSView *)view drawBackground:(BOOL)drawBackground; {
    [self setFadeTimer:nil];
    
    [self.imageView setImage:image];
    [self.imageView setFrameSize:image.size];
    
    [(WCHUDStatusContentView *)self.contentView setDrawBackground:drawBackground];
    [self.contentView setFrameSize:self.imageView.frame.size];
    
    NSRect viewFrame = WC_NSRectCenterWithSize(image.size, view.frame);
    NSRect screenFrame = [view.window convertRectToScreen:[view convertRect:viewFrame toView:nil]];
    
    [self setFrame:[self frameRectForContentRect:screenFrame] display:NO];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setDuration:0];
        
        [self.animator setAlphaValue:1];
    } completionHandler:nil];
    
    [self orderFront:nil];
    
    [self setFadeTimer:[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(_fadeTimerCallback:) userInfo:nil repeats:NO]];
}
- (void)hideHUDStatusWindowAnimated:(BOOL)animated; {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setDuration:(animated)?0.3:0];
        
        [self.animator setAlphaValue:0];
    } completionHandler:^{
        if (self.alphaValue == 0)
            [self orderOut:nil];
    }];
}

- (void)setFadeTimer:(NSTimer *)fadeTimer {
    if (_fadeTimer)
        [_fadeTimer invalidate];
    
    _fadeTimer = fadeTimer;
}

- (void)_fadeTimerCallback:(NSTimer *)timer {
    [self hideHUDStatusWindowAnimated:YES];
}

@end
