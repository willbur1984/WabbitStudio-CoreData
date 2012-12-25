#import "_File.h"
#import "WCOpenQuicklyItem.h"

@interface File : _File <WCOpenQuicklyDataSource> {}

@property (readonly,nonatomic) NSString *directoryPath;

@property (readonly,nonatomic) NSArray *flattenedFiles;
@property (readonly,nonatomic) NSArray *flattenedFilesInclusive;
@property (readonly,nonatomic) NSArray *flattenedFilesAndGroups;
@property (readonly,nonatomic) NSArray *flattenedFilesAndGroupsInclusive;

- (void)sortChildrenUsingComparator:(NSComparator)comparator recursively:(BOOL)recursively;

@end
