#import "Item.h"
#import "NSString+WCExtensions.h"

@implementation Item

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    [self setUuid:[NSString WC_UUIDString]];
}

@end
