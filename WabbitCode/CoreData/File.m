#import "File.h"

@implementation File

- (void)sortChildrenUsingComparator:(NSComparator)comparator recursively:(BOOL)recursively; {
    if (self.files.count > 0)
        [self.filesSet sortUsingComparator:comparator];
    
    if (recursively) {
        for (File *file in self.files) {
            if (file.files.count > 0)
                [file sortChildrenUsingComparator:comparator recursively:recursively];
        }
    }
}

- (NSString *)directoryPath {
    if (self.project)
        return self.path.stringByDeletingLastPathComponent;
    else if (self.isGroupValue)
        return self.path;
    else
        return self.file.directoryPath;
}

- (NSArray *)flattenedFiles {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:self.entity.name];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.isGroup == FALSE AND (self.file == %@ OR self.file IN %@)",self,self.files]];
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
}
- (NSArray *)flattenedFilesInclusive {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:self.entity.name];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.isGroup == FALSE AND (self == %@ OR self.file == %@ OR self.file IN %@)",self,self,self.files]];
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
}
- (NSArray *)flattenedFilesAndGroups {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:self.entity.name];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self.file == %@ OR self.file IN %@",self,self.files]];
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
}
- (NSArray *)flattenedFilesAndGroupsInclusive {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:self.entity.name];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"self == %@ OR self.file == %@ OR self.file IN %@",self,self,self.files]];
    
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:NULL];
}

- (NSImage *)image {
    return [[NSWorkspace sharedWorkspace] iconForFileType:self.uti];
}
- (NSString *)fileUUID; {
    return self.uuid;
}

@end
