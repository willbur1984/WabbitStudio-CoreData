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

NSString *const WCSymbolScannerDidFinishScanningSymbolsNotification = @"WCSymbolScannerDidFinishScanningSymbolsNotification";

static NSString *const kWCSymbolScannerOperationQueueName = @"org.revsoft.wabbitcode.symbol-scanner";

@interface WCSymbolScanner ()
@property (readwrite,weak,nonatomic) NSTextStorage *textStorage;
@property (strong,nonatomic) NSOperationQueue *operationQueue;
@property (readwrite,strong,nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong,nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong,nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation WCSymbolScanner

- (id)initWithTextStorage:(NSTextStorage *)textStorage; {
    if (!(self = [super init]))
        return nil;
    
    [self setTextStorage:textStorage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidProcessEditing:) name:NSTextStorageDidProcessEditingNotification object:textStorage];
    
    [self setOperationQueue:[[NSOperationQueue alloc] init]];
    [self.operationQueue setMaxConcurrentOperationCount:1];
    [self.operationQueue setName:kWCSymbolScannerOperationQueueName];
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Symbols" withExtension:@"momd"];
    
    [self setManagedObjectModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL]];
    [self setPersistentStoreCoordinator:[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel]];
    [self.persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL];
    [self setManagedObjectContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType]];
    [self.managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    [self.managedObjectContext setUndoManager:nil];
    
    return self;
}

- (void)scanSymbols; {
    [self.managedObjectContext reset];
    
    WCScanSymbolsOperation *operation = [[WCScanSymbolsOperation alloc] initWithSymbolScanner:self];
    
    __block typeof (self) blockSelf = self;
    
    [operation setCompletionBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:WCSymbolScannerDidFinishScanningSymbolsNotification object:blockSelf];
    }];
    
    [self.operationQueue addOperation:operation];
}

- (id)symbolForRange:(NSRange)range; {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Symbol"];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.location <= %lu",range.location]];
    [fetchRequest setSortDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"location" ascending:YES] ]];
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL].lastObject;
}
- (NSArray *)symbolsWithName:(NSString *)name; {
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

- (void)_textStorageDidProcessEditing:(NSNotification *)note {
    if (!([note.object editedMask] & NSTextStorageEditedCharacters))
        return;
    
    [self scanSymbols];
}

@end
