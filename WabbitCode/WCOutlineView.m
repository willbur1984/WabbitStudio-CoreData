//
//  WCOutlineView.m
//  WabbitStudio
//
//  Created by William Towe on 11/2/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCOutlineView.h"
#import "NSOutlineView+WCExtensions.h"
#import "NSEvent+WCExtensions.h"

@implementation WCOutlineView

- (void)mouseDown:(NSEvent *)theEvent {
    if (theEvent.type == NSLeftMouseDown && theEvent.clickCount == 2) {
        id item = [self WC_selectedItem];
        
        if ([self.dataSource outlineView:self numberOfChildrenOfItem:item] > 0) {
            if ([self isItemExpanded:item] && [theEvent WC_isOnlyOptionKeyPressed])
                [self collapseItem:item collapseChildren:YES];
            else if ([self isItemExpanded:item])
                [self collapseItem:item collapseChildren:NO];
            else if ([theEvent WC_isOnlyOptionKeyPressed])
                [self expandItem:item expandChildren:YES];
            else
                [self expandItem:item expandChildren:NO];
            
            return;
        }
    }
    
    [super mouseDown:theEvent];
}

@end
