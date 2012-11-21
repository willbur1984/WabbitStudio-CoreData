#import "_Completion.h"
#import "WCCompletionItem.h"

typedef NS_ENUM(int16_t, CompletionType) {
    CompletionTypeOperationalCode = 0,
    CompletionTypeRegister,
    CompletionTypeConditionalRegister,
    CompletionTypeDirective,
    CompletionTypePreProcessor
};

@interface Completion : _Completion <WCCompletionItemDataSource> {}
// Custom logic goes here.
@end
