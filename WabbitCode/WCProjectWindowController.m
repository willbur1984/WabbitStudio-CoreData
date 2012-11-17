//
//  WCProjectWindowController.m
//  WabbitStudio
//
//  Created by William Towe on 10/31/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCProjectWindowController.h"
#import "WCProjectDocument.h"
#import "WCProjectViewController.h"
#import "WCNavigatorControl.h"
#import "WCSearchViewController.h"
#import "WCIssueViewController.h"
#import "NSArray+WCExtensions.h"
#import "WCTabViewController.h"
#import "WCSplitView.h"
#import "NSColor+WCExtensions.h"
#import "WCTabView.h"

static NSString *const kProjectWindowToolbar = @"org.revsoft.wabbitcode.project.toolbar";

@interface WCProjectWindowController () <WCNavigatorControlDataSource,NSWindowDelegate,NSSplitViewDelegate,NSToolbarDelegate>

@property (weak,nonatomic) IBOutlet WCSplitView *mainSplitView;
@property (weak,nonatomic) IBOutlet WCNavigatorControl *navigatorControl;
@property (weak,nonatomic) IBOutlet MMTabBarView *tabBarView;
@property (weak,nonatomic) IBOutlet WCTabView *tabView;

@property (strong,nonatomic) NSArray *navigatorItems;
@property (readwrite,strong,nonatomic) WCTabViewController *tabViewController;

@end

@implementation WCProjectWindowController
#pragma mark *** Subclass Overrides ***
- (id)init {
    if (!(self = [super initWithWindowNibName:self.windowNibName]))
        return nil;
    
    return self;
}

- (NSString *)windowNibName {
    return @"WCProjectWindow";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self setNavigatorItems:@[[[WCProjectViewController alloc] initWithProjectWindowController:self],[[WCSearchViewController alloc] init],[[WCIssueViewController alloc] init]]];
    
    [self.window setDelegate:self];
    
    [self.mainSplitView setDividerColor:[NSColor colorWithCalibratedWhite:67.0/255.0 alpha:1]];
    [self.mainSplitView setDelegate:self];
    
    [self.navigatorControl setDataSource:self];
    [self.navigatorControl setSelectedItemIdentifier:[[self.navigatorItems objectAtIndex:0] identifier]];
    
    [self.tabView setEmptyString:NSLocalizedString(@"No Open Files", nil)];
    
    [self setTabViewController:[[WCTabViewController alloc] initWithTabBarView:self.tabBarView tabView:self.tabView]];
    
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:kProjectWindowToolbar];
    
    [toolbar setShowsBaselineSeparator:NO];
    [toolbar setDelegate:self];
    
    [self.window setToolbar:toolbar];
}
#pragma mark NSWindowDelegate
- (void)windowWillClose:(NSNotification *)notification {
    [self.navigatorControl setDataSource:nil];
    
    for (WCViewController *viewController in self.navigatorItems)
        [viewController cleanup];
}

#pragma mark NSSplitViewDelegate
- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view {
    if (splitView == self.mainSplitView) {
        if (view == [splitView.subviews WC_firstObject])
            return NO;
    }
    return YES;
}
#pragma mark NSToolbarDelegate
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return @[NSToolbarFlexibleSpaceItemIdentifier];
}
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return nil;
}
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    return nil;
}

#pragma mark WCNavigatorControlDataSource
- (NSInteger)numberOfItemsInNavigatorControl:(WCNavigatorControl *)navigatorControl {
    return self.navigatorItems.count;
}
- (id<NSCopying>)navigatorControl:(WCNavigatorControl *)navigatorControl identifierForItemAtIndex:(NSInteger)index {
    return [[self.navigatorItems objectAtIndex:index] identifier];
}
- (NSImage *)navigatorControl:(WCNavigatorControl *)navigatorControl imageForItemAtIndex:(NSInteger)index {
    return [[self.navigatorItems objectAtIndex:index] image];
}

- (NSView *)navigatorControl:(WCNavigatorControl *)navigatorControl contentViewForItemAtIndex:(NSInteger)index {
    return [[self.navigatorItems objectAtIndex:index] view];
}
- (NSString *)navigatorControl:(WCNavigatorControl *)navigatorControl toolTipForItemAtIndex:(NSInteger)index {
    return [[self.navigatorItems objectAtIndex:index] toolTip];
}

#pragma mark *** Public Methods ***

#pragma mark Properties
- (WCProjectDocument *)projectDocument {
    return (WCProjectDocument *)self.document;
}

@end
