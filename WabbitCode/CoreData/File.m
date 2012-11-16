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

- (NSImage *)image {
    return [[NSWorkspace sharedWorkspace] iconForFile:self.path];
}
- (NSString *)fileUUID; {
    return self.uuid;
}

@end
