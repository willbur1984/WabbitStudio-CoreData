//
//  WCFindBarViewController.m
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

#import "WCFindBarViewController.h"
#import "NSArray+WCExtensions.h"
#import "WCDefines.h"
#import "WCHUDStatusWindow.h"
#import "WCGeometry.h"

@interface WCFindBarViewController () <NSTextFieldDelegate,NSMenuDelegate>

@property (weak,nonatomic) IBOutlet NSSearchField *searchField;
@property (weak,nonatomic) IBOutlet NSButton *doneButton;
@property (weak,nonatomic) IBOutlet NSPopUpButton *popUpButton;
@property (weak,nonatomic) IBOutlet NSSegmentedControl *segmentedControl;
@property (weak,nonatomic) IBOutlet NSTextField *statusTextField;
@property (weak,nonatomic) IBOutlet NSButton *replaceButton;
@property (weak,nonatomic) IBOutlet NSButton *replaceAllButton;
@property (weak,nonatomic) IBOutlet NSButton *replaceAndFindButton;
@property (weak,nonatomic) IBOutlet NSTextField *replaceTextField;

@property (assign,nonatomic) NSTextView *textView;
@property (readwrite,copy,nonatomic) NSIndexSet *findRanges;
@property (readwrite,assign,nonatomic) BOOL findRangesAreDirty;
@property (weak,nonatomic) NSTimer *editedTimer;
@property (strong,nonatomic) NSMutableIndexSet *mutableFindRanges;
@property (strong,nonatomic) NSRegularExpression *findRegularExpression;

- (void)_find;
- (void)_findAndHighlightNearestRange:(BOOL)highlightNearestRange;
- (void)_setupSearchFieldMenu;
- (void)_setupPopUpButton;
- (void)_updateStatusTextFieldWithNumberOfMatches:(NSUInteger)numberOfMatches;
- (NSRange)_findNextRangeIncludingSelectedRange:(BOOL)includeSelectedRange didWrap:(BOOL *)didWrap;
- (NSRange)_findPreviousRangeDidWrap:(BOOL *)didWrap;
- (void)_setReplaceViewsHidden:(BOOL)hidden;
@end

@implementation WCFindBarViewController
#pragma mark *** Subclass Overrides ***
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)nibName {
    return @"WCFindBarView";
}

- (void)loadView {
    [super loadView];
    
    [self.searchField setDelegate:self];
    [self.searchField setTarget:self];
    [self.searchField setAction:@selector(_searchFieldAction:)];
    [self _setupSearchFieldMenu];
    
    [self.doneButton setTarget:self];
    [self.doneButton setAction:@selector(_doneButtonAction:)];
    
    [self.segmentedControl setTarget:self];
    [self.segmentedControl setAction:@selector(_segmentedControlAction:)];
    
    [self.statusTextField setStringValue:@""];
    
    [self.replaceButton setTarget:self];
    [self.replaceButton setAction:@selector(_replaceButtonAction:)];
    
    [self.replaceAndFindButton setTarget:self];
    [self.replaceAndFindButton setAction:@selector(_replaceAndFindButtonAction:)];
    
    [self.replaceAllButton setTarget:self];
    [self.replaceAllButton setAction:@selector(_replaceAllButtonAction:)];
    
    [self.replaceTextField setDelegate:self];
    [(NSTextFieldCell *)self.replaceTextField.cell setPlaceholderString:NSLocalizedString(@"Replace", nil)];
    
    [self _setupPopUpButton];
    
    [self setMatchingStyle:WCFindBarViewControllerMatchingStyleTextual];
}

- (void)cleanup {
    [super cleanup];
    
    [self setEditedTimer:nil];
}
#pragma mark NSResponder
- (void)performTextFinderAction:(id)sender; {
    switch ([sender tag]) {
        case NSTextFinderActionShowFindInterface:
            [self showFindBar:YES completion:nil];
            break;
        case NSTextFinderActionHideFindInterface:
            [self showFindBar:NO completion:nil];
            break;
        case NSTextFinderActionNextMatch:
            [self findNextAction:nil];
            break;
        case NSTextFinderActionPreviousMatch:
            [self findPreviousAction:nil];
            break;
        case NSTextFinderActionReplace:
            [self replaceAction:nil];
            break;
        case NSTextFinderActionReplaceAll:
            [self replaceAllAction:nil];
            break;
        case NSTextFinderActionReplaceAndFind:
            [self replaceAndFindAction:nil];
            break;
        case NSTextFinderActionSetSearchString: {
            id plist = [[NSPasteboard pasteboardWithName:NSFindPboard] propertyListForType:NSPasteboardTypeTextFinderOptions];
            
            WCLogObject(plist);
        }
            break;
        case NSTextFinderActionShowReplaceInterface:
            [self showFindBar:YES showReplace:YES completion:nil];
            break;
        case NSTextFinderActionHideReplaceInterface:
            [self showFindBar:YES showReplace:NO completion:nil];
            break;
        default:
            break;
    }
}
#pragma mark NSUserInterfaceValidations
- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem {
    if ([anItem action] == @selector(performTextFinderAction:) ||
        [anItem action] == @selector(performFindPanelAction:)) {
        
        switch ([anItem tag]) {
            case NSTextFinderActionReplace:
            case NSTextFinderActionReplaceAll:
            case NSTextFinderActionReplaceAllInSelection:
            case NSTextFinderActionReplaceAndFind:
                if (!self.textView.isEditable)
                    return NO;
                break;
            case NSTextFinderActionSelectAll:
            case NSTextFinderActionSelectAllInSelection:
                if (!self.textView.isSelectable)
                    return NO;
                break;
            default:
                break;
        }
        return YES;
    }
    else if ([anItem action] == @selector(_anchorsMatchLinesAction:)) {
        if (self.matchingStyle == WCFindBarViewControllerMatchingStyleTextual)
            return NO;
    }
    else if ([anItem action] == @selector(_dotMatchesNewlinesAction:)) {
        if (self.matchingStyle == WCFindBarViewControllerMatchingStyleTextual)
            return NO;
    }
    return YES;
}
#pragma mark NSTextFieldDelegate
- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (commandSelector == @selector(cancelOperation:)) {
        [self showFindBar:NO completion:nil];
        return YES;
    }
    else if (commandSelector == @selector(insertNewline:)) {
        if ([control isKindOfClass:[NSSearchField class]]) {
            if (self.mutableFindRanges.count > 0) {
                if (self.findRangesAreDirty)
                    [self findAction:nil];
                else
                    [self findNextAction:nil];
            }
            else if (self.searchField.stringValue.length > 0)
                [self findAction:nil];
        }
        else if ([control isKindOfClass:[NSTextField class]]) {
            [self replaceAction:nil];
        }
        
        return YES;
    }
    return NO;
}
#pragma mark NSMenuDelegate
- (void)menuNeedsUpdate:(NSMenu *)menu {
    if (menu == [menu.supermenu itemWithTag:kMatchingStyleItemTag].submenu) {
        for (NSMenuItem *item in menu.itemArray) {
            if (item.tag == self.matchingStyle)
                [item setState:NSOnState];
            else
                [item setState:NSOffState];
        }
    }
    else if (menu == [menu.supermenu itemWithTag:kMatchingTypeItemTag].submenu) {
        for (NSMenuItem *item in menu.itemArray) {
            if (item.tag == self.matchingType)
                [item setState:NSOnState];
            else
                [item setState:NSOffState];
        }
    }
    else {
        NSMenuItem *ignoreCaseItem = [menu itemWithTag:kIgnoreCaseItemTag];
        
        [ignoreCaseItem setState:(self.ignoreCase) ? NSOnState : NSOffState];
        
        NSMenuItem *wrapAroundItem = [menu itemWithTag:kWrapAroundItemTag];
        
        [wrapAroundItem setState:(self.wrapAround) ? NSOnState : NSOffState];
        
        NSMenuItem *anchorsMatchLinesItem = [menu itemWithTag:kAnchorsMatchLinesItemTag];
        
        [anchorsMatchLinesItem setState:(self.anchorsMatchLines) ? NSOnState : NSOffState];
        
        NSMenuItem *dotMatchesNewlinesItem = [menu itemWithTag:kDotMatchesNewlinesItemTag];
        
        [dotMatchesNewlinesItem setState:(self.dotMatchesNewlines) ? NSOnState : NSOffState];
    }
}
#pragma mark *** Public Methods ***
- (id)initWithTextView:(NSTextView *)textView; {
    if (!(self = [super init]))
        return nil;
    
    [self setTextView:textView];
    [self setMutableFindRanges:[NSMutableIndexSet indexSet]];
    [self setWrapAround:YES];
    
    return self;
}

- (void)showFindBar:(BOOL)showFindBar completion:(void (^)(void))completion; {
    [self showFindBar:showFindBar showReplace:NO completion:completion];
}

static const CGFloat kFindViewHeight = 22;
static const CGFloat kReplaceViewHeight = 44;

- (void)showFindBar:(BOOL)showFindBar showReplace:(BOOL)showReplace completion:(void (^)(void))completion; {
    if (showFindBar) {
        if (!self.view.superview) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidProcessEditing:) name:NSTextStorageDidProcessEditingNotification object:self.textView.textStorage];
            
            [self.textView.enclosingScrollView addSubview:self.view];
            
            NSString *string = [[NSPasteboard pasteboardWithName:NSFindPboard] stringForType:NSPasteboardTypeString];
            
            if (string.length > 0) {
                [self.searchField setStringValue:string];
                [self _find];
            }
        }
        
        if (showReplace) {
            [self.view setFrameSize:NSMakeSize(NSWidth(self.view.frame), kReplaceViewHeight)];
            [self _setReplaceViewsHidden:NO];
            [self.searchField setNextKeyView:self.replaceTextField];
            [self.replaceTextField setNextKeyView:self.textView];
            [self.textView.window makeFirstResponder:self.replaceTextField];
        }
        else {
            [self.view setFrameSize:NSMakeSize(NSWidth(self.view.frame), kFindViewHeight)];
            [self _setReplaceViewsHidden:YES];
            [self.searchField setNextKeyView:self.textView];
            [self.textView.window makeFirstResponder:self.searchField];
        }
        
        [self.textView.enclosingScrollView tile];
        
        if (completion)
            completion();
    }
    else {
        if (!self.view.superview)
            return;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTextStorageDidProcessEditingNotification object:nil];
        
        [self.view removeFromSuperview];
        [self.textView.enclosingScrollView tile];
        [self.textView.window makeFirstResponder:self.textView];
        
        if (completion)
            completion();
    }
}

+ (NSDictionary *)findRangeAttributes; {
    return @{NSBackgroundColorAttributeName : [[NSColor yellowColor] colorWithAlphaComponent:0.75], NSUnderlineColorAttributeName : [NSColor orangeColor]};
}
#pragma mark Properties
- (void)setViewMode:(WCFindBarViewControllerViewMode)viewMode {
    _viewMode = viewMode;
    
    [self showFindBar:YES showReplace:(viewMode == WCFindBarViewControllerViewModeReplace) completion:nil];
}
- (void)setMatchingStyle:(WCFindBarViewControllerMatchingStyle)matchingStyle {
    _matchingStyle = matchingStyle;
    
    switch (self.matchingStyle) {
        case WCFindBarViewControllerMatchingStyleTextual:
            [(NSSearchFieldCell *)self.searchField.cell setPlaceholderString:NSLocalizedString(@"Textual Search", nil)];
            break;
        case WCFindBarViewControllerMatchingStyleRegularExpression:
            [(NSSearchFieldCell *)self.searchField.cell setPlaceholderString:NSLocalizedString(@"Regular Expression", nil)];
            break;
        default:
            break;
    }
    
    [self _find];
}
- (void)setMatchingType:(WCFindBarViewControllerMatchingType)matchingType {
    _matchingType = matchingType;
    
    [self _find];
}
- (void)setIgnoreCase:(BOOL)ignoreCase {
    _ignoreCase = ignoreCase;
    
    [self _find];
}
- (void)setAnchorsMatchLines:(BOOL)anchorsMatchLines {
    _anchorsMatchLines = anchorsMatchLines;
    
    [self _find];
}
- (void)setDotMatchesNewlines:(BOOL)dotMatchesNewlines {
    _dotMatchesNewlines = dotMatchesNewlines;
    
    [self _find];
}
- (void)setEditedTimer:(NSTimer *)editedTimer {
    [_editedTimer invalidate];
    
    _editedTimer = editedTimer;
}
#pragma mark Actions
- (IBAction)findAction:(id)sender; {
    [self _findAndHighlightNearestRange:YES];
}
- (IBAction)findNextAction:(id)sender; {
    if (self.searchField.stringValue.length == 0) {
        NSBeep();
        return;
    }
    
    BOOL didWrap = NO;
    NSRange range = [self _findNextRangeIncludingSelectedRange:NO didWrap:&didWrap];
    
    if (range.location == NSNotFound) {
        NSBeep();
        
        if (!self.wrapAround)
            [[WCHUDStatusWindow sharedInstance] showImage:[NSImage imageNamed:@"FindNoWrapIndicator"] inView:self.textView.enclosingScrollView drawBackground:NO];
    }
    else {
        [self.textView setSelectedRange:range];
        [self.textView scrollRangeToVisible:range];
        [self.textView showFindIndicatorForRange:range];
        
        if (didWrap)
            [[WCHUDStatusWindow sharedInstance] showImage:[NSImage imageNamed:@"FindWrapIndicator"] inView:self.textView.enclosingScrollView drawBackground:NO];
    }
}
- (IBAction)findPreviousAction:(id)sender; {
    if (self.searchField.stringValue.length == 0) {
        NSBeep();
        return;
    }
    
    BOOL didWrap = NO;
    NSRange range = [self _findPreviousRangeDidWrap:&didWrap];
    
    if (range.location == NSNotFound) {
        NSBeep();
        
        if (!self.wrapAround)
            [[WCHUDStatusWindow sharedInstance] showImage:[NSImage imageNamed:@"FindNoWrapIndicatorReverse"] inView:self.textView.enclosingScrollView drawBackground:NO];
    }
    else {
        [self.textView setSelectedRange:range];
        [self.textView scrollRangeToVisible:range];
        [self.textView showFindIndicatorForRange:range];
        
        if (didWrap)
            [[WCHUDStatusWindow sharedInstance] showImage:[NSImage imageNamed:@"FindWrapIndicatorReverse"] inView:self.textView.enclosingScrollView drawBackground:NO];
    }
}
- (IBAction)replaceAction:(id)sender; {
    if (self.searchField.stringValue.length == 0) {
        NSBeep();
        return;
    }
    
    BOOL didWrap = NO;
    NSRange range = [self _findNextRangeIncludingSelectedRange:YES didWrap:&didWrap];
    
    if (range.location == NSNotFound) {
        NSBeep();
        
        if (!self.wrapAround)
            [[WCHUDStatusWindow sharedInstance] showImage:[NSImage imageNamed:@"FindNoWrapIndicator"] inView:self.textView.enclosingScrollView drawBackground:NO];
    }
    else {
        [self.textView setSelectedRange:range];
        [self.textView scrollRangeToVisible:range];
        
        NSString *replaceString;
        
        if (self.matchingStyle == WCFindBarViewControllerMatchingStyleTextual)
            replaceString = self.replaceTextField.stringValue;
        else
            replaceString = [self.findRegularExpression stringByReplacingMatchesInString:[self.textView.string substringWithRange:range] options:0 range:NSMakeRange(0, range.length) withTemplate:self.replaceTextField.stringValue];
        
        if ([self.textView shouldChangeTextInRange:range replacementString:replaceString]) {
            [self.textView replaceCharactersInRange:range withString:replaceString];
            [self.textView didChangeText];
        }
        
        if (didWrap)
            [[WCHUDStatusWindow sharedInstance] showImage:[NSImage imageNamed:@"FindWrapIndicator"] inView:self.textView.enclosingScrollView drawBackground:NO];
    }
}
- (IBAction)replaceAndFindAction:(id)sender; {
    if (self.searchField.stringValue.length == 0) {
        NSBeep();
        return;
    }
    
    BOOL didWrap = NO;
    NSRange range = [self _findNextRangeIncludingSelectedRange:YES didWrap:&didWrap];
    
    if (range.location == NSNotFound) {
        NSBeep();
        
        if (self.wrapAround)
            [[WCHUDStatusWindow sharedInstance] showImage:[NSImage imageNamed:@"FindNoWrapIndicator"] inView:self.textView.enclosingScrollView drawBackground:NO];
    }
    else {
        [self.textView setSelectedRange:range];
        [self.textView scrollRangeToVisible:range];
        
        NSString *replaceString;
        
        if (self.matchingStyle == WCFindBarViewControllerMatchingStyleTextual)
            replaceString = self.replaceTextField.stringValue;
        else
            replaceString = [self.findRegularExpression stringByReplacingMatchesInString:[self.textView.string substringWithRange:range] options:0 range:NSMakeRange(0, range.length) withTemplate:self.replaceTextField.stringValue];
        
        if ([self.textView shouldChangeTextInRange:range replacementString:replaceString]) {
            [self.textView replaceCharactersInRange:range withString:replaceString];
            [self.textView didChangeText];
        }
        
        [self findNextAction:nil];
        
        if (didWrap)
            [[WCHUDStatusWindow sharedInstance] showImage:[NSImage imageNamed:@"FindWrapIndicator"] inView:self.textView.enclosingScrollView drawBackground:NO];
    }
}
- (IBAction)replaceAllAction:(id)sender; {
    if (self.searchField.stringValue.length == 0) {
        NSBeep();
        return;
    }
    else if (self.mutableFindRanges.count == 0) {
        NSBeep();
        return;
    }
    
    NSMutableArray *ranges = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *strings = [NSMutableArray arrayWithCapacity:0];
    __unsafe_unretained typeof (self) weakSelf = self;
    
    [self.mutableFindRanges enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        [ranges addObject:[NSValue valueWithRange:range]];
        
        NSString *string;
        
        if (weakSelf.matchingStyle == WCFindBarViewControllerMatchingStyleTextual)
            string = weakSelf.replaceTextField.stringValue;
        else
            string = [weakSelf.findRegularExpression stringByReplacingMatchesInString:[weakSelf.textView.string substringWithRange:range] options:0 range:NSMakeRange(0, range.length) withTemplate:weakSelf.replaceTextField.stringValue];
        
        [strings addObject:string];
    }];
    
    if ([self.textView shouldChangeTextInRanges:ranges replacementStrings:strings]) {
        [self.textView.textStorage beginEditing];
        
        [ranges enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSValue *rangeValue, NSUInteger idx, BOOL *stop) {
            NSRange range = rangeValue.rangeValue;
            NSString *string = [strings objectAtIndex:idx];
            
            [weakSelf.textView replaceCharactersInRange:range withString:string];
        }];
        
        [self.textView.textStorage endEditing];
        [self.textView didChangeText];
        
        if (ranges.count == 1)
            [self.statusTextField setStringValue:NSLocalizedString(@"replaced 1 match", nil)];
        else
            [self.statusTextField setStringValue:[NSString stringWithFormat:NSLocalizedString(@"replaced %lu matches", nil),ranges.count]];
    }
}
#pragma mark *** Private Methods ***
- (void)_find; {
    [self _findAndHighlightNearestRange:NO];
}
- (void)_findAndHighlightNearestRange:(BOOL)highlightNearestRange; {
    [self.mutableFindRanges removeAllIndexes];
    
    NSString *searchString = self.searchField.stringValue;
    __block NSUInteger numberOfMatches = 0;
    
    if (searchString.length == 0) {
        [self setFindRanges:self.mutableFindRanges];
        [self _updateStatusTextFieldWithNumberOfMatches:numberOfMatches];
        return;
    }
    else if (self.matchingStyle == WCFindBarViewControllerMatchingStyleRegularExpression) {
        NSRegularExpressionOptions options = 0;
        
        if (self.ignoreCase)
            options |= NSRegularExpressionCaseInsensitive;
        
        NSError *outError;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:self.searchField.stringValue options:options error:&outError];
        
        if (!regex) {
            WCLogObject(outError);
            [self setFindRegularExpression:nil];
            return;
        }
        
        [self setFindRegularExpression:regex];
    }
    
    NSRange searchRange = NSMakeRange(0, self.textView.string.length);
    
    if (self.matchingStyle == WCFindBarViewControllerMatchingStyleTextual) {
        NSStringCompareOptions options = NSLiteralSearch;
        
        if (self.ignoreCase)
            options |= NSCaseInsensitiveSearch;
        
        CFLocaleRef locale = CFLocaleCopyCurrent();
        CFStringTokenizerRef tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, (__bridge CFStringRef)self.textView.string, CFRangeMake(0, self.textView.string.length), kCFStringTokenizerUnitWordBoundary, locale);
        CFRelease(locale);
        
        while (searchRange.location < self.textView.string.length) {
            NSRange findRange = [self.textView.string rangeOfString:searchString options:options range:searchRange];
            
            if (findRange.location == NSNotFound)
                break;
            
            CFStringTokenizerGoToTokenAtIndex(tokenizer, findRange.location);
            CFRange tokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer);
            
            switch (self.matchingType) {
                case NSTextFinderMatchingTypeContains:
                    [self.mutableFindRanges addIndexesInRange:findRange];
                    numberOfMatches++;
                    break;
                case NSTextFinderMatchingTypeStartsWith:
                    if (findRange.location == tokenRange.location && findRange.length < tokenRange.length) {
                        [self.mutableFindRanges addIndexesInRange:findRange];
                        numberOfMatches++;
                    }
                    break;
                case NSTextFinderMatchingTypeEndsWith:
                    if (NSMaxRange(findRange) == (tokenRange.location + tokenRange.length)) {
                        [self.mutableFindRanges addIndexesInRange:findRange];
                        numberOfMatches++;
                    }
                    break;
                case NSTextFinderMatchingTypeFullWord:
                    if (findRange.location == tokenRange.location && findRange.length == tokenRange.length) {
                        [self.mutableFindRanges addIndexesInRange:findRange];
                        numberOfMatches++;
                    }
                    break;
                default:
                    break;
            }
            
            searchRange = NSMakeRange(NSMaxRange(findRange), self.textView.string.length - NSMaxRange(findRange));
        }
        
        CFRelease(tokenizer);
    }
    else {
        __unsafe_unretained typeof (self) weakSelf = self;
        
        [self.findRegularExpression enumerateMatchesInString:self.textView.string options:0 range:searchRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            [weakSelf.mutableFindRanges addIndexesInRange:result.range];
            numberOfMatches++;
        }];
    }
    
    [self setFindRanges:self.mutableFindRanges];
    [self _updateStatusTextFieldWithNumberOfMatches:numberOfMatches];
    
    if (numberOfMatches > 0 && highlightNearestRange) {
        NSRange range = [self _findNextRangeIncludingSelectedRange:YES didWrap:NULL];
        
        [self.textView setSelectedRange:range];
        [self.textView scrollRangeToVisible:range];
        [self.textView showFindIndicatorForRange:range];
        
        NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSFindPboard];
        
        [pasteboard clearContents];
        [pasteboard writeObjects:@[self.searchField.stringValue]];
        
        [self setFindRangesAreDirty:NO];
    }
}
- (NSRange)_findNextRangeIncludingSelectedRange:(BOOL)includeSelectedRange didWrap:(BOOL *)didWrap; {
    NSRange searchRange = (includeSelectedRange) ? NSMakeRange(self.textView.selectedRange.location, self.textView.string.length - self.textView.selectedRange.location) : NSMakeRange(NSMaxRange(self.textView.selectedRange), self.textView.string.length - NSMaxRange(self.textView.selectedRange));
    NSStringCompareOptions options = NSLiteralSearch;
    NSRange range;
    
    if (self.matchingStyle == WCFindBarViewControllerMatchingStyleTextual) {
        if (self.ignoreCase)
            options |= NSCaseInsensitiveSearch;
        
        range = [self.textView.string rangeOfString:self.searchField.stringValue options:options range:searchRange];
    }
    else {
        range = [self.findRegularExpression rangeOfFirstMatchInString:self.textView.string options:0 range:searchRange];
    }
    
    if (range.location == NSNotFound && self.wrapAround) {
        if (didWrap)
            *didWrap = YES;
        
        if (includeSelectedRange)
            searchRange = NSMakeRange(0, NSMaxRange(self.textView.selectedRange));
        else
            searchRange = NSMakeRange(0, self.textView.selectedRange.location);
        
        if (self.matchingStyle == WCFindBarViewControllerMatchingStyleTextual)
            range = [self.textView.string rangeOfString:self.searchField.stringValue options:options range:searchRange];
        else
            range = [self.findRegularExpression rangeOfFirstMatchInString:self.textView.string options:0 range:searchRange];
    }
    
    return range;
}
- (NSRange)_findPreviousRangeDidWrap:(BOOL *)didWrap; {
    NSStringCompareOptions options = NSLiteralSearch;
    NSRange range;
    
    if (self.matchingStyle == WCFindBarViewControllerMatchingStyleTextual) {
        if (self.ignoreCase)
            options |= (NSCaseInsensitiveSearch|NSBackwardsSearch);
        else
            options |= NSBackwardsSearch;
        
        range = [self.textView.string rangeOfString:self.searchField.stringValue options:options range:NSMakeRange(0, self.textView.selectedRange.location)];
    }
    else {
        NSArray *matches = [self.findRegularExpression matchesInString:self.textView.string options:0 range:NSMakeRange(0, self.textView.selectedRange.location)];
        
        range = (matches.lastObject) ? [matches.lastObject range] : WC_NSNotFoundRange;
    }
    
    if (range.location == NSNotFound && self.wrapAround) {
        if (didWrap)
            *didWrap = YES;
        
        if (self.matchingStyle == WCFindBarViewControllerMatchingStyleTextual)
            range = [self.textView.string rangeOfString:self.searchField.stringValue options:options range:NSMakeRange(NSMaxRange(self.textView.selectedRange), self.textView.string.length - NSMaxRange(self.textView.selectedRange))];
        else {
            NSArray *matches = [self.findRegularExpression matchesInString:self.textView.string options:0 range:NSMakeRange(NSMaxRange(self.textView.selectedRange), self.textView.string.length - NSMaxRange(self.textView.selectedRange))];
            
            range = (matches.lastObject) ? [matches.lastObject range] : WC_NSNotFoundRange;
        }
    }
    
    return range;
}

static const NSInteger kMatchingStyleItemTag = 2001;
static const NSInteger kMatchingTypeItemTag = 2002;
static const NSInteger kIgnoreCaseItemTag = 2003;
static const NSInteger kWrapAroundItemTag = 2004;
static const NSInteger kAnchorsMatchLinesItemTag = 2005;
static const NSInteger kDotMatchesNewlinesItemTag = 2006;

- (void)_setupSearchFieldMenu; {
    NSMenu *searchMenu = [[NSMenu alloc] initWithTitle:@"org.revsoft.wabbitcode.find-bar.search-menu-template"];
    
    // case insensitive
    NSMenuItem *ignoreCaseItem = [searchMenu addItemWithTitle:NSLocalizedString(@"Ignore Case", nil) action:@selector(_ignoreCaseAction:) keyEquivalent:@""];
    
    [ignoreCaseItem setTarget:self];
    [ignoreCaseItem setTag:kIgnoreCaseItemTag];
    
    // wrap around
    NSMenuItem *wrapAroundItem = [searchMenu addItemWithTitle:NSLocalizedString(@"Wrap Around", nil) action:@selector(_wrapAroundAction:) keyEquivalent:@""];
    
    [wrapAroundItem setTarget:self];
    [wrapAroundItem setTag:kWrapAroundItemTag];
    
    [searchMenu addItem:[NSMenuItem separatorItem]];
    
    // anchors match lines
    NSMenuItem *anchorsMatchLinesItem = [searchMenu addItemWithTitle:NSLocalizedString(@"Anchors Match Lines", nil) action:@selector(_anchorsMatchLinesAction:) keyEquivalent:@""];
    
    [anchorsMatchLinesItem setTarget:self];
    [anchorsMatchLinesItem setTag:kAnchorsMatchLinesItemTag];
    
    // dot matches newlines
    NSMenuItem *dotMatchesNewlinesItem = [searchMenu addItemWithTitle:NSLocalizedString(@"Dot Matches Newlines", nil) action:@selector(_dotMatchesNewlinesAction:) keyEquivalent:@""];
    
    [dotMatchesNewlinesItem setTarget:self];
    [dotMatchesNewlinesItem setTag:kDotMatchesNewlinesItemTag];
    
    [searchMenu addItem:[NSMenuItem separatorItem]];
    
    // matching style
    NSMenuItem *matchingStyleItem = [searchMenu addItemWithTitle:NSLocalizedString(@"Matching Style", nil) action:NULL keyEquivalent:@""];
    
    [matchingStyleItem setTag:kMatchingStyleItemTag];
    
    NSMenu *matchingStyleMenu = [[NSMenu alloc] initWithTitle:@"org.revsoft.wabbitcode.find-bar.search-menu-template.matching-style-menu"];
    
    [matchingStyleMenu setDelegate:self];
    
    NSMenuItem *textualStyleItem = [matchingStyleMenu addItemWithTitle:NSLocalizedString(@"Textual", nil) action:@selector(_matchingStyleAction:) keyEquivalent:@""];
    
    [textualStyleItem setTarget:self];
    [textualStyleItem setTag:WCFindBarViewControllerMatchingStyleTextual];
    
    NSMenuItem *regularExpressionStyleItem = [matchingStyleMenu addItemWithTitle:NSLocalizedString(@"Regular Expression", nil) action:@selector(_matchingStyleAction:) keyEquivalent:@""];
    
    [regularExpressionStyleItem setTarget:self];
    [regularExpressionStyleItem setTag:WCFindBarViewControllerMatchingStyleRegularExpression];
    
    [matchingStyleItem setSubmenu:matchingStyleMenu];
    
    // matching type
    NSMenuItem *matchingTypeItem = [searchMenu addItemWithTitle:NSLocalizedString(@"Matching Type", nil) action:NULL keyEquivalent:@""];
    
    [matchingTypeItem setTag:kMatchingTypeItemTag];
    
    NSMenu *matchingTypeMenu = [[NSMenu alloc] initWithTitle:@"org.revsoft.wabbitcode.find-bar.search-menu-template.matching-type-menu"];
    
    [matchingTypeMenu setDelegate:self];
    
    NSMenuItem *containsItem = [matchingTypeMenu addItemWithTitle:NSLocalizedString(@"Contains", nil) action:@selector(_matchingTypeAction:) keyEquivalent:@""];
    
    [containsItem setTarget:self];
    [containsItem setTag:WCFindBarViewControllerMatchingTypeContains];
    
    NSMenuItem *startsWithItem = [matchingTypeMenu addItemWithTitle:NSLocalizedString(@"Starts With", nil) action:@selector(_matchingTypeAction:) keyEquivalent:@""];
    
    [startsWithItem setTarget:self];
    [startsWithItem setTag:WCFindBarViewControllerMatchingTypeStartsWith];
    
    NSMenuItem *endsWithItem = [matchingTypeMenu addItemWithTitle:NSLocalizedString(@"Ends With", nil) action:@selector(_matchingTypeAction:) keyEquivalent:@""];
    
    [endsWithItem setTarget:self];
    [endsWithItem setTag:WCFindBarViewControllerMatchingTypeEndsWith];
    
    NSMenuItem *fullWordItem = [matchingTypeMenu addItemWithTitle:NSLocalizedString(@"Full Word", nil) action:@selector(_matchingTypeAction:) keyEquivalent:@""];
    
    [fullWordItem setTarget:self];
    [fullWordItem setTag:WCFindBarViewControllerMatchingTypeFullWord];
    
    [matchingTypeItem setSubmenu:matchingTypeMenu];
    
    [searchMenu addItem:[NSMenuItem separatorItem]];
    
    // recent searches
    NSMenuItem *recentsTitleItem = [searchMenu addItemWithTitle:NSLocalizedString(@"Recent Searches", nil) action:NULL keyEquivalent:@""];
    
    [recentsTitleItem setTag:NSSearchFieldRecentsTitleMenuItemTag];
    
    NSMenuItem *recentsItem = [searchMenu addItemWithTitle:@"" action:NULL keyEquivalent:@""];
    
    [recentsItem setTag:NSSearchFieldRecentsMenuItemTag];
    
    NSMenuItem *noRecentsItem = [searchMenu addItemWithTitle:NSLocalizedString(@"No Recent Searches", nil) action:NULL keyEquivalent:@""];
    
    [noRecentsItem setTag:NSSearchFieldNoRecentsMenuItemTag];
    
    NSMenuItem *clearRecentsSeparator = [NSMenuItem separatorItem];
    
    [clearRecentsSeparator setTag:NSSearchFieldClearRecentsMenuItemTag];
    
    [searchMenu addItem:clearRecentsSeparator];
    
    NSMenuItem *clearRecentsItem = [searchMenu addItemWithTitle:NSLocalizedString(@"Clear Recent Searches", nil) action:NULL keyEquivalent:@""];
    
    [clearRecentsItem setTag:NSSearchFieldClearRecentsMenuItemTag];
    
    [(NSSearchFieldCell *)self.searchField.cell setSearchMenuTemplate:searchMenu];
    
    [self menuNeedsUpdate:searchMenu];
    [self menuNeedsUpdate:matchingStyleMenu];
    [self menuNeedsUpdate:matchingTypeMenu];
}
- (void)_setupPopUpButton; {
    [self.popUpButton removeAllItems];
    
    NSMenuItem *findItem = [self.popUpButton.menu addItemWithTitle:NSLocalizedString(@"Find", nil) action:@selector(_popUpButtonAction:) keyEquivalent:@""];
    
    [findItem setTarget:self];
    [findItem setTag:WCFindBarViewControllerViewModeFind];
    
    NSMenuItem *replaceItem = [self.popUpButton.menu addItemWithTitle:NSLocalizedString(@"Replace", nil) action:@selector(_popUpButtonAction:) keyEquivalent:@""];
    
    [replaceItem setTarget:self];
    [replaceItem setTag:WCFindBarViewControllerViewModeReplace];
    
    if (!self.textView.isEditable)
        [self.popUpButton setHidden:YES];
}
- (void)_updateStatusTextFieldWithNumberOfMatches:(NSUInteger)numberOfMatches; {
    if (numberOfMatches == 0) {
        [self.statusTextField setStringValue:NSLocalizedString(@"Not Found", nil)];
    }
    else if (numberOfMatches == 1) {
        [self.statusTextField setStringValue:NSLocalizedString(@"1 match", nil)];
    }
    else {
        [self.statusTextField setStringValue:[NSString stringWithFormat:NSLocalizedString(@"%lu matches", nil),numberOfMatches]];
    }
}
- (void)_setReplaceViewsHidden:(BOOL)hidden; {
    [self.replaceAllButton setHidden:hidden];
    [self.replaceButton setHidden:hidden];
    [self.replaceAndFindButton setHidden:hidden];
    [self.replaceTextField setHidden:hidden];
}
#pragma mark Actions
- (IBAction)_doneButtonAction:(id)sender {
    [self showFindBar:NO completion:nil];
}
- (IBAction)_searchFieldAction:(NSSearchField *)sender {
    [self findAction:nil];
}
- (IBAction)_matchingStyleAction:(NSMenuItem *)sender {
    [self setMatchingStyle:sender.tag];
}
- (IBAction)_matchingTypeAction:(NSMenuItem *)sender {
    [self setMatchingType:sender.tag];
}
- (IBAction)_ignoreCaseAction:(id)sender {
    [self setIgnoreCase:!self.ignoreCase];
}
- (IBAction)_wrapAroundAction:(id)sender {
    [self setWrapAround:!self.wrapAround];
}
- (IBAction)_anchorsMatchLinesAction:(id)sender {
    [self setAnchorsMatchLines:!self.anchorsMatchLines];
}
- (IBAction)_dotMatchesNewlinesAction:(id)sender {
    [self setDotMatchesNewlines:!self.dotMatchesNewlines];
}
- (IBAction)_replaceButtonAction:(id)sender {
    [self replaceAction:nil];
}
- (IBAction)_replaceAndFindButtonAction:(id)sender {
    [self replaceAndFindAction:nil];
}
- (IBAction)_replaceAllButtonAction:(id)sender {
    [self replaceAllAction:nil];
}
- (IBAction)_segmentedControlAction:(NSSegmentedControl *)sender {
    if (sender.selectedSegment == 0)
        [self findPreviousAction:nil];
    else
        [self findNextAction:nil];
}
- (IBAction)_popUpButtonAction:(NSMenuItem *)sender {
    [self setViewMode:sender.tag];
}
#pragma mark Notifications
- (void)_textStorageDidProcessEditing:(NSNotification *)note {
    if (!([note.object editedMask] & NSTextStorageEditedCharacters))
        return;
    
    [self setFindRangesAreDirty:YES];
    
    [self setEditedTimer:[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(_find) userInfo:nil repeats:NO]];
}

@end
