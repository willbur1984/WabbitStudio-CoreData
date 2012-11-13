#import "_Symbol.h"
#import "WCCompletionItem.h"

typedef NS_ENUM(NSInteger, SymbolType) {
    SymbolTypeLabel = 1,
    SymbolTypeEquate,
    SymbolTypeDefine,
    SymbolTypeMacro
};

@interface Symbol : _Symbol <WCCompletionItemDataSource> {}
// Custom logic goes here.
@end
