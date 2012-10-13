#import "Completion.h"
#import "WCCompletionsImageManager.h"

@implementation Completion

// Custom logic goes here.
- (NSImage *)image {
    return [[WCCompletionsImageManager sharedManager] imageForCompletion:self];
}

@end
