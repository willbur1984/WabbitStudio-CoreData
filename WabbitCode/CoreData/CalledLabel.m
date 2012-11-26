#import "CalledLabel.h"

@implementation CalledLabel

- (int64_t)displayLineNumber {
    return (self.lineNumber.longLongValue + 1);
}

@end
