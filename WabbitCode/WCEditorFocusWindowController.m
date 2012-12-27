//
//  WCEditorFocusWindowController.m
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

#import "WCEditorFocusWindowController.h"
#import "iCarousel.h"
#import "WCProjectDocument.h"
#import "WCEditorFocusWindow.h"
#import "WCDefines.h"
#import "WCEditorFocusCell.h"
#import "WCTabViewController.h"
#import "WCTabView.h"

@interface WCEditorFocusWindowController () <iCarouselDataSource,iCarouselDelegate,WCEditorFocusCellDelegate>
@property (weak,nonatomic) WCProjectDocument *projectDocument;
@property (weak,nonatomic) id eventMonitor;
@property (strong,nonatomic) iCarousel *carouselView;
@end

@implementation WCEditorFocusWindowController

- (id)initWithWindow:(NSWindow *)window {
    if (!(self = [super initWithWindow:window]))
        return nil;
    
    [self setCarouselView:[[iCarousel alloc] initWithFrame:[self.window.contentView bounds]]];
    [self.carouselView setType:iCarouselTypeCoverFlow];
    [self.carouselView setCenterItemWhenSelected:YES];
    [self.carouselView setBounces:NO];
    [self.carouselView setDataSource:self];
    [self.carouselView setDelegate:self];
    [self.window.contentView addSubview:self.carouselView];
    
    return self;
}

+ (WCEditorFocusWindowController *)sharedWindowController; {
    static id retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[[self class] alloc] initWithWindow:[[WCEditorFocusWindow alloc] initWithContentRect:NSMakeRect(0, 0, 400, 200)]];
    });
    return retval;
}

- (void)showWindow:(id)sender {
    [super showWindow:nil];
    [self.window center];
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return self.projectDocument.windowControllers.count;
}
- (NSView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(NSView *)view {
    WCEditorFocusCell *cell = (WCEditorFocusCell *)view;
    
    if (!cell) {
        cell = [[WCEditorFocusCell alloc] initWithFrame:NSMakeRect(0, 0, [self carouselItemWidth:carousel], ceil(NSHeight(carousel.frame) * 0.65))];
        
        [cell setDelegate:self];
    }
    
    id windowController = [self.projectDocument.windowControllers objectAtIndex:index];
    
    [cell setTabViewController:[windowController tabViewController]];
    
    return cell;
}
- (CGFloat)carouselItemWidth:(iCarousel *)carousel {
    return ceil(NSWidth(carousel.frame) * 0.5);
}
- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    [self.window makeFirstResponder:[carousel itemViewAtIndex:carousel.currentItemIndex]];
}

- (void)editorFocusCellDidPressReturn:(WCEditorFocusCell *)cell {
    WCTabViewController *tabViewController = cell.tabViewController;
    
    if (cell.highlightedTabIndex != -1) {
        [tabViewController.tabView selectTabViewItemAtIndex:cell.highlightedTabIndex];
    }
    else if (cell.highlightedTextViewControllerIndex != -1) {
        
    }
    
    [self hideEditorFocusWindow];
}

- (void)showEditorFocusWindowForProjectDocument:(WCProjectDocument *)projectDocument; {
    [self setProjectDocument:projectDocument];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setDuration:0];
        
        [self.window.animator setAlphaValue:1];
    } completionHandler:nil];
    
    [self showWindow:nil];
    
    __unsafe_unretained typeof (self) weakSelf = self;
    
    id eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSLeftMouseDownMask|NSRightMouseDownMask|NSOtherMouseDownMask|NSKeyDownMask|NSFlagsChangedMask handler:^NSEvent *(NSEvent *event) {
        switch (event.type) {
            case NSLeftMouseDown:
            case NSRightMouseDown:
            case NSOtherMouseDown:
                if (event.window != weakSelf.window)
                    [weakSelf hideEditorFocusWindow];
                break;
            case NSKeyDown:
                switch (event.keyCode) {
                    case KEY_CODE_ESCAPE:
                        [weakSelf hideEditorFocusWindow];
                        return nil;
                        break;
                    default:
                        break;
                }
                break;
            default:
                break;
        }
        return event;
    }];
    
    [self setEventMonitor:eventMonitor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidResignActive:) name:NSApplicationWillResignActiveNotification object:nil];
}
- (void)hideEditorFocusWindow; {
    if (!self.window.isVisible)
        return;
    
    [self setEventMonitor:nil];
    [self setProjectDocument:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationWillResignActiveNotification object:nil];
    
    __unsafe_unretained typeof (self) weakSelf = self;
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setDuration:0.25];
        
        [weakSelf.window.animator setAlphaValue:0];
    } completionHandler:^{
        if (weakSelf.window.alphaValue == 0)
            [weakSelf.window orderOut:nil];
    }];
}

- (void)setEventMonitor:(id)eventMonitor {
    if (_eventMonitor)
        [NSEvent removeMonitor:_eventMonitor];
    
    _eventMonitor = eventMonitor;
}
- (void)setProjectDocument:(WCProjectDocument *)projectDocument {
    _projectDocument = projectDocument;
    
    [self.carouselView reloadData];
    
    if (self.carouselView.numberOfItems > 0) {
        [self.carouselView scrollToOffset:1 duration:0];
        [self.carouselView scrollToOffset:0 duration:0];
        [self.window makeFirstResponder:[self.carouselView itemViewAtIndex:0]];
    }
}

- (void)_applicationDidResignActive:(NSNotification *)note {
    [self hideEditorFocusWindow];
}

@end
