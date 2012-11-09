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

@interface WCProjectDocument ()
@property (strong,nonatomic) NSMutableDictionary *mutableFileUUIDsToSourceFileDocuments;
@property (readwrite,strong,nonatomic) WCSymbolIndex *symbolIndex;
@end

@implementation WCProjectDocument

- (id)init {
    if (!(self = [super init]))
        return nil;
    
    [self setMutableFileUUIDsToSourceFileDocuments:[NSMutableDictionary dictionaryWithCapacity:0]];
    
    return self;
}

- (void)makeWindowControllers {
    WCProjectWindowController *windowController = [[WCProjectWindowController alloc] init];
    
    [self addWindowController:windowController];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    [super setManagedObjectContext:managedObjectContext];
    
    [managedObjectContext setUndoManager:nil];
}

- (NSString *)persistentStoreTypeForFileType:(NSString *)fileType {
    return NSXMLStoreType;
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
        }
    }
    
    return retval;
}

- (NSString *)UUID {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
    Project *project = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL].lastObject;
    
    return project.uuid;
}
- (NSDictionary *)fileUUIDsToSourceFileDocuments {
    return [self.mutableFileUUIDsToSourceFileDocuments copy];
}
- (WCProjectWindowController *)projectWindowController {
    return [self.windowControllers WC_firstObject];
}

@end
