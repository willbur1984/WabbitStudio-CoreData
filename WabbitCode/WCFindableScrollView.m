//
//  WCFindableScrollView.m
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

#import "WCFindableScrollView.h"
#import "WCFindBarBackgroundView.h"
#import "WCDefines.h"

@implementation WCFindableScrollView

- (void)tile {
    [super tile];
    
    WCFindBarBackgroundView *findBar = nil;
    
    for (id subview in self.subviews) {
        if ([subview isKindOfClass:[WCFindBarBackgroundView class]]) {
            findBar = subview;
            
            break;
        }
    }
    
    if (findBar) {
        [findBar setFrame:NSMakeRect(NSMinX(self.bounds), NSMinY(self.bounds), NSWidth(self.bounds), NSHeight(findBar.frame))];
        
        [self.verticalRulerView setFrame:NSMakeRect(NSMinX(self.verticalRulerView.frame), NSMaxY(findBar.frame), NSWidth(self.verticalRulerView.frame), NSHeight(self.verticalRulerView.frame) - NSHeight(findBar.frame))];
        [self.verticalScroller setFrame:NSMakeRect(NSMinX(self.verticalScroller.frame), NSMaxY(findBar.frame), NSWidth(self.verticalScroller.frame), NSHeight(self.verticalScroller.frame) - NSHeight(findBar.frame))];
        [self.contentView setFrame:NSMakeRect(NSMinX(self.contentView.frame), NSMaxY(findBar.frame), NSWidth(self.contentView.frame), NSHeight(self.contentView.frame) - NSHeight(findBar.frame))];
    }
}

@end
