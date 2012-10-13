#import "_Completion.h"
#import "WCCompletionItem.h"

typedef enum {
    CompletionTypeOperationalCode = 0,
    CompletionTypeRegister,
    CompletionTypeConditionalRegister,
    CompletionTypeDirective,
    CompletionTypePreProcessor
} CompletionType;

@interface Completion : _Completion <WCCompletionItemDataSource> {}
// Custom logic goes here.
@end
