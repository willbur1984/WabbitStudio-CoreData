//
//  NSOutlineView+WCExtensions.m
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

#import "NSOutlineView+WCExtensions.h"
#import "NSArray+WCExtensions.h"
#import "WCDefines.h"

@implementation NSOutlineView (WCExtensions)

- (id)WC_clickedItem; {
    return [[self WC_clickedItems] WC_firstObject];
}
- (NSArray *)WC_clickedItems; {
    if (self.clickedRow == -1)
        return nil;
    
    if ([self.selectedRowIndexes containsIndex:self.clickedRow])
        return [self WC_selectedItems];
    
    return @[[self itemAtRow:self.clickedRow]];
}

- (id)WC_selectedItem; {
    return [[self WC_selectedItems] WC_firstObject];
}
- (NSArray *)WC_selectedItems; {
    NSIndexSet *indexes = self.selectedRowIndexes;
    NSMutableArray *retval = [NSMutableArray arrayWithCapacity:indexes.count];
    
    [indexes enumerateIndexesWithOptions:0 usingBlock:^(NSUInteger idx, BOOL *stop) {
        id item = [self itemAtRow:idx];
        
        if (item)
            [retval addObject:item];
    }];
    
    return retval;
}

- (void)WC_setSelectedItem:(id)item; {
    [self WC_setSelectedItems:@[item]];
}
- (void)WC_setSelectedItems:(NSArray *)items; {
    NSMutableIndexSet *rows = [NSMutableIndexSet indexSet];
    
    for (id item in items) {
        NSInteger row = [self rowForItem:item];
        
        if (row == -1)
            continue;
        
        [rows addIndex:row];
    }
    
    [self selectRowIndexes:rows byExtendingSelection:NO];
}

- (id)WC_clickedOrSelectedItem; {
    return [[self WC_clickedOrSelectedItems] WC_firstObject];
}
- (NSArray *)WC_clickedOrSelectedItems; {
    NSArray *retval = [self WC_clickedItems];
    
    if (retval.count == 0)
        retval = [self WC_selectedItems];
    
    return retval;
}

- (NSArray *)WC_expandedItems; {
    NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
    
    for (NSInteger row=0; row<self.numberOfRows; row++) {
        id item = [self itemAtRow:row];
        
        if ([self isItemExpanded:item])
            [retval addObject:item];
    }
    
    return retval;
}
- (void)WC_expandItems:(NSArray *)items; {
    for (id item in items)
        [self expandItem:item];
}

@end
