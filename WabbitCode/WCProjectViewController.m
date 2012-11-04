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

@interface WCProjectViewController () <NSOutlineViewDataSource,NSOutlineViewDelegate>

@property (weak,nonatomic) IBOutlet NSOutlineView *outlineView;

@property (assign,nonatomic) WCProjectWindowController *projectWindowController;
@property (readonly,nonatomic) WCProjectDocument *projectDocument;
@property (strong,nonatomic) Project *project;
@end

@implementation WCProjectViewController
#pragma mark *** Subclass Overrides ***
- (NSString *)nibName {
    return @"WCProjectView";
}

- (void)loadView {
    [super loadView];
    
    [self.outlineView setTarget:self];
    [self.outlineView setDoubleAction:@selector(_outlineViewDoubleAction:)];
    [self.outlineView setDataSource:self];
}
#pragma mark NSOutlineViewDataSource
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(File *)item {
    if (item) {
        return (item.files.count > 0);
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
    return self.project.file;
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
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kProjectEntityName];
    
    [self setProject:[self.projectDocument.managedObjectContext executeFetchRequest:fetchRequest error:NULL].lastObject];
    
    return self;
}
#pragma mark *** Private Methods ***

#pragma mark Properties
- (WCProjectDocument *)projectDocument {
    return self.projectWindowController.projectDocument;
}
#pragma mark Actions
- (IBAction)_outlineViewDoubleAction:(NSOutlineView *)sender {
    for (File *file in [sender WC_selectedItems]) {
        WCSourceFileDocument *sfDocument = [self.projectDocument.fileUUIDsToSourceFileDocuments objectForKey:file.uuid];
        
        if (sfDocument)
            [self.projectWindowController.tabViewController selectTabBarItemForSourceFileDocument:sfDocument];
    }
}

@end
