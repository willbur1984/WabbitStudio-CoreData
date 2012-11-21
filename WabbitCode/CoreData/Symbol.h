#import "_Symbol.h"
#import "WCCompletionItem.h"
#import "WCOpenQuicklyItem.h"

typedef NS_ENUM(int16_t, SymbolType) {
    SymbolTypeLabel = 1,
    SymbolTypeEquate,
    SymbolTypeDefine,
    SymbolTypeMacro
};

@interface Symbol : _Symbol <WCCompletionItemDataSource,WCOpenQuicklyDataSource> {}

@property (readonly,nonatomic) int64_t displayLineNumber;

@end
