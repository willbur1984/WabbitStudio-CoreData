//
//  WCNavigatorControl.m
//  WabbitStudio
//
//  Created by William Towe on 11/3/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCNavigatorControl.h"
#import "NSColor+WCExtensions.h"
#import "WCGeometry.h"
#import "DMTabBarItem.h"
#import "WCDefines.h"

static const CGFloat kItemWidth = 32;

@interface WCNavigatorControl ()
@property (strong,nonatomic) NSMutableArray *cells;
@property (strong,nonatomic) NSMutableDictionary *toolTipTagsToStrings;

- (void)_commonInit;
@end

@implementation WCNavigatorControl

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;
    
    [self _commonInit];
    
    return self;
}
- (id)initWithFrame:(NSRect)frameRect {
    if (!(self = [super initWithFrame:frameRect]))
        return nil;
    
    [self _commonInit];
    
    return self;
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    [super viewWillMoveToWindow:newWindow];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
    
    if (newWindow) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowDidBecomeKey:) name:NSWindowDidBecomeKeyNotification object:newWindow];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_windowDidResignKey:) name:NSWindowDidResignKeyNotification object:newWindow];
    }
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    [super resizeSubviewsWithOldSize:oldSize];
    
    CGFloat totalWidth = self.cells.count * kItemWidth;
    CGFloat frameX = floor(NSWidth(self.bounds) * 0.5) - floor(totalWidth * 0.5);
    
    for (DMTabBarItem *cell in self.cells) {
        NSButton *button = cell.tabBarItemButton;
        
        [button setFrameOrigin:NSMakePoint(frameX, NSMinY(button.frame))];
        
        frameX = NSMaxX(button.frame);
    }
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    
    if (self.toolTipTagsToStrings.count > 0) {
        for (NSNumber *tag in self.toolTipTagsToStrings.allKeys)
            [self removeToolTip:tag.integerValue];
        
        [self.toolTipTagsToStrings removeAllObjects];
    }
    
    if ([self.dataSource respondsToSelector:@selector(navigatorControl:toolTipForItemAtIndex:)]) {
        __weak typeof (self) weakSelf = self;
        
        [self.cells enumerateObjectsUsingBlock:^(DMTabBarItem *cell, NSUInteger idx, BOOL *stop) {
            NSString *toolTip = [weakSelf.dataSource navigatorControl:weakSelf toolTipForItemAtIndex:idx];
            
            if (toolTip.length) {
                NSToolTipTag tag = [weakSelf addToolTipRect:cell.tabBarItemButton.frame owner:weakSelf userData:NULL];
                
                [weakSelf.toolTipTagsToStrings setObject:toolTip forKey:@(tag)];
            }
        }];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    static NSGradient *gradient;
    static NSGradient *nonKeyGradient;
    static NSColor *separatorColor;
    static NSColor *nonKeySeparatorColor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gradient = [[NSGradient alloc] initWithStartingColor:[NSColor WC_colorWithHexadecimalString:@"dadada"] endingColor:[NSColor WC_colorWithHexadecimalString:@"bcbcbc"]];
        nonKeyGradient = [[NSGradient alloc] initWithStartingColor:[NSColor WC_colorWithHexadecimalString:@"f6f6f6"] endingColor:[NSColor WC_colorWithHexadecimalString:@"dadada"]];
        separatorColor = [NSColor WC_colorWithHexadecimalString:@"555555"];
        nonKeySeparatorColor = [NSColor WC_colorWithHexadecimalString:@"808080"];
    });
    
    if (self.window.isKeyWindow)
        [gradient drawInRect:self.bounds angle:-90];
    else
        [nonKeyGradient drawInRect:self.bounds angle:-90];
    
    if (self.window.isKeyWindow)
        [separatorColor setFill];
    else
        [nonKeySeparatorColor setFill];
    
    NSRectFill(NSMakeRect(0, NSMinY(self.bounds), NSWidth(self.bounds), 1));
}

- (NSString *)view:(NSView *)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:(void *)data {
    return [self.toolTipTagsToStrings objectForKey:@(tag)];
}

- (void)reloadData {
    for (DMTabBarItem *cell in self.cells)
        [cell.tabBarItemButton removeFromSuperview];
    
    [self.cells removeAllObjects];
    
    NSInteger numberOfItems = [self.dataSource numberOfItemsInNavigatorControl:self];
    
    for (NSInteger itemIndex=0; itemIndex<numberOfItems; itemIndex++) {
        NSImage *image = [self.dataSource navigatorControl:self imageForItemAtIndex:itemIndex];
        DMTabBarItem *cell = [[DMTabBarItem alloc] initWithIcon:image tag:itemIndex];
        
        [cell sendActionOn:NSLeftMouseUpMask];
        
        NSButton *button = cell.tabBarItemButton;
        
        [button sendActionOn:NSLeftMouseUpMask];
        [button setFrame:NSMakeRect(0, 0, kItemWidth, NSHeight(self.bounds))];
        [button setState:NSOffState];
        [button setTarget:self];
        [button setAction:@selector(_buttonAction:)];
        
        [self addSubview:button];
        [self.cells addObject:cell];
    }
    
    [self resizeSubviewsWithOldSize:self.frame.size];
}

- (void)setDataSource:(id<WCNavigatorControlDataSource>)dataSource {
    _dataSource = dataSource;
    
    [self reloadData];
}
- (void)setSelectedItemIdentifier:(id<NSCopying,NSObject>)selectedItemIdentifier {
    if ([_selectedItemIdentifier isEqual:selectedItemIdentifier])
        return;
    
    _selectedItemIdentifier = selectedItemIdentifier;
    
    NSInteger selectedItemIndex = NSNotFound;
    
    for (DMTabBarItem *cell in self.cells) {
        if ([[self.dataSource navigatorControl:self identifierForItemAtIndex:cell.tag] isEqual:selectedItemIdentifier]) {
            [cell.tabBarItemButton setState:NSOnState];
            
            selectedItemIndex = cell.tag;
        }
        else
            [cell.tabBarItemButton setState:NSOffState];
    }
    
    if (self.containerView && [self.dataSource respondsToSelector:@selector(navigatorControl:contentViewForItemAtIndex:)]) {
        NSView *contentView = [self.dataSource navigatorControl:self contentViewForItemAtIndex:selectedItemIndex];
        
        if (contentView) {
            [contentView setFrameSize:self.containerView.frame.size];
            
            if (self.containerView.subviews.count > 0)
                [self.containerView replaceSubview:self.containerView.subviews.lastObject with:contentView];
            else
                [self.containerView addSubview:contentView];
        }
    }
}

- (void)_commonInit; {
    [self setCells:[NSMutableArray arrayWithCapacity:0]];
    [self setToolTipTagsToStrings:[NSMutableDictionary dictionaryWithCapacity:0]];
}

- (IBAction)_buttonAction:(NSButton *)sender {
    [self setSelectedItemIdentifier:[self.dataSource navigatorControl:self identifierForItemAtIndex:sender.tag]];
}

- (void)_windowDidBecomeKey:(NSNotification *)note {
    [self setNeedsDisplay:YES];
}
- (void)_windowDidResignKey:(NSNotification *)note {
    [self setNeedsDisplay:YES];
}

@end
