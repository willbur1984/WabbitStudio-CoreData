//
//  WCFindBarFieldEditor.m
//  WabbitStudio
//
//  Created by William Towe on 11/11/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCFindBarFieldEditor.h"
#import "WCFindBarViewController.h"

@implementation WCFindBarFieldEditor

- (id)initWithFrame:(NSRect)frameRect {
    if (!(self = [super initWithFrame:frameRect]))
        return nil;
    
    [self setFieldEditor:YES];
    
    return self;
}

- (void)performTextFinderAction:(id)sender {
    [self.findBarViewController performTextFinderAction:sender];
}
- (void)performFindPanelAction:(id)sender {
    [self.findBarViewController performTextFinderAction:sender];
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem {
    if ([anItem action] == @selector(performTextFinderAction:) ||
        [anItem action] == @selector(performFindPanelAction:)) {
        
        return [self.findBarViewController validateUserInterfaceItem:anItem];
    }
    return [super validateUserInterfaceItem:anItem];
}

+ (WCFindBarFieldEditor *)sharedFieldEditor; {
    static id retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[[self class] alloc] initWithFrame:NSMakeRect(0, 0, CGFLOAT_MAX, CGFLOAT_MAX)];
    });
    return retval;
}

@end
