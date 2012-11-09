//
//  WCSymbolIndex.m
//  WabbitStudio
//
//  Created by William Towe on 11/4/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCSymbolIndex.h"
#import "WCProjectDocument.h"
#import "WCSymbolScanner.h"
#import "WCDefines.h"

@interface WCSymbolIndex ()
@property (weak,nonatomic) WCProjectDocument *projectDocument;
@property (readwrite,strong,nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong,nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong,nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation WCSymbolIndex

- (id)initWithProjectDocument:(WCProjectDocument *)projectDocument; {
    if (!(self = [super init]))
        return nil;
    
    [self setProjectDocument:projectDocument];
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Symbols" withExtension:@"momd"];
    
    [self setManagedObjectModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL]];
    [self setPersistentStoreCoordinator:[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel]];
    [self.persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL];
    [self setManagedObjectContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType]];
    [self.managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    [self.managedObjectContext setUndoManager:nil];
    [self.managedObjectContext setMergePolicy:NSOverwriteMergePolicy];
    
    return self;
}

- (void)removeSymbolScanner:(WCSymbolScanner *)symbolScanner; {
    [symbolScanner.managedObjectContext setParentContext:nil];
}

- (NSArray *)symbolsWithName:(NSString *)name; {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Symbol"];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.name ==[cd] %@",name]];
    [fetchRequest setSortDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"type" ascending:NO] ]];
    
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

@end
