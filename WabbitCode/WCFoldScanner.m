//
//  WCFoldScanner.m
//  WabbitStudio
//
//  Created by William Towe on 9/28/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCFoldScanner.h"
#import "WCScanFoldsOperation.h"
#import "WCDefines.h"

NSString *const WCFoldScannerDidFinishScanningFoldsNotification = @"WCFoldScannerDidFinishScanningFoldsNotification";

static NSString *const kWCFoldScannerOperationQueueName = @"org.revsoft.wabbitcode.fold-scanner";

@interface WCFoldScanner ()
@property (readwrite,weak,nonatomic) NSTextStorage *textStorage;
@property (strong,nonatomic) NSOperationQueue *operationQueue;
@property (readwrite,strong,nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong,nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong,nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (assign,nonatomic,getter = isScanning) BOOL scanning;
@property (assign,nonatomic) BOOL scanPending;
@end

@implementation WCFoldScanner

- (id)initWithTextStorage:(NSTextStorage *)textStorage {
    if (!(self = [super init]))
        return nil;
    
    [self setTextStorage:textStorage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidProcessEditing:) name:NSTextStorageDidProcessEditingNotification object:textStorage];
    
    [self setOperationQueue:[[NSOperationQueue alloc] init]];
    [self.operationQueue setMaxConcurrentOperationCount:1];
    [self.operationQueue setName:kWCFoldScannerOperationQueueName];
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Folds" withExtension:@"momd"];
    
    [self setManagedObjectModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL]];
    [self setPersistentStoreCoordinator:[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel]];
    [self.persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL];
    [self setManagedObjectContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType]];
    [self.managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    [self.managedObjectContext setUndoManager:nil];
    
    [self scanFolds];
    
    return self;
}

- (void)scanFolds {
    if (self.isScanning) {
        [self setScanPending:YES];
        return;
    }
    
    [self setScanning:YES];
    
    WCScanFoldsOperation *operation = [[WCScanFoldsOperation alloc] initWithFoldScanner:self];
    
    __block typeof (self) blockSelf = self;
    
    [operation setCompletionBlock:^{
        [blockSelf setScanning:NO];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:WCFoldScannerDidFinishScanningFoldsNotification object:blockSelf];
        
        if (blockSelf.scanPending) {
            [blockSelf setScanPending:NO];
            [blockSelf scanFolds];
        }
    }];
    
    [self.operationQueue addOperation:operation];
}

- (NSArray *)foldsSortedByLocation {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Fold"];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.fold == nil"]];
    [fetchRequest setSortDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"location" ascending:YES] ]];
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
}

@end
