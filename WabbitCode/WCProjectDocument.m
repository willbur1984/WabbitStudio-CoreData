//
//  WCProjectDocument.m
//  WabbitStudio
//
//  Created by William Towe on 10/26/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCProjectDocument.h"
#import "WCProjectWindowController.h"
#import "WCDefines.h"
#import "WCSourceFileDocument.h"
#import "NSURL+WCExtensions.h"
#import "WCDocumentController.h"
#import "WCSymbolIndex.h"
#import "File.h"
#import "Project.h"
#import "NSArray+WCExtensions.h"
#import "NSImage+WCExtensions.h"
#import "WCOpenQuicklyWindowController.h"
#import "ProjectSetting.h"
#import "WCAddToProjectAccessoryViewController.h"
#import "WCTabViewController.h"
#import "WCTabView.h"
#import "WCEditorFocusWindowController.h"

@interface WCProjectDocument ()
@property (strong,nonatomic) NSMapTable *mutableFileUUIDsToSourceFileDocuments;
@property (strong,nonatomic) NSMutableSet *mutableSourceFileDocuments;
@property (readwrite,strong,nonatomic) WCSymbolIndex *symbolIndex;
@property (strong,nonatomic) NSCountedSet *openFileUUIDs;
@end

@implementation WCProjectDocument
#pragma mark *** Subclass Overrides ***
- (id)init {
    if (!(self = [super init]))
        return nil;
    
    [self setMutableFileUUIDsToSourceFileDocuments:[NSMapTable mapTableWithStrongToWeakObjects]];
    [self setMutableSourceFileDocuments:[NSMutableSet setWithCapacity:0]];
    
    return self;
}
#pragma mark NSDocument
- (void)close {
    [super close];
    
    for (WCSourceFileDocument *sourceFileDocument in self.mutableSourceFileDocuments)
        [sourceFileDocument close];
}

- (void)makeWindowControllers {
    WCProjectWindowController *windowController = [[WCProjectWindowController alloc] init];
    
    [self addWindowController:windowController];
}

+ (BOOL)autosavesInPlace {
    return YES;
}

- (void)saveDocument:(id)sender {
    [super saveDocument:nil];
    
    [self.projectWindowController.tabViewController.tabView.selectedTabViewItem.identifier saveDocument:nil];
}
#pragma mark NSPersistentDocument
- (id)managedObjectModel {
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Projects" withExtension:@"momd"]];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    [super setManagedObjectContext:managedObjectContext];
    
    [managedObjectContext setUndoManager:nil];
}

- (NSString *)persistentStoreTypeForFileType:(NSString *)fileType {
    return NSSQLiteStoreType;
}

- (BOOL)configurePersistentStoreCoordinatorForURL:(NSURL *)url ofType:(NSString *)fileType modelConfiguration:(NSString *)configuration storeOptions:(NSDictionary *)storeOptions error:(NSError *__autoreleasing *)error {
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:storeOptions];
    
    [options setObject:@true forKey:NSMigratePersistentStoresAutomaticallyOption];
    [options setObject:@true forKey:NSInferMappingModelAutomaticallyOption];
    
    BOOL retval = [super configurePersistentStoreCoordinatorForURL:url ofType:fileType modelConfiguration:configuration storeOptions:options error:error];
    
    if (retval) {
        [self setSymbolIndex:[[WCSymbolIndex alloc] initWithProjectDocument:self]];
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kFileEntityName];
        
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.isGroup == %@",@false]];
        
        NSSet *UTIs = [[WCDocumentController sharedDocumentController] sourceFileUTIs];
        
        for (File *file in [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL]) {
            NSURL *url = [NSURL fileURLWithPath:file.path isDirectory:NO];
            NSString *uti = [url WC_typeIdentifier];
            
            if (![UTIs containsObject:uti])
                continue;
            
            NSError *documentError;
            WCSourceFileDocument *sourceFileDocument = [[WCSourceFileDocument alloc] initWithContentsOfURL:url ofType:uti projectDocument:self UUID:file.uuid error:&documentError];
            
            if (!sourceFileDocument) {
                WCLogObject(documentError);
                continue;
            }
            
            [self.mutableFileUUIDsToSourceFileDocuments setObject:sourceFileDocument forKey:file.uuid];
            [self.mutableSourceFileDocuments addObject:sourceFileDocument];
        }
        
        fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kFileEntityName];
        
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.file == nil"]];
        
        File *file = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL].lastObject;
        
        [self.mutableFileUUIDsToSourceFileDocuments setObject:self forKey:file.uuid];
    }
    
    return retval;
}
#pragma mark *** Public Methods ***
- (WCSourceFileDocument *)sourceFileDocumentForFile:(File *)file; {
    return [self.mutableFileUUIDsToSourceFileDocuments objectForKey:file.uuid];
}

- (File *)fileForSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument; {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kFileEntityName];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.uuid == %@",sourceFileDocument.UUID]];
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL].lastObject;
}
- (File *)fileWithUUID:(NSString *)UUID; {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kFileEntityName];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.uuid == %@",UUID]];
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL].lastObject;
}
- (NSImage *)imageForFile:(File *)file; {
    WCSourceFileDocument *sourceFileDocument = [self sourceFileDocumentForFile:file];
    NSImage *retval = file.image;
    
    if (sourceFileDocument.isDocumentEdited && file.project == nil)
        retval = [retval WC_unsavedImageIcon];
    
    return retval;
}

- (NSArray *)addFilesForURLs:(NSArray *)URLs toParentFile:(File *)parentFile atIndex:(NSUInteger)index; {
    NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *newFiles = [NSMutableArray arrayWithCapacity:0];
    NSSet *filePaths = self.filePaths;
    NSSet *UTIs = [[WCDocumentController sharedDocumentController] sourceFileUTIs];
    NSMutableDictionary *URLsToFiles = [NSMutableDictionary dictionaryWithCapacity:0];
    BOOL copyFiles = [[NSUserDefaults standardUserDefaults] boolForKey:WCAddToProjectAccessoryViewControllerCopyItemsIntoDestinationGroupsFolderUserDefaultsKey];
    NSURL *directoryURL = [NSURL fileURLWithPath:parentFile.directoryPath isDirectory:YES];
    
    [URLsToFiles setObject:parentFile forKey:directoryURL];
    
    for (NSURL *url in URLs) {
        NSURL *newURL = url;
        
        if (copyFiles) {
            NSURL *copyURL = [directoryURL URLByAppendingPathComponent:url.lastPathComponent];
            NSError *copyError;
            if (![[NSFileManager defaultManager] copyItemAtURL:url toURL:copyURL error:&copyError]) {
                WCLogObject(copyError);
                continue;
            }
            
            newURL = copyURL;
        }
        
        if ([filePaths containsObject:newURL.path])
            continue;
        
        File *newFile = [NSEntityDescription insertNewObjectForEntityForName:kFileEntityName inManagedObjectContext:self.managedObjectContext];
        
        [newFile setName:newURL.lastPathComponent];
        [newFile setPath:newURL.path];
        [newFile setUti:[newURL WC_typeIdentifier]];
        
        [parentFile.filesSet insertObject:newFile atIndex:(index++)];
        
        if ([newURL WC_isDirectory]) {
            [newFile setIsGroup:@true];
            
            [URLsToFiles setObject:newFile forKey:newURL];
            
            NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:newURL includingPropertiesForKeys:@[NSURLIsDirectoryKey,NSURLParentDirectoryURLKey,NSURLTypeIdentifierKey] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
                WCLog(@"%@ %@",url,error);
                return YES;
            }];
            
            for (NSURL *childURL in directoryEnumerator) {
                File *childParentFile = [URLsToFiles objectForKey:[childURL WC_parentDirectory]];
                
                if (!childParentFile)
                    continue;
                
                File *childNewFile = [NSEntityDescription insertNewObjectForEntityForName:kFileEntityName inManagedObjectContext:self.managedObjectContext];
                
                [childNewFile setName:childURL.lastPathComponent];
                [childNewFile setPath:childURL.path];
                [childNewFile setUti:[childURL WC_typeIdentifier]];
                
                [childParentFile.filesSet addObject:childNewFile];
                
                if ([childURL WC_isDirectory]) {
                    [childNewFile setIsGroup:@true];
                    
                    [URLsToFiles setObject:childNewFile forKey:childURL];
                }
                
                [newFiles addObject:childNewFile];
            }
        }
        
        [newFiles addObject:newFile];
        [retval addObject:newFile];
    }
    
    for (File *newFile in newFiles) {
        if (![UTIs containsObject:newFile.uti])
            continue;
        
        NSError *documentError;
        WCSourceFileDocument *sourceFileDocument = [[WCSourceFileDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:newFile.path isDirectory:NO] ofType:newFile.uti projectDocument:self UUID:newFile.uuid error:&documentError];
        
        if (!sourceFileDocument) {
            WCLogObject(documentError);
            continue;
        }
        
        [self.mutableFileUUIDsToSourceFileDocuments setObject:sourceFileDocument forKey:newFile.uuid];
        [self.mutableSourceFileDocuments addObject:sourceFileDocument];
    }
    
    [self.managedObjectContext processPendingChanges];
    
    return retval;
}
- (void)removeFiles:(NSArray *)files moveToTrash:(BOOL)moveToTrash; {
    for (File *file in files) {
        WCSourceFileDocument *document = [self sourceFileDocumentForFile:file];
        
        if (document) {
            [document close];
            
            [self.mutableFileUUIDsToSourceFileDocuments removeObjectForKey:file.uuid];
            [self.mutableSourceFileDocuments removeObject:document];
        }
    }
    
    if (moveToTrash) {
        NSMutableArray *urls = [NSMutableArray arrayWithCapacity:files.count];
        
        for (File *file in files)
            [urls addObject:[NSURL fileURLWithPath:file.path isDirectory:file.isGroupValue]];
        
        [[NSWorkspace sharedWorkspace] recycleURLs:urls completionHandler:nil];
    }
    
    for (File *file in files)
        [self.managedObjectContext deleteObject:file];
    
    [self.managedObjectContext processPendingChanges];
    
    [self updateChangeCount:NSChangeDone];
}
#pragma mark Actions
- (IBAction)openQuicklyAction:(id)sender; {
    [[WCOpenQuicklyWindowController sharedWindowController] showOpenQuicklyWindowForProjectDocument:self];
}
- (IBAction)moveFocusToEditorAction:(id)sender; {
    [[WCEditorFocusWindowController sharedWindowController] showEditorFocusWindowForProjectDocument:self];
}
#pragma mark Properties
- (NSString *)UUID {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
    Project *project = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL].lastObject;
    
    return project.uuid;
}
- (WCProjectWindowController *)projectWindowController {
    return [self.windowControllers WC_firstObject];
}
- (Project *)project {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kProjectEntityName];
    
    [fetchRequest setFetchLimit:1];
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL].lastObject;
}
- (ProjectSetting *)projectSetting {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kProjectSettingEntityName];
    
    [fetchRequest setFetchLimit:1];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.shortUserName == %@",NSUserName()]];
    
    ProjectSetting *retval = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL].lastObject;
    
    if (!retval) {
        retval = [NSEntityDescription insertNewObjectForEntityForName:kProjectSettingEntityName inManagedObjectContext:self.managedObjectContext];
        
        [retval setShortUserName:NSUserName()];
        [retval setProject:self.project];
    }
    
    return retval;
}
- (NSSet *)filePaths {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:kFileEntityName];
    
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:@[@"path"]];
    
    return [NSSet setWithArray:[[self.managedObjectContext executeFetchRequest:fetchRequest error:NULL] valueForKey:@"path"]];
}
- (NSArray *)unsavedSourceFileDocuments {
    NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
    
    for (WCSourceFileDocument *document in self.mutableSourceFileDocuments) {
        if (document.isDocumentEdited)
            [retval addObject:document];
    }
    
    return retval;
}

@end
