//
//  WCSymbolScanner.m
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

#import "WCSymbolScanner.h"
#import "WCScanSymbolsOperation.h"
#import "WCDefines.h"
#import "WCSourceFileDocument.h"
#import "WCTextStorage.h"
#import "WCProjectDocument.h"
#import "WCSymbolIndex.h"
#import "NSString+WCExtensions.h"

NSString *const WCSymbolScannerDidFinishScanningSymbolsNotification = @"WCSymbolScannerDidFinishScanningSymbolsNotification";

static NSString *const kWCSymbolScannerOperationQueueName = @"org.revsoft.wabbitcode.symbol-scanner";

@interface WCSymbolScanner ()
@property (readwrite,weak,nonatomic) NSTextStorage *textStorage;
@property (strong,nonatomic) NSOperationQueue *operationQueue;
@property (readwrite,strong,nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong,nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong,nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong,nonatomic) NSMutableDictionary *symbolNamesToSymbolArrays;
@property (readwrite,copy,nonatomic) NSString *fileContainerUUID;
@end

@implementation WCSymbolScanner

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithSourceFileDocument:(WCSourceFileDocument *)sourceFileDocument; {
    if (!(self = [super init]))
        return nil;
    
    [self setFileContainerUUID:sourceFileDocument.UUID];
    
    [self setTextStorage:sourceFileDocument.textStorage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidProcessEditing:) name:NSTextStorageDidProcessEditingNotification object:self.textStorage];
    
    [self setOperationQueue:[[NSOperationQueue alloc] init]];
    [self.operationQueue setMaxConcurrentOperationCount:1];
    [self.operationQueue setName:kWCSymbolScannerOperationQueueName];
    
    if (!sourceFileDocument.projectDocument) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Symbols" withExtension:@"momd"];
        
        [self setManagedObjectModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL]];
        [self setPersistentStoreCoordinator:[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel]];
        [self.persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL];
    }
    
    [self setManagedObjectContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType]];
    
    if (sourceFileDocument.projectDocument) {
        [self.managedObjectContext setParentContext:sourceFileDocument.projectDocument.symbolIndex.managedObjectContext];
    }
    else {
        [self.managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.managedObjectContext];
    
    [self.managedObjectContext setUndoManager:nil];
    [self.managedObjectContext setMergePolicy:NSOverwriteMergePolicy];
    
    [self setSymbolNamesToSymbolArrays:[NSMutableDictionary dictionaryWithCapacity:0]];
    
    return self;
}

- (void)scanSymbols; {
    [self.operationQueue cancelAllOperations];
    
    WCScanSymbolsOperation *operation = [[WCScanSymbolsOperation alloc] initWithSymbolScanner:self];
    __weak typeof (self) weakSelf = self;
    
    [operation setCompletionBlock:^{
        [weakSelf.symbolNamesToSymbolArrays removeAllObjects];
    }];
    
    [self.operationQueue addOperation:operation];
}

- (Symbol *)symbolForRange:(NSRange)range; {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Symbol"];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.file.identifier == %@ AND self.location <= %@",self.fileContainerUUID,@(range.location)]];
    [fetchRequest setSortDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"location" ascending:YES] ]];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    return results.lastObject;
}
- (NSArray *)symbolsWithName:(NSString *)name; {
    NSArray *retval = [self.symbolNamesToSymbolArrays objectForKey:name];
    
    if (!retval) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Symbol"];
        
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.name ==[cd] %@",name]];
        [fetchRequest setSortDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"type" ascending:NO] ]];
        
        retval = [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
        
        [self.symbolNamesToSymbolArrays setObject:retval forKey:name];
    }
    
    return retval;
}
- (NSArray *)symbolsSortedByLocationWithName:(NSString *)name; {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Symbol"];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.name ==[cd] %@",name]];
    [fetchRequest setSortDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"location" ascending:YES] ]];
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
}
- (NSArray *)symbolsOfType:(SymbolType)type withName:(NSString *)name; {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Symbol"];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.type == %i AND self.name ==[cd] %@",type,name]];
    [fetchRequest setSortDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"location" ascending:YES] ]];
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
}

- (NSArray *)symbolsWithPrefix:(NSString *)prefix; {    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Symbol"];
    
    if (prefix.length)
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.name BEGINSWITH[cd] %@",prefix]];
    
    [fetchRequest setSortDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)], [NSSortDescriptor sortDescriptorWithKey:@"type" ascending:YES]]];
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
}

+ (NSRegularExpression *)symbolRegex; {
    static NSRegularExpression *retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[NSRegularExpression alloc] initWithPattern:@"[A-Za-z0-9_!?.]+" options:0 error:NULL];
    });
    return retval;
}

- (void)setDelegate:(id<WCSymbolScannerDelegate>)delegate {
    _delegate = delegate;
    
    [self scanSymbols];
}
- (NSArray *)symbolsSortedByLocation {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Symbol"];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.file.identifier == %@",self.fileContainerUUID]];
    [fetchRequest setSortDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"location" ascending:YES]]];
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
}

- (void)_textStorageDidProcessEditing:(NSNotification *)note {
    if (!([note.object editedMask] & NSTextStorageEditedCharacters))
        return;
    
    [self scanSymbols];
}
- (void)_managedObjectContextDidSave:(NSNotificationCenter *)note {
    [[NSNotificationCenter defaultCenter] postNotificationName:WCSymbolScannerDidFinishScanningSymbolsNotification object:self];
}

@end
