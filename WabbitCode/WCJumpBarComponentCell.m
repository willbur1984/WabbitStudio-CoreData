//
//  WCJumpBarComponentCell.m
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

#import "WCJumpBarComponentCell.h"
#import "WCDefines.h"
#import "WCGeometry.h"

@interface WCJumpBarComponentCell ()
@property (strong,nonatomic) NSTextFieldCell *titleCell;
@end

@implementation WCJumpBarComponentCell

- (id)initTextCell:(NSString *)aString {
    if (!(self = [super initTextCell:aString]))
        return nil;
    
    [self setBackgroundStyle:NSBackgroundStyleRaised];
    [self setControlSize:NSSmallControlSize];
    
    [self setTitleCell:[[NSTextFieldCell alloc] initTextCell:aString]];
    [self.titleCell setBackgroundStyle:NSBackgroundStyleRaised];
    [self.titleCell setDrawsBackground:NO];
    [self.titleCell setControlSize:self.controlSize];
    [self.titleCell setFont:self.font];
    [self.titleCell setTextColor:self.textColor];
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    WCJumpBarComponentCell *copy = [[WCJumpBarComponentCell alloc] initTextCell:self.stringValue];
    
    return copy;
}

static const CGFloat kImageMarginLeft = 3;
static const CGFloat kTitleMarginLeft = 1;

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSRect titleRect = cellFrame;
    
    if (self.image) {
        NSRect imageRect = NSMakeRect(NSMinX(titleRect) + kImageMarginLeft, NSMinY(titleRect), WC_NSSmallSize.width, NSHeight(titleRect));
        
        [self.image setSize:WC_NSSmallSize];
        [self.image drawInRect:WC_NSRectCenterY(NSMakeRect(NSMinX(imageRect), 0, WC_NSSmallSize.width, WC_NSSmallSize.height), imageRect) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
        
        titleRect = NSMakeRect(NSMaxX(imageRect), NSMinY(titleRect), NSMaxX(titleRect) - NSMaxX(imageRect), NSHeight(titleRect));
    }
    
    if ([(NSPathControl *)controlView pathComponentCells].lastObject != self) {
        NSImage *image = [NSImage imageNamed:@"GCJumpBarSeparator"];
        
        [image drawInRect:WC_NSRectCenterY(NSMakeRect(NSMaxX(titleRect) - image.size.width, 0, image.size.width, image.size.height), titleRect) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1 respectFlipped:YES hints:nil];
        
        titleRect = NSMakeRect(NSMinX(titleRect), NSMinY(titleRect), NSWidth(titleRect) - image.size.width, NSHeight(titleRect));
    }
    
    [self.titleCell setAttributedStringValue:self.attributedStringValue];
    [self.titleCell drawWithFrame:WC_NSRectCenterY(NSMakeRect(NSMinX(titleRect) + kTitleMarginLeft, 0, NSWidth(titleRect) - kTitleMarginLeft, self.attributedStringValue.size.height), titleRect) inView:controlView];
}

@end
