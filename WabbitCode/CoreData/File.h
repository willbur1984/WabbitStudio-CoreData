#import "_File.h"
#import "WCOpenQuicklyItem.h"

@interface File : _File <WCOpenQuicklyDataSource> {}

- (void)sortChildrenUsingComparator:(NSComparator)comparator recursively:(BOOL)recursively;

@end
