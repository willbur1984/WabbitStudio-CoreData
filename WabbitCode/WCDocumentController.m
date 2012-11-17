//
//  WCDocumentController.m
//  WabbitStudio
//
//  Created by William Towe on 10/23/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCDocumentController.h"
#import "WCProjectDocument.h"
#import "Project.h"
#import "File.h"
#import "WCDefines.h"
#import "NSURL+WCExtensions.h"

NSString *const kProjectDocumentUTI = @"org.revsoft.wabbitcode.project";
NSString *const kAssemblyFileUTI = @"org.revsoft.wabbitcode.assembly";
NSString *const kIncludeFileUTI = @"org.revsoft.wabbitcode.include";
NSString *const kActiveServerIncludeFileUTI = @"com.panic.coda.active-server-include-file";

NSString *const kProjectEntityName = @"Project";
NSString *const kFileEntityName = @"File";

@implementation WCDocumentController

- (id)init {
    if (!(self = [super init]))
        return nil;

    [self setAutosavingDelay:20];
    
    return self;
}

- (BOOL)makeProjectDocumentForURL:(NSURL *)documentURL withContentsOfURL:(NSURL *)directoryURL error:(NSError *__autoreleasing *)outError {
    NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:directoryURL includingPropertiesForKeys:@[NSURLIsDirectoryKey,NSURLParentDirectoryURLKey] options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants errorHandler:^BOOL(NSURL *url, NSError *error) {
        WCLog(@"%@ %@",url,error);
        return YES;
    }];
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Projects" withExtension:@"momd"];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    
    [[NSFileManager defaultManager] removeItemAtURL:documentURL error:NULL];
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:documentURL options:nil error:outError])
        return NO;
    
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    [managedObjectContext setUndoManager:nil];
    [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    
    Project *project = [NSEntityDescription insertNewObjectForEntityForName:kProjectEntityName inManagedObjectContext:managedObjectContext];
    
    [project setName:documentURL.lastPathComponent];
    
    NSMutableDictionary *URLsToFiles = [NSMutableDictionary dictionaryWithCapacity:0];
    
    File *projectFile = [NSEntityDescription insertNewObjectForEntityForName:kFileEntityName inManagedObjectContext:managedObjectContext];
    
    [projectFile setName:documentURL.lastPathComponent];
    [projectFile setPath:documentURL.path];
    [project setFile:projectFile];
    
    [URLsToFiles setObject:projectFile forKey:directoryURL];
    
    for (NSURL *url in directoryEnumerator) {
        File *parentFile = [URLsToFiles objectForKey:[url WC_parentDirectory]];
        File *file = [NSEntityDescription insertNewObjectForEntityForName:kFileEntityName inManagedObjectContext:managedObjectContext];
        
        [file setName:url.lastPathComponent];
        [file setPath:url.path];
        
        [[parentFile filesSet] addObject:file];
        
        if ([url WC_isDirectory]) {
            [file setIsGroup:@true];
            
            [URLsToFiles setObject:file forKey:url];
        }
    }
    
    return [managedObjectContext save:outError];
}

- (NSArray *)unsavedDocumentURLs {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:0];
    
    for (NSDocument *document in self.documents) {
        if (document.isDocumentEdited)
            [temp addObject:document.fileURL];
    }
    
    return temp;
}
- (NSSet *)sourceFileUTIs {
    return [NSSet setWithObjects:kAssemblyFileUTI,kIncludeFileUTI,kActiveServerIncludeFileUTI, nil];
}

@end
