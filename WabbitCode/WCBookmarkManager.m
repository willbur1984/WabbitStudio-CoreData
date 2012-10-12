//
//  WCBookmarkManager.m
//  WabbitStudio
//
//  Created by William Towe on 10/1/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCBookmarkManager.h"
#import "Bookmark.h"
#import "WCDefines.h"

NSString *const WCBookmarkManagerDidAddBookmarkNotification = @"WCBookmarkManagerDidAddBookmarkNotification";
NSString *const WCBookmarkManagerDidRemoveBookmarkNotification = @"WCBookmarkManagerDidRemoveBookmarkNotification";

NSString *const WCBookmarkManagerBookmarkUserInfoKey = @"WCBookmarkManagerBookmarkUserInfoKey";

NSString *const WCBookmarkManagerShowRemoveAllWarningUserDefaultsKey = @"WCBookmarkManagerShowRemoveAllWarningUserDefaultsKey";

@interface WCBookmarkManager ()
@property (weak,nonatomic) NSTextStorage *textStorage;
@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong,nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong,nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation WCBookmarkManager

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithTextStorage:(NSTextStorage *)textStorage; {
    if (!(self = [super init]))
        return nil;
    
    [self setTextStorage:textStorage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textStorageDidProcessEditing:) name:NSTextStorageDidProcessEditingNotification object:textStorage];
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Bookmarks" withExtension:@"momd"];
    
    [self setManagedObjectModel:[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL]];
    [self setPersistentStoreCoordinator:[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel]];
    [self.persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL];
    [self setManagedObjectContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType]];
    [self.managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    [self.managedObjectContext setUndoManager:nil];
    
    return self;
}

- (void)addBookmarkForRange:(NSRange)range name:(NSString *)name; {
    Bookmark *bookmark = [NSEntityDescription insertNewObjectForEntityForName:@"Bookmark" inManagedObjectContext:self.managedObjectContext];
    NSRange lineRange = [self.textStorage.string lineRangeForRange:range];
    
    [bookmark setLocation:@(lineRange.location)];
    [bookmark setRange:NSStringFromRange(range)];
    [bookmark setName:(name.length) ? name : [self.textStorage.string substringWithRange:[self.textStorage.string lineRangeForRange:NSMakeRange(lineRange.location, 0)]]];
    
    NSError *outError;
    if (![self.managedObjectContext save:&outError])
        WCLogObject(outError);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WCBookmarkManagerDidAddBookmarkNotification object:self userInfo:@{ WCBookmarkManagerBookmarkUserInfoKey : bookmark }];
}
- (void)removeBookmark:(Bookmark *)bookmark; {
    WCAssert(bookmark,@"bookmark cannot be nil!");
    
    [self.managedObjectContext deleteObject:bookmark];
    
    NSError *outError;
    if (![self.managedObjectContext save:&outError])
        WCLogObject(outError);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WCBookmarkManagerDidRemoveBookmarkNotification object:self userInfo:@{ WCBookmarkManagerBookmarkUserInfoKey : bookmark }];
}
- (void)removeAllBookmarks; {
    for (Bookmark *bookmark in self.bookmarksSortedByLocation)
        [self.managedObjectContext deleteObject:bookmark];
    
    NSError *outError;
    if (![self.managedObjectContext save:&outError])
        WCLogObject(outError);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:WCBookmarkManagerDidRemoveBookmarkNotification object:self];
}

- (NSArray *)bookmarksForRange:(NSRange)range; {
    return [self bookmarksForRange:range inclusive:YES];
}
- (NSArray *)bookmarksForRange:(NSRange)range inclusive:(BOOL)inclusive; {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Bookmark"];
    
    if (inclusive)
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.location <= %lu AND self.location >= %lu",NSMaxRange(range),range.location]];
    else
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.location < %lu AND self.location > %lu",NSMaxRange(range),range.location]];
    
    [fetchRequest setSortDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"location" ascending:YES] ]];
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
}

- (NSArray *)bookmarks {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Bookmark"];
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
}
- (NSArray *)bookmarksSortedByLocation {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Bookmark"];
    
    [fetchRequest setSortDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"location" ascending:YES] ]];
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
}

- (void)_textStorageDidProcessEditing:(NSNotification *)note {
    if (!([note.object editedMask] & NSTextStorageEditedCharacters))
        return;
    
    // TODO: update bookmarks and remove if necessary
    NSRange editedRange = [note.object editedRange];
    NSInteger changeInLength = [note.object changeInLength];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Bookmark"];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.location >= %lu",editedRange.location]];
    
    for (Bookmark *bookmark in [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL])
        [bookmark setLocation:@(bookmark.location.longLongValue + changeInLength)];
}

@end
