//
//  WCTabViewController.h
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

#import "WCViewController.h"

@class WCSourceFileDocument,WCTextViewController,MMTabBarView,WCProjectDocument,WCTabView;
@protocol WCTabViewControllerDelegate;

@interface WCTabViewController : WCViewController <NSUserInterfaceValidations>

@property (readonly,weak,nonatomic) IBOutlet WCTabView *tabView;

@property (unsafe_unretained,nonatomic) id <WCTabViewControllerDelegate> delegate;

@property (readonly,strong,nonatomic) MMTabBarView *tabBarView;

- (id)initWithTabBarView:(MMTabBarView *)tabBarView;

- (WCTextViewController *)addTabBarItemForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument;
- (WCTextViewController *)selectTabBarItemForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument;
- (void)removeTabBarItemForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument;

- (IBAction)showStandardEditorAction:(id)sender;

- (IBAction)showAssistantEditorAction:(id)sender;
- (IBAction)addAssistantEditorAction:(id)sender;
- (IBAction)removeAssistantEditorAction:(id)sender;
- (IBAction)resetEditorAction:(id)sender;

@end

@protocol WCTabViewControllerDelegate <NSObject>
@required
- (WCProjectDocument *)projectDocumentForTabViewController:(WCTabViewController *)tabViewController;
@end