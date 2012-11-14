#import "Symbol.h"
#import "FileContainer.h"
#import "WCSymbolImageManager.h"

@implementation Symbol

- (NSImage *)image {
    return [[WCSymbolImageManager sharedManager] imageForSymbol:self];
}
- (NSString *)path {
    return self.fileContainer.path;
}
- (NSString *)fileUUID; {
    return self.fileContainer.uuid;
}

@end
