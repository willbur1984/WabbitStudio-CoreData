#import "_File.h"
#import "WCOpenQuicklyItem.h"

@interface File : _File <WCOpenQuicklyDataSource> {}

@property (readonly,nonatomic) NSArray *flattenedFiles;
@property (readonly,nonatomic) NSArray *flattenedFilesInclusive;

- (void)sortChildrenUsingComparator:(NSComparator)comparator recursively:(BOOL)recursively;

@end
