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

@interface WCProjectViewController () <NSOutlineViewDataSource,WCOutlineViewDelegate,NSUserInterfaceValidations>

@property (weak,nonatomic) IBOutlet WCOutlineView *outlineView;

@property (assign,nonatomic) WCProjectWindowController *projectWindowController;
@property (readonly,nonatomic) WCProjectDocument *projectDocument;
@property (assign,nonatomic) BOOL ignoreChanges;

- (void)_setupOutlineViewContextualMenu;
- (void)_restoreFromProjectSetting;
@end

@implementation WCProjectViewController
#pragma mark *** Subclass Overrides ***
- (NSString *)nibName {
    return @"WCProjectView";
}

- (void)loadView {
    [super loadView];
    
    [self.outlineView setEmptyString:NSLocalizedString(@"No Filter Results", nil)];
    [self.outlineView setTarget:self];
    [self.outlineView setDoubleAction:@selector(_outlineViewDoubleAction:)];
    [self.outlineView setDataSource:self];
    [self.outlineView setDelegate:self];
    
    [self _setupOutlineViewContextualMenu];
    [self _restoreFromProjectSetting];
}
#pragma mark NSOutlineViewDataSource
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(File *)item {
    if (item) {
        return (item.isGroup.boolValue || item.files.count > 0);
    }
    return YES;
}
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(File *)item {
    if (item) {
        return item.files.count;
    }
    return 1;
}
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(File *)item {
    if (item) {
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
    
    return cell;
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

#pragma mark NSUserInterfaceValidations
- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem {
    if ([anItem action] == @selector(sortByNameAction:) ||
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
    
    [group setPath:file.path];
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
    
    [group setPath:file.file.path];
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
- (IBAction)addFilesToProject:(id)sender {
    
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
                
                break;
                // cancel
            case NSAlertAlternateReturn:
                
                break;
                // move to trash
            case NSAlertOtherReturn:
                
                break;
            default:
                break;
        }
    }
    else {
        for (File *file in files)
            [self.projectDocument.managedObjectContext deleteObject:file];
        
        [self.projectDocument.managedObjectContext processPendingChanges];
        
        [self.outlineView reloadData];
        
        [self.projectDocument updateChangeCount:NSChangeDone];
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
    [menu addItemWithTitle:NSLocalizedString(@"Add Files to Project", nil) action:@selector(addFilesToProject:) keyEquivalent:@""];
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
#pragma mark Actions
- (IBAction)_outlineViewDoubleAction:(NSOutlineView *)sender {
    for (File *file in [sender WC_selectedItems]) {
        WCSourceFileDocument *sfDocument = [self.projectDocument sourceFileDocumentForFile:file];
        
        if (sfDocument && [sfDocument isKindOfClass:[WCSourceFileDocument class]])
            [self.projectWindowController.tabViewController selectTabBarItemForSourceFileDocument:sfDocument];
    }
}

@end
