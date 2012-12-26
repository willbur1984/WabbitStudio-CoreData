//
//  WCProjectViewController.m
//  WabbitStudio
//
//  Created by William Towe on 11/3/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCProjectViewController.h"
#import "WCDocumentController.h"
#import "WCProjectDocument.h"
#import "WCProjectWindowController.h"
#import "WCProjectCellView.h"
#import "WCTabViewController.h"
#import "NSOutlineView+WCExtensions.h"
#import "NSURL+WCExtensions.h"
#import "Project.h"
#import "File.h"
#import "WCOutlineView.h"
#import "NSArray+WCExtensions.h"
#import "WCDefines.h"
#import "WCSourceFileDocument.h"
#import "ProjectSetting.h"
#import "NSURL+WCExtensions.h"
#import "WCAddToProjectAccessoryViewController.h"
#import "WCAppController.h"
#import "WCGlassGradientView.h"

@interface WCProjectViewController () <NSOutlineViewDataSource,WCOutlineViewDelegate,NSUserInterfaceValidations,NSOpenSavePanelDelegate>

@property (weak,nonatomic) IBOutlet WCOutlineView *outlineView;
@property (weak,nonatomic) IBOutlet WCGlassGradientView *glassGradientView;
@property (weak,nonatomic) IBOutlet NSSearchField *filterSearchField;

@property (assign,nonatomic) WCProjectWindowController *projectWindowController;
@property (readonly,nonatomic) WCProjectDocument *projectDocument;
@property (assign,nonatomic) BOOL ignoreChanges;
@property (strong,nonatomic) NSSet *filePaths;
@property (strong,nonatomic) WCAddToProjectAccessoryViewController *accessoryViewController;
@property (strong,nonatomic) NSArray *filteredFiles;
@property (strong,nonatomic) NSMapTable *filteredParentFilesToChildFiles;

- (void)_setupOutlineViewContextualMenu;
- (void)_restoreFromProjectSetting;
- (IBAction)_filterSearchFieldAction:(NSSearchField *)sender;
@end

@implementation WCProjectViewController
#pragma mark *** Subclass Overrides ***
- (NSString *)nibName {
    return @"WCProjectView";
}

- (void)loadView {
    [super loadView];
    
    [self.glassGradientView setEdges:WCGlassGradientViewEdgesMaxY];
    
    [(NSSearchFieldCell *)self.filterSearchField.cell setPlaceholderString:NSLocalizedString(@"Filter Files", nil)];
    [[(NSSearchFieldCell *)self.filterSearchField.cell searchButtonCell] setImage:[NSImage imageNamed:@"Filter.png"]];
    [[(NSSearchFieldCell *)self.filterSearchField.cell searchButtonCell] setAlternateImage:nil];
    
    [self.outlineView registerForDraggedTypes:@[NSPasteboardTypeString,(__bridge NSString *)kUTTypeFileURL,(__bridge NSString *)kUTTypeDirectory]];
    [self.outlineView setVerticalMotionCanBeginDrag:YES];
    [self.outlineView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
    [self.outlineView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
    [self.outlineView setEmptyString:NSLocalizedString(@"No Filter Results", nil)];
    [self.outlineView setTarget:self];
    [self.outlineView setDoubleAction:@selector(_outlineViewDoubleAction:)];
    [self.outlineView setDataSource:self];
    [self.outlineView setDelegate:self];
    
    __unsafe_unretained typeof (self) weakSelf = self;
    
    [self.outlineView setShouldDrawEmptyStringPredicate:^BOOL(WCOutlineView *outlineView) {
        if (weakSelf.filteredFiles)
            return (weakSelf.filteredFiles.count == 0 && outlineView.emptyAttributedString.length > 0);
        return (outlineView.numberOfRows == 0 && outlineView.emptyAttributedString.length > 0);
    }];
    
    [self _setupOutlineViewContextualMenu];
    [self _restoreFromProjectSetting];
    
    if (self.projectDocument.projectSetting.projectFilterString.length > 0) {
        [self.filterSearchField setStringValue:self.projectDocument.projectSetting.projectFilterString];
        [self _filterSearchFieldAction:self.filterSearchField];
    }
}
#pragma mark NSOutlineViewDataSource
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(File *)item {
    if (item) {
        return item.isGroupValue;
    }
    return YES;
}
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(File *)item {
    if (item) {
        if (self.filteredFiles) {
            return [[self.filteredParentFilesToChildFiles objectForKey:item] count];
        }
        return item.files.count;
    }
    return 1;
}
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(File *)item {
    if (item) {
        if (self.filteredFiles) {
            return [[self.filteredParentFilesToChildFiles objectForKey:item] objectAtIndex:index];
        }
        return [item.files objectAtIndex:index];
    }
    return self.projectDocument.project.file;
}
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(File *)item {
    return item;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(File *)item {
    WCProjectCellView *cell = [outlineView makeViewWithIdentifier:tableColumn.identifier owner:nil];
    
    if (!cell) {
        cell = [[WCProjectCellView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(outlineView.frame), 0)];
        
        [cell setIdentifier:tableColumn.identifier];
    }
    
    [cell setOutlineView:outlineView];
    
    return cell;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {
    if (!item || index == NSOutlineViewDropOnItemIndex || self.filteredFiles)
        return NSDragOperationNone;
    else if ([info draggingSource] == outlineView) {
        __unsafe_unretained typeof (self) weakSelf = self;
        __block NSDragOperation retval = NSDragOperationMove;
        NSMutableArray *files = [NSMutableArray arrayWithCapacity:0];
        NSRegularExpression *uuidRegex = [[WCAppController sharedController] uuidRegularExpression];
        
        [info enumerateDraggingItemsWithOptions:0 forView:outlineView classes:@[[NSString class]] searchOptions:nil usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
            NSString *uuid = draggingItem.item;
            
            if (![uuidRegex firstMatchInString:uuid options:0 range:NSMakeRange(0, uuid.length)])
                return;
            
            File *file = [weakSelf.projectDocument fileWithUUID:uuid];
            
            WCAssert(file,@"file cannot be nil!");
            
            [files addObject:file];
            
            if (!file.file) {
                retval = NSDragOperationNone;
                *stop = YES;
            }
        }];
        
        for (File *file in files) {
            // cannot drag an item onto itself
            if (file == item) {
                retval = NSDragOperationNone;
                break;
            }
            // cannot drag an item onto one of its children
            else if ([[file flattenedFilesAndGroups] containsObject:item]) {
                retval = NSDragOperationNone;
                break;
            }
            // if its a single item moving within its parent, require it to move one index up or down
            else if (files.count == 1 &&
                     item == file.file &&
                     ([file.file.files indexOfObject:file] == index || [file.file.files indexOfObject:file] == index - 1)) {
                
                retval = NSDragOperationNone;
                break;
            }
        }
        
        return retval;
    }
    else {
        
        return NSDragOperationCopy;
    }
}
- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {
    if ([info draggingSource] == outlineView) {
        __unsafe_unretained typeof (self) weakSelf = self;
        __block NSInteger indexCopy = index;
        NSMutableArray *files = [NSMutableArray arrayWithCapacity:0];
        NSRegularExpression *uuidRegex = [[WCAppController sharedController] uuidRegularExpression];
        File *projectFile = self.projectDocument.project.file;
        
        [info enumerateDraggingItemsWithOptions:0 forView:outlineView classes:@[[NSString class]] searchOptions:nil usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
            NSString *uuid = draggingItem.item;
            
            if (![uuidRegex firstMatchInString:uuid options:0 range:NSMakeRange(0, uuid.length)])
                return;
            
            File *file = [weakSelf.projectDocument fileWithUUID:uuid];
            
            WCAssert(file,@"file cannot be nil!");
            
            [files addObject:file];
            
            if (file.file == projectFile && [projectFile.files indexOfObject:file] < index)
                indexCopy--;
        }];
        
        File *file = (File *)item;
        
        [file.filesSet removeObjectsInArray:files];
        [file.filesSet insertObjects:files atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexCopy, files.count)]];
        
        [self.outlineView reloadData];
        [self.outlineView WC_setSelectedItems:files];
        
        [self.projectDocument updateChangeCount:NSChangeDone];
    }
    else {
        NSMutableArray *fileURLs = [NSMutableArray arrayWithCapacity:0];
        
        [info enumerateDraggingItemsWithOptions:0 forView:outlineView classes:@[[NSURL class]] searchOptions:nil usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
            [fileURLs addObject:draggingItem.item];
        }];
        
        NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString(@"Add Files to \"%@\"", nil),self.projectDocument.displayName] defaultButton:NSLocalizedString(@"Add", nil) alternateButton:NSLocalizedString(@"Cancel", nil) otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Choose options for the files to be added to the project.", nil)];
        
        [self setAccessoryViewController:[[WCAddToProjectAccessoryViewController alloc] init]];
        [alert setAccessoryView:self.accessoryViewController.view];
        
        [alert beginSheetModalForWindow:self.view.window modalDelegate:self didEndSelector:@selector(_alertDidEnd:code:context:) contextInfo:(void *)CFBridgingRetain(@{@"item" : item,@"index" : @(index),@"urls" : fileURLs})];
    }
    return YES;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard {
    [pasteboard clearContents];
    
    NSMutableArray *fileURLs = [NSMutableArray arrayWithCapacity:items.count];
    
    for (File *file in items) {
        if (!file.isGroupValue)
            [fileURLs addObject:[NSURL fileURLWithPath:file.path isDirectory:NO]];
    }
    
    [fileURLs insertObjects:[items valueForKey:@"uuid"] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, items.count)]];
    
    return [pasteboard writeObjects:fileURLs];
}
#pragma mark NSOutlineViewDelegate
- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    if (self.ignoreChanges)
        return;
    
    [self.projectDocument.projectSetting setProjectSelectedFiles:[NSSet setWithArray:[self.outlineView WC_selectedItems]]];
    
    [self.projectDocument updateChangeCount:NSChangeDone|NSChangeDiscardable];
}
- (void)outlineViewItemDidCollapse:(NSNotification *)notification {
    if (self.ignoreChanges)
        return;
    
    [self.projectDocument.projectSetting setProjectExpandedFiles:[NSOrderedSet orderedSetWithArray:[self.outlineView WC_expandedItems]]];
    
    [self.projectDocument updateChangeCount:NSChangeDone|NSChangeDiscardable];
}
- (void)outlineViewItemDidExpand:(NSNotification *)notification {
    if (self.ignoreChanges)
        return;
    
    [self.projectDocument.projectSetting setProjectExpandedFiles:[NSOrderedSet orderedSetWithArray:[self.outlineView WC_expandedItems]]];
    
    [self.projectDocument updateChangeCount:NSChangeDone|NSChangeDiscardable];
}
#pragma mark WCOutlineViewDelegate
- (BOOL)validateDeleteActionInOutlineView:(WCOutlineView *)outlineView {
    return YES;
}
- (void)deleteActionInOutlineView:(WCOutlineView *)outlineView {
    [self deleteAction:nil];
}
- (void)returnActionInOutlineView:(WCOutlineView *)outlineView {
    [self _outlineViewDoubleAction:outlineView];
}
#pragma mark NSOpenSavePanelDelegate
- (BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url {
    if ([url WC_isDirectory])
        return YES;
    
    return (![self.filePaths containsObject:url.path]);
}

#pragma mark NSUserInterfaceValidations
- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem {
    if (self.filteredFiles &&
        ([anItem action] == @selector(newGroupAction:) ||
         [anItem action] == @selector(newGroupFromSelection:) ||
         [anItem action] == @selector(ungroupSelectionAction:) ||
         [anItem action] == @selector(sortByNameAction:) ||
         [anItem action] == @selector(sortByTypeAction:) ||
         [anItem action] == @selector(addFilesToProjectAction:) ||
         [anItem action] == @selector(deleteAction:) ||
         [anItem action] == @selector(renameAction:))) {
            
        return NO;
    }
    else if ([anItem action] == @selector(sortByNameAction:) ||
        [anItem action] == @selector(sortByTypeAction:) ||
        [anItem action] == @selector(ungroupSelectionAction:)) {
        
        NSArray *items = [self.outlineView WC_clickedOrSelectedItems];
        
        for (File *file in items) {
            if (!file.isGroupValue)
                return NO;
        }
    }
    else if ([anItem action] == @selector(deleteAction:) ||
             [anItem action] == @selector(delete:)) {
        
        NSArray *items = [self.outlineView WC_clickedOrSelectedItems];
        
        for (File *file in items) {
            if (!file.file)
                return NO;
        }
    }
    return YES;
}

#pragma mark WCNavigatorItem
- (id<NSCopying,NSObject>)identifier {
    return @"org.revsoft.wabbitcode.navigator.project";
}
- (NSImage *)image {
    return [NSImage imageNamed:@"Folder.tiff"];
}
- (NSString *)toolTip {
    return NSLocalizedString(@"Show the Project Navigator", nil);
}
#pragma mark *** Public Methods ***
- (id)initWithProjectWindowController:(WCProjectWindowController *)windowController; {
    if (!(self = [super init]))
        return nil;
    
    [self setProjectWindowController:windowController];
    
    return self;
}
#pragma mark Actions
- (IBAction)showInFinderAction:(id)sender {
    NSArray *files = [self.outlineView WC_clickedOrSelectedItems];
    
    if (files.count == 0) {
        NSBeep();
        return;
    }
    
    NSMutableArray *urls = [NSMutableArray arrayWithCapacity:files.count];
    
    for (File *file in files)
        [urls addObject:[NSURL fileURLWithPath:file.path isDirectory:file.isGroupValue]];
    
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:urls];
}
- (IBAction)openWithExternalEditor:(id)sender {
    NSArray *files = [self.outlineView WC_clickedOrSelectedItems];
    
    if (files.count == 0) {
        NSBeep();
        return;
    }
    
    for (File *file in files)
        [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:file.path isDirectory:file.isGroupValue]];
}
- (IBAction)newGroupAction:(id)sender {
    File *file = [self.outlineView WC_clickedOrSelectedItem];
    
    if (!file) {
        NSBeep();
        return;
    }
    
    NSUInteger index = 0;
    
    if (!file.isGroupValue) {
        index = [file.file.files indexOfObject:file] + 1;
        file = file.file;
    }
    else {
        [self.outlineView expandItem:file];
    }
    
    File *group = [NSEntityDescription insertNewObjectForEntityForName:kFileEntityName inManagedObjectContext:self.projectDocument.managedObjectContext];
    
    [group setPath:file.directoryPath];
    [group setName:NSLocalizedString(@"New Group", nil)];
    [group setIsGroup:@true];
    
    [file.filesSet insertObject:group atIndex:index];
    
    // stop the outline view from animating the new group in
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0];
    [self.outlineView reloadItem:file reloadChildren:YES];
    [NSAnimationContext endGrouping];
    
    [self.outlineView WC_setSelectedItem:group];
    [self.outlineView editColumn:0 row:[self.outlineView rowForItem:group] withEvent:nil select:YES];
    
    [self.projectDocument updateChangeCount:NSChangeDone];
}
- (IBAction)newGroupFromSelection:(id)sender {
    NSArray *files = [self.outlineView WC_clickedOrSelectedItems];
    File *file = [files WC_firstObject];
    NSUInteger index = [file.file.files indexOfObject:file];
    File *group = [NSEntityDescription insertNewObjectForEntityForName:kFileEntityName inManagedObjectContext:self.projectDocument.managedObjectContext];
    
    [group setPath:file.file.directoryPath];
    [group setName:NSLocalizedString(@"New Group", nil)];
    [group setIsGroup:@true];
    
    // insert our new group first
    [file.file.filesSet insertObject:group atIndex:index];
    
    // move files into our new group
    [group.filesSet addObjectsFromArray:files];
    
    [self.outlineView reloadData];
    [self.outlineView WC_setSelectedItem:group];
    [self.outlineView editColumn:0 row:[self.outlineView rowForItem:group] withEvent:nil select:YES];
    
    [self.projectDocument updateChangeCount:NSChangeDone];
}
- (IBAction)ungroupSelectionAction:(id)sender {
    
}
- (IBAction)sortByNameAction:(id)sender; {
    NSArray *files = [self.outlineView WC_clickedOrSelectedItems];
    
    for (File *file in files) {
        [file sortChildrenUsingComparator:^NSComparisonResult(File *obj1, File *obj2) {
            return [obj1.name localizedStandardCompare:obj2.name];
        } recursively:YES];
    }
    
    for (File *file in files)
        [self.outlineView reloadItem:file reloadChildren:YES];
}
- (IBAction)sortByTypeAction:(id)sender; {
    NSArray *files = [self.outlineView WC_clickedOrSelectedItems];
    
    for (File *file in files) {
        [file sortChildrenUsingComparator:^NSComparisonResult(File *obj1, File *obj2) {
            return [obj1.uti localizedStandardCompare:obj2.uti];
        } recursively:YES];
    }
    
    for (File *file in files)
        [self.outlineView reloadItem:file reloadChildren:YES];
}
- (IBAction)addFilesToProjectAction:(id)sender {
    [self setFilePaths:self.projectDocument.filePaths];
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    [openPanel setCanChooseDirectories:YES];
    [openPanel setAllowsMultipleSelection:YES];
    [openPanel setDelegate:self];
    [openPanel setTitle:[NSString stringWithFormat:NSLocalizedString(@"Add Files to \"%@\"", nil),self.projectDocument.displayName]];
    [openPanel setPrompt:NSLocalizedString(@"Add", nil)];
    [openPanel setMessage:NSLocalizedString(@"Choose files and directorieis to add to the project.", nil)];
    
    [self setAccessoryViewController:[[WCAddToProjectAccessoryViewController alloc] init]];
    [openPanel setAccessoryView:self.accessoryViewController.view];
    
    __unsafe_unretained typeof (self) weakSelf = self;
    File *file = [self.outlineView WC_clickedOrSelectedItem];
    NSUInteger insertIndex = 0;
    
    if (!file.isGroupValue) {
        insertIndex = [file.file.files indexOfObject:file] + 1;
        file = file.file;
    }
    
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        [weakSelf setFilePaths:nil];
        [weakSelf setAccessoryViewController:nil];
        
        if (result != NSFileHandlingPanelOKButton)
            return;
        
        NSArray *files = [weakSelf.projectDocument addFilesForURLs:[openPanel URLs] toParentFile:file atIndex:insertIndex];
        
        [weakSelf.outlineView reloadItem:file reloadChildren:YES];
        [weakSelf.outlineView WC_setSelectedItems:files];
    }];
}
- (IBAction)deleteAction:(id)sender {
    BOOL confirm = NO;
    NSArray *files = [self.outlineView WC_clickedOrSelectedItems];
    
    for (File *file in files) {
        if (file.flattenedFilesInclusive.count > 0) {
            confirm = YES;
            break;
        }
    }
    
    if (confirm) {
        NSString *defaultButton = (files.count == 1) ? NSLocalizedString(@"Remove Reference", nil) : NSLocalizedString(@"Remove References", nil);
        NSString *messageText = (files.count == 1) ? [NSString stringWithFormat:NSLocalizedString(@"Do you want to move the file \"%@\" to the trash, or only remove the reference to it?", nil),[files.lastObject name]] : [NSString stringWithFormat:NSLocalizedString(@"Do you want to move the %lu selected files to the trash, or only remove the references to them?", nil),files.count];
        NSAlert *alert = [NSAlert alertWithMessageText:messageText defaultButton:defaultButton alternateButton:NSLocalizedString(@"Cancel", nil) otherButton:NSLocalizedString(@"Move to Trash", nil) informativeTextWithFormat:@""];
        
        switch ([alert runModal]) {
                // remove reference
            case NSAlertDefaultReturn:
                [self.projectDocument removeFiles:files moveToTrash:NO];
                break;
                // cancel
            case NSAlertAlternateReturn:
                break;
                // move to trash
            case NSAlertOtherReturn:
                [self.projectDocument removeFiles:files moveToTrash:YES];
                break;
            default:
                break;
        }
    }
    else {
        [self.projectDocument removeFiles:files moveToTrash:NO];
        [self.outlineView reloadData];
    }
}
- (IBAction)renameAction:(id)sender {
    id item = [self.outlineView WC_clickedOrSelectedItem];
    
    if (!item) {
        NSBeep();
        return;
    }
    
    [self.outlineView editColumn:0 row:[self.outlineView rowForItem:item] withEvent:nil select:YES];
}
- (IBAction)openInSeparateEditorAction:(id)sender {
    
}

- (IBAction)filterInNavigatorAction:(id)sender; {
    [self.view.window makeFirstResponder:self.filterSearchField];
}
#pragma mark *** Private Methods ***
- (void)_setupOutlineViewContextualMenu; {
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"org.revsoft.wabbitcode.navigator.project.menu"];
    
    [menu addItemWithTitle:NSLocalizedString(@"Show in Finder", nil) action:@selector(showInFinderAction:) keyEquivalent:@""];
    [menu addItemWithTitle:NSLocalizedString(@"Open with External Editor", nil) action:@selector(openWithExternalEditor:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:NSLocalizedString(@"New File…", nil) action:@selector(newFileAction:) keyEquivalent:@""];
    [menu addItemWithTitle:NSLocalizedString(@"New Project…", nil) action:@selector(newProjectAction:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:NSLocalizedString(@"New Group", nil) action:@selector(newGroupAction:) keyEquivalent:@""];
    [menu addItemWithTitle:NSLocalizedString(@"New Group from Selection", nil) action:@selector(newGroupFromSelection:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:NSLocalizedString(@"Ungroup Selection", nil) action:@selector(ungroupSelectionAction:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:NSLocalizedString(@"Sort by Name", nil) action:@selector(sortByNameAction:) keyEquivalent:@""];
    [menu addItemWithTitle:NSLocalizedString(@"Sort by Type", nil) action:@selector(sortByTypeAction:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:NSLocalizedString(@"Add Files to Project", nil) action:@selector(addFilesToProjectAction:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:NSLocalizedString(@"Delete", nil) action:@selector(deleteAction:) keyEquivalent:@""];
    [menu addItemWithTitle:NSLocalizedString(@"Rename", nil) action:@selector(renameAction:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItemWithTitle:NSLocalizedString(@"Open in Separate Editor", nil) action:@selector(openInSeparateEditorAction:) keyEquivalent:@""];
    
    [self.outlineView setMenu:menu];
}
- (void)_restoreFromProjectSetting; {
    [self setIgnoreChanges:YES];
    
    ProjectSetting *projectSetting = self.projectDocument.projectSetting;
    
    [self.outlineView WC_expandItems:projectSetting.projectExpandedFiles.array];
    [self.outlineView WC_setSelectedItems:projectSetting.projectSelectedFiles.allObjects];
    
    [self setIgnoreChanges:NO];
}
#pragma mark Properties
- (WCProjectDocument *)projectDocument {
    return self.projectWindowController.projectDocument;
}
- (void)setFilteredFiles:(NSArray *)filteredFiles {
    _filteredFiles = filteredFiles;
    
    [self.outlineView reloadData];
}
#pragma mark Actions
- (IBAction)_outlineViewDoubleAction:(NSOutlineView *)sender {
    for (File *file in [sender WC_selectedItems]) {
        WCSourceFileDocument *sfDocument = [self.projectDocument sourceFileDocumentForFile:file];
        
        if (sfDocument && [sfDocument isKindOfClass:[WCSourceFileDocument class]])
            [self.projectWindowController.tabViewController selectTabBarItemForSourceFileDocument:sfDocument];
    }
}
- (IBAction)_filterSearchFieldAction:(NSSearchField *)sender; {
    [self.projectDocument.projectSetting setProjectFilterString:sender.stringValue];
    [self.projectDocument updateChangeCount:NSChangeDone|NSChangeDiscardable];
    
    if (sender.stringValue.length <= 1) {
        [self setFilteredParentFilesToChildFiles:nil];
        [self setFilteredFiles:nil];
        [self.outlineView collapseItem:nil collapseChildren:YES];
        [self _restoreFromProjectSetting];
        [self setIgnoreChanges:NO];
        return;
    }
    
    [self setIgnoreChanges:YES];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kFileEntityName];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.isGroup == NO AND self.name CONTAINS[cd] %@",sender.stringValue]];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)]]];
    
    NSArray *files = [self.projectDocument.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    NSMapTable *filteredParentFilesToChildFiles = [NSMapTable mapTableWithStrongToStrongObjects];
    
    for (File *file in files) {
        File *parentFile = file.file;
        File *childFile = file;
        
        do {
            
            NSMutableOrderedSet *childFiles = [filteredParentFilesToChildFiles objectForKey:parentFile];
            
            if (!childFiles) {
                childFiles = [NSMutableOrderedSet orderedSetWithCapacity:0];
                
                [filteredParentFilesToChildFiles setObject:childFiles forKey:parentFile];
            }
            
            [childFiles addObject:childFile];
            
            childFile = parentFile;
            parentFile = parentFile.file;
            
        } while (parentFile);
    }
    
    [self setFilteredParentFilesToChildFiles:filteredParentFilesToChildFiles];
    [self setFilteredFiles:files];
    [self.outlineView expandItem:nil expandChildren:YES];
}
#pragma mark Callbacks
- (void)_alertDidEnd:(NSAlert *)alert code:(NSInteger)code context:(void *)context {
    NSDictionary *info = (NSDictionary *)CFBridgingRelease((CFDictionaryRef)context);
    
    [alert.window orderOut:nil];
    
    if (code != NSAlertDefaultReturn)
        return;
    
    [self setFilePaths:self.projectDocument.filePaths];
    
    File *file = [info objectForKey:@"item"];
    NSMutableArray *urls = [[info objectForKey:@"urls"] mutableCopy];
    
    [urls filterUsingPredicate:[NSPredicate predicateWithFormat:@"NOT %@ CONTAINS self.path",self.filePaths]];
    
    NSArray *files = [self.projectDocument addFilesForURLs:urls toParentFile:file atIndex:[[info objectForKey:@"index"] integerValue]];
    
    [self.outlineView reloadItem:file reloadChildren:YES];
    [self.outlineView WC_setSelectedItems:files];
    
    [self setFilePaths:nil];
}

@end
