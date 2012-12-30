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
#import "WCStandardTextViewController.h"
#import "WCSourceFileDocument.h"
#import "WCDocumentController.h"
#import "WCProjectDocument.h"
#import "WCTextView.h"
#import "File.h"
#import "WCTabView.h"
#import "NSView+WCExtensions.h"
#import "WCDefines.h"
#import "NSEvent+WCExtensions.h"
#import "ProjectSetting.h"
#import "NSView+WCExtensions.h"

@interface WCTabViewController () <MMTabBarViewDelegate,WCTextViewControllerDelegate,NSSplitViewDelegate>

@property (readwrite,weak,nonatomic) IBOutlet WCTabView *tabView;

@property (readwrite,strong,nonatomic) MMTabBarView *tabBarView;
@property (strong,nonatomic) NSMapTable *sourceFileDocumentsToTextViewControllers;
@property (strong,nonatomic) NSMapTable *textViewControllersToSourceFileDocuments;
@property (assign,nonatomic) BOOL ignoreChanges;

- (void)_updateOpenTabFiles;
@end

@implementation WCTabViewController
- (NSString *)nibName {
    return @"WCTabView";
}

- (void)loadView {
    [super loadView];
    
    [self.tabView setEmptyString:NSLocalizedString(@"No Open Files", nil)];
    
    [self.tabBarView setTabView:self.tabView];
    [self.tabView setDelegate:(id<NSTabViewDelegate>)self.tabBarView];
    [self.tabBarView setDelegate:self];
    [self.tabBarView setStyleNamed:@"Safari"];
    [self.tabBarView setOnlyShowCloseOnHover:YES];
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
    
    [self setIgnoreChanges:YES];
    
    WCProjectDocument *projectDocument = [self.delegate projectDocumentForTabViewController:self];
    
    for (File *file in projectDocument.projectSetting.projectOpenTabFiles) {
        WCSourceFileDocument *document = [projectDocument sourceFileDocumentForFile:file];
        
        [self addTabBarItemForSourceFileDocument:document];
    }
    
    if (projectDocument.projectSetting.projectSelectedTabFile) {
        WCSourceFileDocument *document = [projectDocument sourceFileDocumentForFile:projectDocument.projectSetting.projectSelectedTabFile];
        
        [self selectTabBarItemForSourceFileDocument:document];
    }
    
    [self setIgnoreChanges:NO];
}

- (void)cleanup {
    [super cleanup];
    
    for (WCTextViewController *textViewController in self.sourceFileDocumentsToTextViewControllers.objectEnumerator)
        [textViewController cleanup];
}

#pragma mark MMTabBarViewDelegate
- (void)tabViewDidChangeNumberOfTabViewItems:(NSTabView *)tabView {
    if (self.ignoreChanges)
        return;
    
    [self _updateOpenTabFiles];
}
- (void)tabView:(NSTabView *)aTabView didCloseTabViewItem:(NSTabViewItem *)tabViewItem {
    [self removeTabBarItemForSourceFileDocument:tabViewItem.identifier];
}
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    if (self.ignoreChanges)
        return;
    
    WCProjectDocument *projectDocument = [self.delegate projectDocumentForTabViewController:self];
    File *file = [projectDocument fileForSourceFileDocument:tabViewItem.identifier];
    
    [projectDocument.projectSetting setProjectSelectedTabFile:file];
    [projectDocument updateChangeCount:NSChangeDone|NSChangeDiscardable];
}
- (NSDragOperation)tabView:(NSTabView *)aTabView validateSlideOfProposedItem:(NSTabViewItem *)tabViewItem proposedIndex:(NSUInteger)proposedIndex inTabBarView:(MMTabBarView *)tabBarView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_updateOpenTabFiles) object:nil];
    [self performSelector:@selector(_updateOpenTabFiles) withObject:nil afterDelay:0];
    
    return NSDragOperationMove;
}
- (NSString *)tabView:(NSTabView *)aTabView toolTipForTabViewItem:(NSTabViewItem *)tabViewItem {
    WCSourceFileDocument *sourceFileDocument = tabViewItem.identifier;
    File *file = [sourceFileDocument.projectDocument fileForSourceFileDocument:sourceFileDocument];
    
    return file.path;
}
#pragma mark WCTextViewControllerDelegate

#pragma mark *** Public Methods ***
- (id)initWithTabBarView:(MMTabBarView *)tabBarView; {
    if (!(self = [super init]))
        return nil;
    
    [self setSourceFileDocumentsToTextViewControllers:[NSMapTable mapTableWithWeakToStrongObjects]];
    [self setTextViewControllersToSourceFileDocuments:[NSMapTable mapTableWithWeakToWeakObjects]];
    [self setTabBarView:tabBarView];
    
    return self;
}

- (WCTextViewController *)addTabBarItemForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument; {
    NSParameterAssert(sourceFileDocument);
    
    WCStandardTextViewController *retval = [self.sourceFileDocumentsToTextViewControllers objectForKey:sourceFileDocument];
    
    if (!retval) {
        NSTabViewItem *item = [[NSTabViewItem alloc] initWithIdentifier:sourceFileDocument];
        WCStandardTextViewController *textViewController = [[WCStandardTextViewController alloc] initWithSourceFileDocument:sourceFileDocument];
        
        [textViewController setShowAddRemoveAssistantEditorButtons:NO];
        [textViewController setDelegate:self];
        
        NSView *containerView = [[NSView alloc] initWithFrame:self.tabView.frame];
        
        [containerView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        [textViewController.view setFrameSize:containerView.frame.size];
        [containerView addSubview:textViewController.view];
        
        [item setView:containerView];
        [item setInitialFirstResponder:textViewController.textView];
        
        [self.sourceFileDocumentsToTextViewControllers setObject:textViewController forKey:sourceFileDocument];
        [self.textViewControllersToSourceFileDocuments setObject:sourceFileDocument forKey:textViewController];
        
        [self.tabBarView addAttachedButtonForTabViewItem:item];
        
        retval = textViewController;
    }
    
    return retval;
}
- (WCTextViewController *)selectTabBarItemForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument; {
    NSParameterAssert(sourceFileDocument);
    
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
    NSParameterAssert(sourceFileDocument);
    
    WCTextViewController *textViewController = [self.sourceFileDocumentsToTextViewControllers objectForKey:sourceFileDocument];
    
    [textViewController cleanup];
    
    [self.sourceFileDocumentsToTextViewControllers removeObjectForKey:sourceFileDocument];
    [self.textViewControllersToSourceFileDocuments removeObjectForKey:textViewController];
}

- (WCStandardTextViewController *)standardTextViewControllerForTabViewItemAtIndex:(NSInteger)index; {
    NSTabViewItem *tabViewItem = [self.tabBarView.tabView tabViewItemAtIndex:index];
    WCStandardTextViewController *textViewController = [self.sourceFileDocumentsToTextViewControllers objectForKey:tabViewItem.identifier];
    
    return textViewController;
}
#pragma mark Actions

#pragma mark Properties
- (WCSourceFileDocument *)currentSourceFileDocument {
    return [self.textViewControllersToSourceFileDocuments objectForKey:self.currentStandardTextViewController];
}
#pragma mark *** Private Methods ***
- (void)_updateOpenTabFiles {
    WCProjectDocument *projectDocument = [self.delegate projectDocumentForTabViewController:self];
    NSMutableArray *files = [NSMutableArray arrayWithCapacity:self.tabView.numberOfTabViewItems];
    
    for (NSTabViewItem *item in self.tabView.tabViewItems) {
        File *file = [projectDocument fileForSourceFileDocument:item.identifier];
        
        [files addObject:file];
    }
    
    [projectDocument.projectSetting setProjectOpenTabFiles:[NSOrderedSet orderedSetWithArray:files]];
    [projectDocument updateChangeCount:NSChangeDone|NSChangeDiscardable];
}
#pragma mark Properties
- (WCStandardTextViewController *)currentStandardTextViewController {
    NSView *view = self.tabView.selectedTabViewItem.view;
    
    for (WCStandardTextViewController *textViewController in self.textViewControllersToSourceFileDocuments.keyEnumerator) {
        if ([textViewController.view isDescendantOf:view])
            return textViewController;
    }
    
    return nil;
}
@end
