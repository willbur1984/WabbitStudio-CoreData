#import "File.h"

@implementation File

- (NSImage *)image {
    return [[NSWorkspace sharedWorkspace] iconForFile:self.path];
}
- (NSString *)fileUUID; {
    return self.uuid;
}

@end
