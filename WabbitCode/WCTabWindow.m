//
//  WCTabWindow.m
//  WabbitStudio
//
//  Created by William Towe on 12/7/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCTabWindow.h"
#import "WCTabViewController.h"
#import "WCTabView.h"
#import "MMTabBarView.h"
#import "MMAttachedTabBarButton.h"

@implementation WCTabWindow

- (void)performClose:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tabViewControllerForTabWindow:)]) {
        WCTabViewController *tabViewController = [self.delegate tabViewControllerForTabWindow:self];
        
        if (tabViewController) {
            NSTabViewItem *selectedItem = tabViewController.tabView.selectedTabViewItem;
            
            if (selectedItem) {
                if (tabViewController.tabView.numberOfTabViewItems > 1) {
                    MMAttachedTabBarButton *button = [tabViewController.tabBarView attachedButtonForTabViewItem:selectedItem];
                    
                    [tabViewController.tabBarView removeAttachedButton:button synchronizeTabViewItems:YES];
                    [tabViewController removeTabBarItemForSourceFileDocument:selectedItem.identifier];
                }
                else if (tabViewController.tabView.numberOfTabViewItems == 1 && tabViewController.tabBarView.canCloseOnlyTab) {
                    MMAttachedTabBarButton *button = [tabViewController.tabBarView attachedButtonForTabViewItem:selectedItem];
                    
                    [tabViewController.tabBarView removeAttachedButton:button synchronizeTabViewItems:YES];
                    [tabViewController removeTabBarItemForSourceFileDocument:selectedItem.identifier];
                }
                else
                    [super performClose:nil];
            }
            else
                [super performClose:nil];
        }
        else
            [super performClose:nil];
    }
    else
        [super performClose:nil];
}

@dynamic delegate;
- (id<WCTabWindowDelegate>)delegate {
    return (id<WCTabWindowDelegate>)[super delegate];
}
- (void)setDelegate:(id<WCTabWindowDelegate>)delegate {
    [super setDelegate:delegate];
}

@end
