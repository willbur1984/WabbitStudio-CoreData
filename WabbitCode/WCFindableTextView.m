//
//  WCFindableTextView.m
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

#import "WCFindableTextView.h"
#import "WCFindBarViewController.h"
#import "WCDefines.h"
#import "NSTextView+WCExtensions.h"
#import "WCGeometry.h"

static char kWCFindableTextViewObservingContext;

@interface WCFindableTextView () <NSUserInterfaceValidations>
@property (readwrite,strong,nonatomic) WCFindBarViewController *findBarViewController;

- (void)_WCFindableTextView_init;
@end

@implementation WCFindableTextView
- (void)dealloc {
    [self.findBarViewController removeObserver:self forKeyPath:@"findRanges" context:&kWCFindableTextViewObservingContext];
    [self.findBarViewController removeObserver:self forKeyPath:@"findRangesAreDirty" context:&kWCFindableTextViewObservingContext];
    [self.findBarViewController cleanup];
}

- (id)initWithFrame:(NSRect)frameRect {
    if (!(self = [super initWithFrame:frameRect]))
        return nil;
    
    [self _WCFindableTextView_init];
    
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;
    
    [self _WCFindableTextView_init];
    
    return self;
}
#pragma mark NSResponder
- (void)performTextFinderAction:(id)sender {
    [self.findBarViewController performTextFinderAction:sender];
}
- (void)performFindPanelAction:(id)sender {
    [self.findBarViewController performTextFinderAction:sender];
}

#pragma mark NSTextView
- (void)drawViewBackgroundInRect:(NSRect)rect {
    [super drawViewBackgroundInRect:rect];
    
    if (self.findBarViewController.view.superview && self.findBarViewController.findRanges.count > 0 && !self.findBarViewController.findRangesAreDirty) {
        NSDictionary *findRangeAttributes = [WCFindBarViewController findRangeAttributes];
        __unsafe_unretained typeof (self) weakSelf = self;
        
        [self.findBarViewController.findRanges enumerateRangesInRange:[self WC_visibleRange] options:0 usingBlock:^(NSRange range, BOOL *stop) {
            NSUInteger rectCount;
            NSRectArray rects = [weakSelf.layoutManager rectArrayForCharacterRange:range withinSelectedCharacterRange:WC_NSNotFoundRange inTextContainer:weakSelf.textContainer rectCount:&rectCount];
            
            if (rectCount == 0)
                return;
            
            for (NSUInteger rectIndex=0; rectIndex<rectCount; rectIndex++) {
                NSRect temp = rects[rectIndex];
                
                [[findRangeAttributes objectForKey:NSBackgroundColorAttributeName] setFill];
                NSRectFillUsingOperation(temp, NSCompositeSourceOver);
                
                temp.origin.y += temp.size.height - 2;
                temp.size.height = 2;
                
                [[findRangeAttributes objectForKey:NSUnderlineColorAttributeName] setFill];
                NSRectFillUsingOperation(temp, NSCompositeSourceOver);
            }
        }];
    }
}
#pragma mark NSKeyValueObserving
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &kWCFindableTextViewObservingContext) {
        if ([keyPath isEqualToString:@"findRanges"]) {
            [self setNeedsDisplayInRect:self.visibleRect avoidAdditionalLayout:YES];
        }
        else if ([keyPath isEqualToString:@"findRangesAreDirty"]) {
            [self setNeedsDisplayInRect:self.visibleRect avoidAdditionalLayout:YES];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark NSUserInterfaceValidations
- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem {
    if ([anItem action] == @selector(performTextFinderAction:) ||
        [anItem action] == @selector(performFindPanelAction:)) {
        
        return [self.findBarViewController validateUserInterfaceItem:anItem];
    }
    return [super validateUserInterfaceItem:anItem];
}

- (void)_WCFindableTextView_init; {
    [self setFindBarViewController:[[WCFindBarViewController alloc] initWithTextView:self]];
    
    [self.findBarViewController addObserver:self forKeyPath:@"findRanges" options:0 context:&kWCFindableTextViewObservingContext];
    [self.findBarViewController addObserver:self forKeyPath:@"findRangesAreDirty" options:0 context:&kWCFindableTextViewObservingContext];
}
@end
