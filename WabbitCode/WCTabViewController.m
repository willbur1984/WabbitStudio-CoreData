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
#import "File.h"
#import "WCTabView.h"
#import "NSView+WCExtensions.h"
#import "WCDefines.h"
#import "NSEvent+WCExtensions.h"
#import "ProjectSetting.h"

@interface WCTabViewController () <MMTabBarViewDelegate,WCTextViewControllerDelegate,NSSplitViewDelegate>

@property (readwrite,weak,nonatomic) IBOutlet WCTabView *tabView;

@property (readwrite,strong,nonatomic) MMTabBarView *tabBarView;
@property (strong,nonatomic) NSMapTable *sourceFileDocumentsToTextViewControllers;
@property (strong,nonatomic) NSMapTable *textViewControllersToSourceFileDocuments;
@property (strong,nonatomic) NSMapTable *textViewControllersToAssistantTextViewControllers;
@property (strong,nonatomic) NSMapTable *textViewControllersToAssistantTextViewControllerMutableSets;
@property (strong,nonatomic) NSMapTable *textViewControllersToAssistantSplitViewMutableSets;
@property (readonly,nonatomic) WCTextViewController *currentTextViewController;
@property (readonly,nonatomic) WCTextViewController *currentAssistantTextViewController;
@property (assign,nonatomic) BOOL ignoreChanges;

- (void)_addAssistantEditorForTextViewController:(WCTextViewController *)currentAssistantTextViewController;
- (void)_removeAssistantEditorForTextViewController:(WCTextViewController *)currentAssistantTextViewController;
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
    
    for (NSSet *textViewControllers in self.textViewControllersToAssistantTextViewControllerMutableSets.objectEnumerator) {
        for (WCTextViewController *textViewController in textViewControllers)
            [textViewController cleanup];
    }
    
    for (WCTextViewController *textViewController in self.sourceFileDocumentsToTextViewControllers.objectEnumerator)
        [textViewController cleanup];
}
#pragma mark NSUserInterfaceValidations
- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem {
    if ([anItem action] == @selector(addAssistantEditorAction:)) {
        return ([[self.textViewControllersToAssistantTextViewControllerMutableSets objectForKey:self.currentTextViewController] count] >= 1);
    }
    else if ([anItem action] == @selector(removeAssistantEditorAction:)) {
        return ([[self.textViewControllersToAssistantTextViewControllerMutableSets objectForKey:self.currentTextViewController] count] >= 2);
    }
    return YES;
}
#pragma mark NSSplitViewDelegate
- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    return NO;
}
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    CGFloat amount = (splitView.isVertical) ? NSWidth(splitView.frame) : NSHeight(splitView.frame);
    
    return proposedMinimumPosition + floor(amount * 0.25);
}
- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    CGFloat amount = (splitView.isVertical) ? NSWidth(splitView.frame) : NSHeight(splitView.frame);
    
    return proposedMaximumPosition - floor(amount * 0.25);
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
- (void)addAssistantEditorForTextViewController:(WCTextViewController *)textViewController {
    [self _addAssistantEditorForTextViewController:textViewController];
}
- (void)removeAssistantEditorForTextViewController:(WCTextViewController *)textViewController {
    [self _removeAssistantEditorForTextViewController:textViewController];
}
#pragma mark *** Public Methods ***
- (id)initWithTabBarView:(MMTabBarView *)tabBarView; {
    if (!(self = [super init]))
        return nil;
    
    [self setSourceFileDocumentsToTextViewControllers:[NSMapTable mapTableWithWeakToStrongObjects]];
    [self setTextViewControllersToSourceFileDocuments:[NSMapTable mapTableWithWeakToWeakObjects]];
    [self setTabBarView:tabBarView];
    [self setTextViewControllersToAssistantSplitViewMutableSets:[NSMapTable mapTableWithWeakToStrongObjects]];
    [self setTextViewControllersToAssistantTextViewControllerMutableSets:[NSMapTable mapTableWithWeakToStrongObjects]];
    [self setTextViewControllersToAssistantTextViewControllers:[NSMapTable mapTableWithWeakToStrongObjects]];
    
    return self;
}

- (WCTextViewController *)addTabBarItemForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument; {
    NSParameterAssert(sourceFileDocument);
    
    WCTextViewController *retval = [self.sourceFileDocumentsToTextViewControllers objectForKey:sourceFileDocument];
    
    if (!retval) {
        NSTabViewItem *item = [[NSTabViewItem alloc] initWithIdentifier:sourceFileDocument];
        WCTextViewController *textViewController = [[WCTextViewController alloc] initWithSourceFileDocument:sourceFileDocument];
        
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
    
    for (WCTextViewController *assistantTextViewController in [self.textViewControllersToAssistantTextViewControllerMutableSets objectForKey:textViewController])
        [assistantTextViewController cleanup];
    for (NSSplitView *splitView in [self.textViewControllersToAssistantSplitViewMutableSets objectForKey:textViewController])
        [splitView removeFromSuperviewWithoutNeedingDisplay];
    
    [self.textViewControllersToAssistantSplitViewMutableSets removeObjectForKey:textViewController];
    [self.textViewControllersToAssistantTextViewControllers removeObjectForKey:textViewController];
    [self.textViewControllersToAssistantTextViewControllerMutableSets removeObjectForKey:textViewController];
    [self.sourceFileDocumentsToTextViewControllers removeObjectForKey:sourceFileDocument];
    [self.textViewControllersToSourceFileDocuments removeObjectForKey:textViewController];
}

- (NSArray *)textViewControllersForTabViewItemAtIndex:(NSInteger)index; {
    NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
    NSTabViewItem *tabViewItem = [self.tabBarView.tabView tabViewItemAtIndex:index];
    WCTextViewController *textViewController = [self.sourceFileDocumentsToTextViewControllers objectForKey:tabViewItem.identifier];
    
    [retval addObject:textViewController];
    [retval addObjectsFromArray:[[self.textViewControllersToAssistantTextViewControllerMutableSets objectForKey:textViewController] allObjects]];
    
    return retval;
}
#pragma mark Actions
- (IBAction)showStandardEditorAction:(id)sender; {
    WCTextViewController *currentTextViewController = self.currentTextViewController;
    
    if ([[self.textViewControllersToAssistantTextViewControllerMutableSets objectForKey:currentTextViewController] count] == 0) {
        [currentTextViewController.textView WC_makeFirstResponder];
        return;
    }
    
    for (WCTextViewController *textViewController in [self.textViewControllersToAssistantTextViewControllerMutableSets objectForKey:currentTextViewController])
        [textViewController cleanup];
    for (NSSplitView *splitView in [self.textViewControllersToAssistantSplitViewMutableSets objectForKey:currentTextViewController])
        [splitView removeFromSuperviewWithoutNeedingDisplay];
    
    [self.textViewControllersToAssistantSplitViewMutableSets removeObjectForKey:currentTextViewController];
    [self.textViewControllersToAssistantTextViewControllerMutableSets removeObjectForKey:currentTextViewController];
    [self.textViewControllersToAssistantTextViewControllers removeObjectForKey:currentTextViewController];
    
    [currentTextViewController.view setFrame:[self.tabView.selectedTabViewItem.view bounds]];
    [self.tabView.selectedTabViewItem.view addSubview:currentTextViewController.view];
    
    [currentTextViewController.textView WC_makeFirstResponder];
}

- (IBAction)showAssistantEditorAction:(id)sender; {
    WCTextViewController *currentTextViewController = self.currentTextViewController;
    
    if ([self.textViewControllersToAssistantTextViewControllers objectForKey:currentTextViewController]) {
        WCTextViewController *assistantTextViewController = [self.textViewControllersToAssistantTextViewControllers objectForKey:currentTextViewController];
        
        [assistantTextViewController.textView WC_makeFirstResponder];
        return;
    }
    
    BOOL vertical = NO;
    NSSplitView *splitView = [[NSSplitView alloc] initWithFrame:currentTextViewController.view.bounds];
    
    [splitView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [splitView setVertical:vertical];
    [splitView setDividerStyle:(vertical)?NSSplitViewDividerStyleThin:NSSplitViewDividerStylePaneSplitter];
    [splitView setDelegate:self];
    
    NSMutableOrderedSet *temp = [NSMutableOrderedSet orderedSetWithCapacity:0];
    
    [temp addObject:splitView];
    
    [self.textViewControllersToAssistantSplitViewMutableSets setObject:temp forKey:currentTextViewController];
    
    WCTextViewController *textViewController = [[WCTextViewController alloc] initWithSourceFileDocument:[self.textViewControllersToSourceFileDocuments objectForKey:currentTextViewController]];
    
    [textViewController setDelegate:self];
    
    temp = [NSMutableOrderedSet orderedSetWithCapacity:0];
    
    [temp addObject:textViewController];
    
    [self.textViewControllersToAssistantTextViewControllerMutableSets setObject:temp forKey:currentTextViewController];
    [self.textViewControllersToAssistantTextViewControllers setObject:textViewController forKey:currentTextViewController];
    
    NSView *superview = currentTextViewController.view.superview;
    
    [splitView addSubview:currentTextViewController.view];
    [splitView addSubview:textViewController.view];
    [splitView adjustSubviews];
    
    CGFloat amount = (vertical) ? NSWidth(splitView.frame) : NSHeight(splitView.frame);
    
    [splitView setPosition:floor((amount - splitView.dividerThickness) * 0.5) ofDividerAtIndex:0];
    
    [superview addSubview:splitView];
    
    [textViewController.textView WC_makeFirstResponder];
}
- (IBAction)addAssistantEditorAction:(id)sender; {
    [self _addAssistantEditorForTextViewController:self.currentAssistantTextViewController];
}
- (IBAction)removeAssistantEditorAction:(id)sender; {
    [self _removeAssistantEditorForTextViewController:self.currentAssistantTextViewController];
}
- (IBAction)resetEditorAction:(id)sender; {
    // TODO: i don't really know what this method is supposed to do :(
}
#pragma mark *** Private Methods ***
- (void)_addAssistantEditorForTextViewController:(WCTextViewController *)currentAssistantTextViewController; {
    NSSplitView *currentSplitView = (NSSplitView *)currentAssistantTextViewController.view.superview;
    
    BOOL vertical = [NSEvent WC_isOptionKeyPressed];
    NSSplitView *splitView = [[NSSplitView alloc] initWithFrame:currentAssistantTextViewController.view.bounds];
    
    [splitView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [splitView setVertical:vertical];
    [splitView setDividerStyle:(vertical)?NSSplitViewDividerStyleThin:NSSplitViewDividerStylePaneSplitter];
    [splitView setDelegate:self];
    
    WCTextViewController *currentTextViewController = self.currentTextViewController;
    
    [[self.textViewControllersToAssistantSplitViewMutableSets objectForKey:currentTextViewController] addObject:splitView];
    
    WCTextViewController *textViewController = [[WCTextViewController alloc] initWithSourceFileDocument:[self.textViewControllersToSourceFileDocuments objectForKey:currentTextViewController]];
    
    [textViewController setDelegate:self];
    
    NSMutableOrderedSet *assistantTextViewControllers = [self.textViewControllersToAssistantTextViewControllerMutableSets objectForKey:currentTextViewController];
    
    [assistantTextViewControllers removeObject:currentAssistantTextViewController];
    [assistantTextViewControllers addObject:currentAssistantTextViewController];
    [assistantTextViewControllers addObject:textViewController];
    
    [splitView addSubview:currentAssistantTextViewController.view];
    [splitView addSubview:textViewController.view];
    [splitView adjustSubviews];
    
    CGFloat amount = (vertical) ? NSWidth(splitView.frame) : NSHeight(splitView.frame);
    
    [splitView setPosition:floor((amount - splitView.dividerThickness) * 0.5) ofDividerAtIndex:0];
    
    [currentSplitView addSubview:splitView];
    
    [textViewController.textView WC_makeFirstResponder];
}
- (void)_removeAssistantEditorForTextViewController:(WCTextViewController *)currentAssistantTextViewController; {
    WCTextViewController *currentTextViewController = self.currentTextViewController;
    
    if (currentAssistantTextViewController == [self.textViewControllersToAssistantTextViewControllers objectForKey:currentTextViewController] &&
        [[self.textViewControllersToAssistantTextViewControllerMutableSets objectForKey:currentTextViewController] count] == 1) {
        
        [self showStandardEditorAction:nil];
        return;
    }
    
    WCTextViewController *textViewController = nil;
    NSSplitView *currentSplitView = nil;
    NSSplitView *parentSplitView = nil;
    
    for (NSSplitView *splitView in [self.textViewControllersToAssistantSplitViewMutableSets objectForKey:currentTextViewController]) {
        for (NSView *view in splitView.subviews) {
            if ([view WC_viewController] == currentAssistantTextViewController) {
                currentSplitView = splitView;
                parentSplitView = (NSSplitView *)currentSplitView.superview;
                
                for (NSView *sView in splitView.subviews) {
                    if ([sView WC_viewController] != currentAssistantTextViewController) {
                        textViewController = (WCTextViewController *)[sView WC_viewController];
                        break;
                    }
                }
                
                break;
            }
        }
        
        if (textViewController)
            break;
    }
    
    NSParameterAssert(textViewController);
    
    [currentSplitView removeFromSuperviewWithoutNeedingDisplay];
    [currentAssistantTextViewController cleanup];
    
    [parentSplitView addSubview:textViewController.view];
    
    [textViewController.textView WC_makeFirstResponder];
    
    [[self.textViewControllersToAssistantSplitViewMutableSets objectForKey:currentTextViewController] removeObject:currentSplitView];
    
    NSMutableOrderedSet *assistantTextViewControllers = [self.textViewControllersToAssistantTextViewControllerMutableSets objectForKey:currentTextViewController];
    
    [assistantTextViewControllers removeObject:currentAssistantTextViewController];
    [assistantTextViewControllers removeObject:textViewController];
    [assistantTextViewControllers addObject:textViewController];
    
    if (currentAssistantTextViewController == [self.textViewControllersToAssistantTextViewControllers objectForKey:currentTextViewController])
        [self.textViewControllersToAssistantTextViewControllers setObject:textViewController forKey:currentTextViewController];
}
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
- (WCTextViewController *)currentTextViewController {
    NSView *view = self.tabView.selectedTabViewItem.view;
    
    for (WCTextViewController *textViewController in self.textViewControllersToSourceFileDocuments.keyEnumerator) {
        if ([textViewController.view isDescendantOf:view])
            return textViewController;
    }
    
    return nil;
}
- (WCTextViewController *)currentAssistantTextViewController {
    WCTextViewController *currentTextViewController = self.currentTextViewController;
    NSView *firstResponder = (NSView *)self.tabBarView.window.firstResponder;
    
    for (WCTextViewController *textViewController in [self.textViewControllersToAssistantTextViewControllerMutableSets objectForKey:currentTextViewController]) {
        if ([firstResponder isDescendantOf:textViewController.view])
            return textViewController;
    }
    
    return [self.textViewControllersToAssistantTextViewControllers objectForKey:currentTextViewController];
}
@end
