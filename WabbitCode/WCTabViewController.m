//
//  WCTabViewController.m
//  WabbitStudio
//
//  Created by William Towe on 11/4/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCTabViewController.h"
#import "MMTabBarView.h"
#import "MMAttachedTabBarButton.h"
#import "WCTextViewController.h"
#import "WCSourceFileDocument.h"
#import "WCDocumentController.h"
#import "WCProjectDocument.h"
#import "WCTextView.h"

@interface WCTabViewController () <MMTabBarViewDelegate,WCTextViewControllerDelegate>

@property (weak,nonatomic) IBOutlet MMTabBarView *tabBarView;
@property (strong,nonatomic) NSMapTable *sourceFileDocumentsToTextViewControllers;
@property (strong,nonatomic) NSMapTable *textViewControllersToSourceFileDocuments;
@end

@implementation WCTabViewController

- (id)init {
    if (!(self = [super init]))
        return nil;
    
    [self setSourceFileDocumentsToTextViewControllers:[NSMapTable mapTableWithWeakToStrongObjects]];
    [self setTextViewControllersToSourceFileDocuments:[NSMapTable mapTableWithWeakToWeakObjects]];
    
    return self;
}

- (NSString *)nibName {
    return @"WCTabView";
}

- (void)loadView {
    [super loadView];
    
    [self.tabBarView setStyleNamed:@"Safari"];
    [self.tabBarView setOnlyShowCloseOnHover:NO];
    [self.tabBarView setCanCloseOnlyTab:YES];
    [self.tabBarView setHideForSingleTab:NO];
    [self.tabBarView setShowAddTabButton:NO];
    [self.tabBarView setUseOverflowMenu:YES];
    [self.tabBarView setAllowsBackgroundTabClosing:YES];
    [self.tabBarView setSelectsTabsOnMouseDown:YES];
    [self.tabBarView setAutomaticallyAnimates:NO];
    [self.tabBarView setAlwaysShowActiveTab:YES];
    [self.tabBarView setAllowsScrubbing:NO];
    [self.tabBarView setTearOffStyle:MMTabBarTearOffMiniwindow];
}

#pragma mark MMTabBarViewDelegate
- (void)tabView:(NSTabView *)aTabView didCloseTabViewItem:(NSTabViewItem *)tabViewItem {
    [self removeTabBarItemForSourceFileDocument:tabViewItem.identifier];
}
#pragma mark WCTextViewControllerDelegate

#pragma mark *** Public Methods ***
- (WCTextViewController *)addTabBarItemForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument; {
    if (!sourceFileDocument)
        return nil;
    
    WCTextViewController *retval = [self.sourceFileDocumentsToTextViewControllers objectForKey:sourceFileDocument];
    
    if (!retval) {
        NSTabViewItem *item = [[NSTabViewItem alloc] initWithIdentifier:sourceFileDocument];
        WCTextViewController *textViewController = [[WCTextViewController alloc] initWithSourceFileDocument:sourceFileDocument];
        
        [textViewController setDelegate:self];
        
        [item setView:textViewController.view];
        [item setInitialFirstResponder:textViewController.textView];
        
        [self.sourceFileDocumentsToTextViewControllers setObject:textViewController forKey:sourceFileDocument];
        [self.textViewControllersToSourceFileDocuments setObject:sourceFileDocument forKey:textViewController];
        
        [self.tabBarView addAttachedButtonForTabViewItem:item];
        
        retval = textViewController;
    }
    
    return retval;
}
- (WCTextViewController *)selectTabBarItemForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument; {
    if (!sourceFileDocument)
        return nil;
    
    WCTextViewController *retval = [self.sourceFileDocumentsToTextViewControllers objectForKey:sourceFileDocument];
    
    if (retval) {
        NSTabViewItem *itemToSelect = nil;
        
        for (NSTabViewItem *item in self.tabBarView.tabView.tabViewItems) {
            if (item.identifier == sourceFileDocument) {
                itemToSelect = item;
                break;
            }
        }
        
        if (itemToSelect) {
            [self.tabBarView selectTabViewItem:itemToSelect];
            return retval;
        }
    }
    
    return [self addTabBarItemForSourceFileDocument:sourceFileDocument];
}
- (void)removeTabBarItemForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument; {
    WCTextViewController *textViewController = [self.sourceFileDocumentsToTextViewControllers objectForKey:sourceFileDocument];
    
    [textViewController cleanup];
    
    [self.sourceFileDocumentsToTextViewControllers removeObjectForKey:sourceFileDocument];
    [self.textViewControllersToSourceFileDocuments removeObjectForKey:textViewController];
}
#pragma mark *** Private Methods ***

@end