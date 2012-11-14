#import "_Symbol.h"
#import "WCCompletionItem.h"
#import "WCOpenQuicklyItem.h"

typedef NS_ENUM(NSInteger, SymbolType) {
    SymbolTypeLabel = 1,
    SymbolTypeEquate,
    SymbolTypeDefine,
    SymbolTypeMacro
};

@interface Symbol : _Symbol <WCCompletionItemDataSource,WCOpenQuicklyDataSource> {}
// Custom logic goes here.
@end
