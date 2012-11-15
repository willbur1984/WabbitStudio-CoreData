#import "Symbol.h"
#import "FileContainer.h"
#import "WCSymbolImageManager.h"

@implementation Symbol

- (int64_t)displayLineNumber {
    return (self.lineNumber.longLongValue + 1);
}

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
