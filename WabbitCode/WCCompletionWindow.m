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

@interface WCCompletionWindow () <NSTableViewDataSource,NSTableViewDelegate>

@property (strong,nonatomic) NSTableView *tableView;
@property (strong,nonatomic) NSScrollView *scrollView;
@property (assign,nonatomic) WCTextView *textView;
@property (strong,nonatomic) NSArray *completionItems;
@property (weak,nonatomic) id eventMonitor;
@property (strong,nonatomic) NSLayoutManager *layoutManager;
@property (strong,nonatomic) NSTextStorage *textStorage;
@property (strong,nonatomic) NSTextContainer *textContainer;

- (void)_insertSymbol:(Symbol *)symbol;
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
    [self.scrollView setScrollerStyle:NSScrollerStyleOverlay];
    [self setContentView:self.scrollView];

    [self setTableView:[[WCTableView alloc] initWithFrame:NSZeroRect]];
    [self.tableView setHeaderView:nil];
    [self.tableView setAllowsEmptySelection:NO];
    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(_tableViewDoubleClick:)];
    [self.tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
    [self.tableView setBackgroundColor:[NSColor clearColor]];
    
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
        return [[WCSymbolImageManager sharedManager] imageForSymbol:completionItem.symbol];
    
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
    NSArray *symbols = [[self.textView.delegate symbolScannerForTextView:self.textView] symbolsWithPrefix:(completionRange.location == NSNotFound) ? nil : [self.textView.string substringWithRange:completionRange]];
    NSMutableArray *completionItems = [NSMutableArray arrayWithCapacity:symbols.count];
    
    for (Symbol *symbol in symbols)
        [completionItems addObject:[[WCCompletionItem alloc] initWithSymbol:symbol]];
    
    [self setCompletionItems:completionItems];
    
    const NSUInteger maximumNumberOfRows = 8;
    NSUInteger numberOfRows = self.completionItems.count;
    
    if (numberOfRows > maximumNumberOfRows)
        numberOfRows = maximumNumberOfRows;
    
    CGFloat minimumWidth = 150;
    
    for (WCCompletionItem *completionItem in self.completionItems) {
        [self.textStorage replaceCharactersInRange:NSMakeRange(0, self.textStorage.length) withAttributedString:completionItem.displayString];
        [self.layoutManager ensureLayoutForCharacterRange:NSMakeRange(0, self.textStorage.length)];
        
        NSRect usedRect = [self.layoutManager usedRectForTextContainer:self.textContainer];
        
        if (NSWidth(usedRect) > minimumWidth)
            minimumWidth = NSWidth(usedRect);
    }
    
    const CGFloat imageColumnWidth = [self.tableView tableColumnWithIdentifier:@"image"].width;
    
    [[self.tableView tableColumnWithIdentifier:@"name"] setWidth:minimumWidth];
    
    [self.scrollView setFrame:NSIntegralRectWithOptions(NSMakeRect(0, 0, minimumWidth + self.tableView.intercellSpacing.width + imageColumnWidth + NSWidth(self.scrollView.verticalScroller.frame), (self.tableView.rowHeight + self.tableView.intercellSpacing.height) * numberOfRows), NSAlignAllEdgesInward)];
    
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
    
    [self setFrameTopLeftPoint:point];
    [self setAlphaValue:1];
    [self orderFront:nil];
    
    __block typeof (self) blockSelf = self;
    
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
                        [blockSelf _insertSymbol:[[blockSelf.completionItems objectAtIndex:[blockSelf.tableView selectedRow]] symbol]];
                        return nil;
                    case KEY_CODE_UP_ARROW:
                    case KEY_CODE_DOWN_ARROW:
                        [blockSelf.tableView keyDown:event];
                        return nil;
                    default:
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
                // TODO: reposition the window underneath the text
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
    __block typeof (self) blockSelf = self;
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setDuration:0.3];
        
        [blockSelf.animator setAlphaValue:0];
    } completionHandler:^{
        [blockSelf orderOut:nil];
        [blockSelf setCompletionItems:nil];
    }];
    
    [self setTextView:nil];
    [self setEventMonitor:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WCSymbolScannerDidFinishScanningSymbolsNotification object:nil];
}
#pragma mark *** Private Methods ***
- (void)_insertSymbol:(Symbol *)symbol; {
    NSDictionary *defaultAttributes = [WCSyntaxHighlighter defaultAttributes];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:symbol.name attributes:defaultAttributes];
    
    if (symbol.type.intValue == SymbolTypeMacro) {
        Macro *macro = (Macro *)symbol;
        NSArray *arguments = [macro.arguments componentsSeparatedByString:@","];
        
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
    
    NSRange charRange = self.textView.rangeForUserCompletion;
    
    if (charRange.location == NSNotFound)
        charRange = self.textView.selectedRange;
    
    if ([self.textView shouldChangeTextInRange:charRange replacementString:string.string]) {
        [self.textView.textStorage replaceCharactersInRange:charRange withAttributedString:string];
        [self.textView didChangeText];
        
        NSRange lineRange = [self.textView.string lineRangeForRange:charRange];
        
        [self.textView.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(charRange.location, NSMaxRange(lineRange) - charRange.location) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
            if (value) {
                id cell = [(NSTextAttachment *)value attachmentCell];
                
                if ([cell isKindOfClass:[WCArgumentPlaceholderCell class]]) {
                    [self.textView setSelectedRange:range];
                    *stop = YES;
                }
            }
        }];
    }
    
    [self hideCompletionWindow];
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
    
    [self _insertSymbol:[[self.completionItems objectAtIndex:self.tableView.clickedRow] symbol]];
}
#pragma mark Notifications
- (void)_applicationDidResignActive:(NSNotification *)note {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidResignActiveNotification object:nil];
    
    [self hideCompletionWindow];
}
- (void)_symbolScannerDidFinishScanningSymbols:(NSNotification *)note {
    NSRange completionRange = self.textView.rangeForUserCompletion;
    NSArray *symbols = [[self.textView.delegate symbolScannerForTextView:self.textView] symbolsWithPrefix:(completionRange.location == NSNotFound) ? nil : [self.textView.string substringWithRange:completionRange]];
    NSMutableArray *completionItems = [NSMutableArray arrayWithCapacity:symbols.count];
    
    for (Symbol *symbol in symbols)
        [completionItems addObject:[[WCCompletionItem alloc] initWithSymbol:symbol]];
    
    [self setCompletionItems:completionItems];
}

@end
