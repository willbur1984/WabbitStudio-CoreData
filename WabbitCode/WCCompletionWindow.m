//
//  WCCompletionWindow.m
//  WabbitStudio
//
//  Created by William Towe on 9/24/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCCompletionWindow.h"
#import "WCTextView.h"
#import "WCSymbolScanner.h"
#import "WCSymbolImageManager.h"
#import "WCDefines.h"
#import "WCGeometry.h"
#import "WCSyntaxHighlighter.h"
#import "Macro.h"
#import "WCArgumentPlaceholderCell.h"
#import "NSColor+WCExtensions.h"
#import "File.h"
#import "WCTableView.h"
#import "WCCompletionItem.h"
#import "Completion.h"
#import "Placeholder.h"
#import "NSAttributedString+WCExtensions.h"

@interface WCCompletionWindow () <NSTableViewDataSource,NSTableViewDelegate>

@property (strong,nonatomic) WCTableView *tableView;
@property (strong,nonatomic) NSScrollView *scrollView;
@property (assign,nonatomic) WCTextView *textView;
@property (strong,nonatomic) NSArray *completionItems;
@property (weak,nonatomic) id eventMonitor;
@property (strong,nonatomic) NSLayoutManager *layoutManager;
@property (strong,nonatomic) NSTextStorage *textStorage;
@property (strong,nonatomic) NSTextContainer *textContainer;
@property (strong,nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong,nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)_insertCompletionItem:(WCCompletionItem *)completionItem;
- (NSArray *)_completionsWithPrefix:(NSString *)prefix;
- (NSAttributedString *)_attributedStringForCompletion:(Completion *)completion;
@end

@implementation WCCompletionWindow
#pragma mark *** Subclass Overrides ***
- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    if (!(self = [super initWithContentRect:NSZeroRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO]))
        return nil;
    
    [self setReleasedWhenClosed:NO];
    [self setOpaque:NO];
    [self setBackgroundColor:[NSColor clearColor]];
    [self setHasShadow:YES];
    [self setLevel:NSStatusWindowLevel];
    [self setAlphaValue:0];
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Completions" withExtension:@"momd"];
    
    [self setManagedObjectModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL]];
    [self setPersistentStoreCoordinator:[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel]];
    [self.persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL];
    [self setManagedObjectContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType]];
    [self.managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    [self.managedObjectContext setUndoManager:nil];
    
    NSData *data = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Completions" withExtension:@"json"] options:NSDataReadingUncached error:NULL];
    NSDictionary *completions = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    NSEntityDescription *completionDesc = [NSEntityDescription entityForName:@"Completion" inManagedObjectContext:self.managedObjectContext];
    
    for (NSDictionary *dict in [completions objectForKey:@"completions"]) {
        Completion *completion = [NSEntityDescription insertNewObjectForEntityForName:@"Completion" inManagedObjectContext:self.managedObjectContext];
        
        [completionDesc.attributesByName enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSAttributeDescription *desc, BOOL *stop) {
            [completion setValue:[dict objectForKey:name] forKey:name];
        }];
        
        [completionDesc.relationshipsByName enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSRelationshipDescription *desc, BOOL *stop) {
            if (desc.isToMany && desc.isOrdered) {
                NSMutableOrderedSet *temp = [completion mutableOrderedSetValueForKey:name];
                
                for (NSDictionary *placeholderDict in [dict objectForKey:name]) {
                    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:desc.destinationEntity.name];
                    
                    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.name ==[cd] %@",[placeholderDict objectForKey:@"name"]]];
                    
                    id entity = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL].lastObject;
                    
                    if (!entity) {
                        entity = [NSEntityDescription insertNewObjectForEntityForName:desc.destinationEntity.name inManagedObjectContext:self.managedObjectContext];
                        
                        [desc.destinationEntity.attributesByName enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSAttributeDescription *desc, BOOL *stop) {
                            [entity setValue:[placeholderDict objectForKey:name] forKey:name];
                        }];
                    }
                    
                    [temp addObject:entity];
                }
            }
        }];
    }
    
    [self.managedObjectContext save:NULL];
    
    NSDictionary *defaultAttributes = [WCSyntaxHighlighter defaultAttributes];
    
    [self setTextStorage:[[NSTextStorage alloc] initWithString:@"" attributes:defaultAttributes]];
    [self setLayoutManager:[[NSLayoutManager alloc] init]];
    [self setTextContainer:[[NSTextContainer alloc] initWithContainerSize:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)]];
    [self.layoutManager addTextContainer:self.textContainer];
    [self.textStorage addLayoutManager:self.layoutManager];
    
    [self setScrollView:[[NSScrollView alloc] initWithFrame:NSZeroRect]];
    [self.scrollView setBorderType:NSNoBorder];
    [self.scrollView setBackgroundColor:[NSColor whiteColor]];
    [self.scrollView setHasHorizontalScroller:NO];
    [self.scrollView setHasVerticalScroller:YES];
    [self.scrollView setAutohidesScrollers:YES];
    [self.scrollView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [self setContentView:self.scrollView];

    [self setTableView:[[WCTableView alloc] initWithFrame:NSZeroRect]];
    [self.tableView setHeaderView:nil];
    [self.tableView setAllowsEmptySelection:NO];
    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(_tableViewDoubleClick:)];
    [self.tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
    [self.tableView setBackgroundColor:[NSColor clearColor]];
    [self.tableView setEmptyString:NSLocalizedString(@"No Completions", nil)];
    
    NSTableColumn *imageColumn = [[NSTableColumn alloc] initWithIdentifier:@"image"];
    
    [imageColumn setDataCell:[[NSImageCell alloc] init]];
    [imageColumn setWidth:WC_NSSmallSize.width];
    [imageColumn setEditable:NO];
    
    [self.tableView addTableColumn:imageColumn];
    
    NSTableColumn *nameColumn = [[NSTableColumn alloc] initWithIdentifier:@"name"];
    
    [nameColumn setEditable:NO];
    
    [self.tableView addTableColumn:nameColumn];
    
    NSFont *defaultFont = [defaultAttributes objectForKey:NSFontAttributeName];
    
    [self.tableView setFont:defaultFont];
    [self.tableView setRowHeight:[self.layoutManager defaultLineHeightForFont:defaultFont]];
    
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [self.scrollView setDocumentView:self.tableView];
    [self setFrame:[self frameRectForContentRect:self.scrollView.frame] display:NO];
    
    return self;
}

- (BOOL)isKeyWindow {
    return YES;
}
#pragma mark NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.completionItems.count;
}
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    WCCompletionItem *completionItem = [self.completionItems objectAtIndex:row];
    
    if ([tableColumn.identifier isEqualToString:@"image"])
        return [completionItem.dataSource image];
    
    NSMutableAttributedString *string = [completionItem.displayString mutableCopy];
    
    if (tableView.selectedRow == row)
        [string addAttribute:NSForegroundColorAttributeName value:[NSColor alternateSelectedControlTextColor] range:NSMakeRange(0, string.length)];
    
    return string;
}
#pragma mark *** Public Methods ***
+ (WCCompletionWindow *)sharedInstance; {
    static id retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[[self class] alloc] init];
    });
    return retval;
}

- (void)showCompletionWindowForTextView:(WCTextView *)textView; {
    if (self.isVisible)
        return;
    
    [self setTextView:textView];
    
    NSRange completionRange = self.textView.rangeForUserCompletion;
    NSString *prefix = (completionRange.location == NSNotFound) ? nil : [self.textView.string substringWithRange:completionRange];
    NSArray *completions = [self _completionsWithPrefix:prefix];
    NSArray *symbols = [[self.textView.delegate symbolScannerForTextView:self.textView] symbolsWithPrefix:prefix];
    NSMutableArray *completionItems = [NSMutableArray arrayWithCapacity:symbols.count];
    
    for (Completion *completion in completions)
        [completionItems addObject:[[WCCompletionItem alloc] initWithDataSource:completion]];
    for (Symbol *symbol in symbols)
        [completionItems addObject:[[WCCompletionItem alloc] initWithDataSource:symbol]];
    
    [self setCompletionItems:completionItems];
    
    if (self.completionItems.count == 0) {
        [self setTextView:nil];
        return;
    }
    
    const NSUInteger maximumNumberOfRows = 8;
    NSUInteger numberOfRows = self.completionItems.count;
    
    if (numberOfRows > maximumNumberOfRows)
        numberOfRows = maximumNumberOfRows;
    
    const CGFloat minimumHeight = 40;
    CGFloat minimumWidth = 75;
    
    for (WCCompletionItem *completionItem in self.completionItems) {
        [self.textStorage replaceCharactersInRange:NSMakeRange(0, self.textStorage.length) withAttributedString:completionItem.displayString];
        [self.layoutManager ensureLayoutForCharacterRange:NSMakeRange(0, self.textStorage.length)];
        
        NSRect usedRect = [self.layoutManager usedRectForTextContainer:self.textContainer];
        
        if (NSWidth(usedRect) > minimumWidth)
            minimumWidth = NSWidth(usedRect);
    }
    
    const CGFloat imageColumnWidth = [self.tableView tableColumnWithIdentifier:@"image"].width;
    
    [[self.tableView tableColumnWithIdentifier:@"name"] setWidth:minimumWidth];
    
    [self.scrollView setFrame:NSIntegralRectWithOptions(NSMakeRect(0, 0, minimumWidth + self.tableView.intercellSpacing.width + imageColumnWidth + NSWidth(self.scrollView.verticalScroller.frame), (numberOfRows > 0) ? (self.tableView.rowHeight + self.tableView.intercellSpacing.height) * numberOfRows : minimumHeight), NSAlignAllEdgesInward)];
    
    NSUInteger glyphIndex = [self.textView.layoutManager glyphIndexForCharacterAtIndex:(completionRange.location == NSNotFound) ? self.textView.selectedRange.location : completionRange.location];
    NSRect lineFragmentRect = [self.textView.layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL];
    NSPoint glyphLocation = [self.textView.layoutManager locationForGlyphAtIndex:glyphIndex];
    
    lineFragmentRect.origin.x += glyphLocation.x;
    lineFragmentRect.origin.y += NSHeight(lineFragmentRect);

    NSPoint point = [self.textView.window convertBaseToScreen:[self.textView convertPoint:lineFragmentRect.origin toView:nil]];
    NSRect screenFrame = [NSScreen mainScreen].visibleFrame;
    NSRect windowFrame = [self frameRectForContentRect:self.scrollView.frame];
    
    windowFrame.size.width = MIN(NSWidth(windowFrame), NSWidth(screenFrame));
    windowFrame.size.height = MIN(NSHeight(windowFrame), NSHeight(screenFrame));
    
    [self setFrame:windowFrame display:NO];
    
    point.x = MAX(NSMinX(screenFrame), MIN(point.x, NSMaxX(screenFrame) - NSWidth(windowFrame)));
    point.y = MIN(MAX(NSMinY(screenFrame) + NSHeight(windowFrame), point.y), NSMaxY(screenFrame));
    
    [self.textView.window addChildWindow:self ordered:NSWindowAbove];
    [self setFrameTopLeftPoint:point];
    [self setAlphaValue:1];
    [self orderFront:nil];
    
    static NSCharacterSet *kLegalCharacters;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableCharacterSet *temp = [[NSCharacterSet letterCharacterSet] mutableCopy];
        
        [temp formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
        [temp formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"_!?.#"]];
        
        kLegalCharacters = [temp copy];
    });
    
    __unsafe_unretained typeof (self) blockSelf = self;
    
    id eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSLeftMouseDownMask|NSRightMouseDownMask|NSOtherMouseDownMask|NSKeyDownMask|NSScrollWheelMask handler:^NSEvent *(NSEvent *event) {
        switch (event.type) {
            case NSKeyDown: {
                switch (event.keyCode) {
                    case KEY_CODE_ESCAPE:
                        [blockSelf hideCompletionWindow];
                        return nil;
                    case KEY_CODE_ENTER:
                    case KEY_CODE_RETURN:
                    case KEY_CODE_TAB:
                        [blockSelf _insertCompletionItem:[blockSelf.completionItems objectAtIndex:[blockSelf.tableView selectedRow]]];
                        return nil;
                    case KEY_CODE_UP_ARROW:
                    case KEY_CODE_DOWN_ARROW:
                        [blockSelf.tableView keyDown:event];
                        return nil;
                    case KEY_CODE_DELETE:
                    case KEY_CODE_DELETE_FORWARD:
                        return event;
                    default:
                        if ((event.modifierFlags & NSControlKeyMask) || (event.modifierFlags & NSCommandKeyMask))
                            [blockSelf hideCompletionWindow];
                        else if ([event.charactersIgnoringModifiers rangeOfCharacterFromSet:kLegalCharacters].location == NSNotFound) {
                            [blockSelf hideCompletionWindow];
                        }
                        return event;
                }
            }
                break;
            case NSLeftMouseDown:
            case NSRightMouseDown:
            case NSOtherMouseDown:
                if (event.window != self) {
                    [blockSelf hideCompletionWindow];
                    return nil;
                }
                break;
            case NSScrollWheel:
                if (event.window != self) {
                    [blockSelf hideCompletionWindow];
                    return nil;
                }
                break;
            default:
                break;
        }
        return event;
    }];
    
    [self setEventMonitor:eventMonitor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidResignActive:) name:NSApplicationDidResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_symbolScannerDidFinishScanningSymbols:) name:WCSymbolScannerDidFinishScanningSymbolsNotification object:[self.textView.delegate symbolScannerForTextView:self.textView]];
}

- (void)hideCompletionWindow; {
    [self.textView.window removeChildWindow:self];
    [self setTextView:nil];
    [self setEventMonitor:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WCSymbolScannerDidFinishScanningSymbolsNotification object:nil];
    
    __unsafe_unretained typeof (self) blockSelf = self;
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setDuration:0.25];
        
        [blockSelf.animator setAlphaValue:0];
    } completionHandler:^{
        [blockSelf orderOut:nil];
        [blockSelf setCompletionItems:nil];
    }];
}
#pragma mark *** Private Methods ***
- (void)_insertCompletionItem:(WCCompletionItem *)completionItem; {
    NSDictionary *defaultAttributes = [WCSyntaxHighlighter defaultAttributes];
    NSMutableAttributedString *string;
    
    if ([completionItem.dataSource isKindOfClass:[Completion class]]) {
        string = [[NSMutableAttributedString alloc] initWithAttributedString:[self _attributedStringForCompletion:(Completion *)completionItem.dataSource]];
    }
    else {
        string = [[NSMutableAttributedString alloc] initWithString:[completionItem.dataSource name] attributes:defaultAttributes];
        
        if ([completionItem.dataSource respondsToSelector:@selector(arguments)]) {
            NSArray *arguments = [[completionItem.dataSource arguments] componentsSeparatedByString:@","];
            
            if (arguments.count) {
                NSMutableAttributedString *argumentString = [[NSMutableAttributedString alloc] initWithString:@"(" attributes:defaultAttributes];
                
                [arguments enumerateObjectsUsingBlock:^(NSString *argument, NSUInteger argumentIndex, BOOL *stop) {
                    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                    
                    [attachment setAttachmentCell:[[WCArgumentPlaceholderCell alloc] initTextCell:[argument stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
                    
                    [argumentString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
                    
                    if (argumentIndex == arguments.count - 1)
                        [argumentString appendAttributedString:[[NSAttributedString alloc] initWithString:@")" attributes:defaultAttributes]];
                    else
                        [argumentString appendAttributedString:[[NSAttributedString alloc] initWithString:@"," attributes:defaultAttributes]];
                }];
                
                [string appendAttributedString:argumentString];
            }
        }
    }
    
    NSRange charRange = self.textView.rangeForUserCompletion;
    
    if (charRange.location == NSNotFound)
        charRange = self.textView.selectedRange;
    
    if ([self.textView shouldChangeTextInRange:charRange replacementString:string.string]) {
        [self.textView.textStorage replaceCharactersInRange:charRange withAttributedString:string];
        [self.textView didChangeText];
        
        NSRange range = [self.textView.textStorage WC_nextPlaceholderRangeForRange:charRange inRange:NSMakeRange(charRange.location, string.length) wrap:NO];
        
        if (range.location != NSNotFound)
            [self.textView setSelectedRange:range];
    }
    
    if ([completionItem.dataSource respondsToSelector:@selector(priority)])
        [completionItem.dataSource setPriority:@([completionItem.dataSource priority].longLongValue + 1)];
    
    [self hideCompletionWindow];
}
- (NSArray *)_completionsWithPrefix:(NSString *)prefix; {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Completion"];
    
    if (prefix.length)
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.name BEGINSWITH[cd] %@",prefix]];
    
    [fetchRequest setSortDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO],[NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES],[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)] ]];
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
}

- (NSAttributedString *)_attributedStringForCompletion:(Completion *)completion; {
    NSMutableAttributedString *retval = [[NSMutableAttributedString alloc] initWithString:@"" attributes:[WCSyntaxHighlighter defaultAttributes]];
    
    if (completion.placeholders.count > 0) {
        for (Placeholder *placeholder in completion.placeholders) {
            if (placeholder.isPlaceholderValue) {
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                
                [attachment setAttachmentCell:[[WCArgumentPlaceholderCell alloc] initTextCell:placeholder.name arguments:placeholder.arguments]];
                
                [retval appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
            }
            else {
                [retval.mutableString appendString:placeholder.name];
            }
        }
    }
    else {
        [retval.mutableString appendString:completion.name];
    }
    
    return retval;
}

#pragma mark Properties
- (void)setCompletionItems:(NSArray *)completionItems {
    _completionItems = completionItems;
    
    [self.tableView reloadData];
}

- (void)setEventMonitor:(id)eventMonitor {
    if (_eventMonitor)
        [NSEvent removeMonitor:_eventMonitor];
    
    _eventMonitor = eventMonitor;
}
#pragma mark Actions
- (IBAction)_tableViewDoubleClick:(id)sender {
    if (self.tableView.clickedRow == -1) {
        NSBeep();
        return;
    }
    
    [self _insertCompletionItem:[self.completionItems objectAtIndex:self.tableView.clickedRow]];
}
#pragma mark Notifications
- (void)_applicationDidResignActive:(NSNotification *)note {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidResignActiveNotification object:nil];
    
    [self hideCompletionWindow];
}
- (void)_symbolScannerDidFinishScanningSymbols:(NSNotification *)note {
    NSRange completionRange = self.textView.rangeForUserCompletion;
    NSString *prefix = (completionRange.location == NSNotFound) ? nil : [self.textView.string substringWithRange:completionRange];
    NSArray *completions = [self _completionsWithPrefix:prefix];
    NSArray *symbols = [[self.textView.delegate symbolScannerForTextView:self.textView] symbolsWithPrefix:prefix];
    NSMutableArray *completionItems = [NSMutableArray arrayWithCapacity:symbols.count];
    
    for (Completion *completion in completions)
        [completionItems addObject:[[WCCompletionItem alloc] initWithDataSource:completion]];
    
    for (Symbol *symbol in symbols)
        [completionItems addObject:[[WCCompletionItem alloc] initWithDataSource:symbol]];
    
    [self setCompletionItems:completionItems];
}

@end
