//
//  WCJumpBarControl.m
//  WabbitStudio
//
//  Created by William Towe on 9/22/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCJumpBarControl.h"
#import "WCJumpBarCell.h"
#import "WCJumpBarComponentCell.h"
#import "WCDefines.h"

@interface WCJumpBarControl () <NSMenuDelegate>

@property (strong,nonatomic) NSMenu *contextualMenu;
@property (strong,nonatomic) WCJumpBarComponentCell *clickedJumpBarComponentCell;
@property (strong,nonatomic) NSMutableDictionary *toolTipTagsToStrings;

@end

@implementation WCJumpBarControl

+ (Class)cellClass {
    return [WCJumpBarCell class];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;
    
    [self setRefusesFirstResponder:YES];
    [self setTarget:self];
    [self setAction:@selector(_jumpBarControlAction:)];
    [self setContextualMenu:[[NSMenu alloc] initWithTitle:@""]];
    [self.contextualMenu setFont:[NSFont menuFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]]];
    [self.contextualMenu setDelegate:self];
    [self setToolTipTagsToStrings:[NSMutableDictionary dictionaryWithCapacity:0]];
    
    return self;
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    
    if (self.toolTipTagsToStrings.count) {
        for (NSNumber *tag in self.toolTipTagsToStrings.allKeys)
            [self removeToolTip:tag.integerValue];
        
        [self.toolTipTagsToStrings removeAllObjects];
    }
    
    if ([self.delegate respondsToSelector:@selector(jumpBarControl:toolTipForPathComponentCell:atIndex:)]) {
        [self.pathComponentCells enumerateObjectsUsingBlock:^(WCJumpBarComponentCell *cell, NSUInteger cellIndex, BOOL *stop) {
            NSString *toolTip = [self.delegate jumpBarControl:self toolTipForPathComponentCell:cell atIndex:cellIndex];
            
            if (toolTip) {
                NSRect cellRect = [self.cell rectOfPathComponentCell:cell withFrame:self.bounds inView:self];
                NSToolTipTag tag = [self addToolTipRect:cellRect owner:self userData:NULL];
                
                [self.toolTipTagsToStrings setObject:toolTip forKey:@(tag)];
            }
        }];
    }
}
#pragma mark NSToolTipOwner
- (NSString *)view:(NSView *)view stringForToolTip:(NSToolTipTag)tag point:(NSPoint)point userData:(void *)data {
    return [self.toolTipTagsToStrings objectForKey:@(tag)];
}
#pragma mark NSMenuDelegate
- (NSInteger)numberOfItemsInMenu:(NSMenu *)menu {
    return [self.delegate jumpBarControl:self numberOfItemsInMenuForPathComponentCell:self.clickedJumpBarComponentCell];
}
- (BOOL)menu:(NSMenu *)menu updateItem:(NSMenuItem *)item atIndex:(NSInteger)index shouldCancel:(BOOL)shouldCancel {
    [self.delegate jumpBarControl:self updateItem:item atIndex:index forPathComponentCell:self.clickedJumpBarComponentCell];
    
    [item setTag:index];
    
    return YES;
}

- (BOOL)menuHasKeyEquivalent:(NSMenu *)menu forEvent:(NSEvent *)event target:(__autoreleasing id *)target action:(SEL *)action {
    *target = nil;
    *action = NULL;
    return NO;
}
#pragma mark *** Public Methods ***
- (void)reloadPathComponentCells; {
    NSMutableArray *cells = [NSMutableArray arrayWithArray:[self.dataSource jumpBarComponentCellsForJumpBarControl:self]];
    WCJumpBarComponentCell *symbolCell = [self.dataSource symbolPathComponentCellForJumpBarControl:self];
    
    if (symbolCell)
        [cells addObject:symbolCell];
    
    [self setPathComponentCells:cells];
}
- (void)reloadSymbolPathComponentCell; {
    NSMutableArray *temp = [self.pathComponentCells mutableCopy];
    
    [temp replaceObjectAtIndex:temp.count - 1 withObject:[self.dataSource symbolPathComponentCellForJumpBarControl:self]];
    
    [self setPathComponentCells:temp];
}
- (void)reloadImageForPathComponentCell:(WCJumpBarComponentCell *)pathComponentCell {
    if ([self.dataSource respondsToSelector:@selector(jumpBarControl:imageForPathComponentCell:)]) {
        NSImage *image = [self.dataSource jumpBarControl:self imageForPathComponentCell:pathComponentCell];
        WCJumpBarComponentCell *cell = [[WCJumpBarComponentCell alloc] initTextCell:pathComponentCell.stringValue];
        
        [cell setImage:image];
        [cell setTag:pathComponentCell.tag];
        [cell setRepresentedObject:pathComponentCell.representedObject];
        
        NSMutableArray *temp = [self.pathComponentCells mutableCopy];
        
        [temp replaceObjectAtIndex:[temp indexOfObject:pathComponentCell] withObject:cell];
        
        [self setPathComponentCells:temp];
        
        return;
    }
    
    [self reloadPathComponentCells];
}

- (void)showPopUpMenuForPathComponentCell:(WCJumpBarComponentCell *)pathComponentCell; {
    if (!pathComponentCell)
        return;
    
    if ([self.delegate jumpBarControl:self shouldPopUpMenuForPathComponentCell:pathComponentCell]) {
        NSInteger numberOfItems = [self.delegate jumpBarControl:self numberOfItemsInMenuForPathComponentCell:pathComponentCell];
        
        if (numberOfItems <= 0)
            return;
        
        [self setClickedJumpBarComponentCell:pathComponentCell];
        
        if (self.contextualMenu.numberOfItems < numberOfItems) {
            while (self.contextualMenu.numberOfItems < numberOfItems) {
                NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"" action:@selector(_contextualMenuItemAction:) keyEquivalent:@""];
                
                [item setTarget:self];
                
                [self.contextualMenu addItem:item];
            }
        }
        else if (self.contextualMenu.numberOfItems > numberOfItems) {
            while (self.contextualMenu.numberOfItems > numberOfItems)
                [self.contextualMenu removeItemAtIndex:0];
        }
        
        NSInteger highlightedItemIndex = 0;
        
        if ([self.delegate respondsToSelector:@selector(jumpBarControl:highlightedItemIndexForPathComponentCell:)])
            highlightedItemIndex = [self.delegate jumpBarControl:self highlightedItemIndexForPathComponentCell:self.clickedJumpBarComponentCell];
        
        NSRect menuRect = [self.cell rectOfPathComponentCell:pathComponentCell withFrame:self.bounds inView:self];
        
        if (![self.contextualMenu popUpMenuPositioningItem:[self.contextualMenu itemAtIndex:highlightedItemIndex] atLocation:menuRect.origin inView:self]) {
            if ([self.delegate respondsToSelector:@selector(jumpBarControl:menuDidCloseForPathComponentCell:)])
                [self.delegate jumpBarControl:self menuDidCloseForPathComponentCell:self.clickedJumpBarComponentCell];
            
            [self setClickedJumpBarComponentCell:nil];
        }
    }
}
#pragma mark Properties
- (void)setDataSource:(id<WCJumpBarControlDataSource>)dataSource {
    _dataSource = dataSource;
    
    [self reloadPathComponentCells];
}

- (id<WCJumpBarControlDelegate>)delegate {
    return (id<WCJumpBarControlDelegate>)[super delegate];
}
- (void)setDelegate:(id<WCJumpBarControlDelegate>)delegate {
    [super setDelegate:delegate];
}
#pragma mark *** Private Methods ***

#pragma mark Actions
- (IBAction)_jumpBarControlAction:(WCJumpBarControl *)sender {
    WCJumpBarComponentCell *cell = (WCJumpBarComponentCell *)sender.clickedPathComponentCell;
    
    [self showPopUpMenuForPathComponentCell:cell];
}
- (IBAction)_contextualMenuItemAction:(NSMenuItem *)sender {
    if ([self.delegate respondsToSelector:@selector(jumpBarControl:didSelectItem:atIndex:forPathComponentCell:)])
        [self.delegate jumpBarControl:self didSelectItem:sender atIndex:sender.tag forPathComponentCell:self.clickedJumpBarComponentCell];
    
    if ([self.delegate respondsToSelector:@selector(jumpBarControl:menuDidCloseForPathComponentCell:)])
        [self.delegate jumpBarControl:self menuDidCloseForPathComponentCell:self.clickedJumpBarComponentCell];
    
    [self setClickedJumpBarComponentCell:nil];
}

@end
