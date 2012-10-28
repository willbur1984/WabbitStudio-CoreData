//
//  WCCompletionsImageManager.m
//  WabbitStudio
//
//  Created by William Towe on 10/13/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCCompletionsImageManager.h"
#import "WCDefines.h"
#import "WCGeometry.h"
#import "NSBezierPath+StrokeExtensions.h"

@interface WCCompletionsImageManager ()
@property (strong,nonatomic) NSCache *imageCache;
@end

@implementation WCCompletionsImageManager

- (id)init {
    if (!(self = [super init]))
        return nil;
    
    [self setImageCache:[[NSCache alloc] init]];
    [self.imageCache setName:@"org.revsoft.completion-image.cache"];
    
    return self;
}

+ (WCCompletionsImageManager *)sharedManager; {
    static id retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[[self class] alloc] init];
    });
    return retval;
}

- (NSImage *)imageForCompletion:(Completion *)completion; {
    return [self imageForCompletionType:completion.type.intValue];
}
- (NSImage *)imageForCompletionType:(CompletionType)completionType; {
    NSImage *retval = [self.imageCache objectForKey:@(completionType)];
    
    if (!retval) {
        retval = [[NSImage alloc] initWithSize:WC_NSSmallSize];
        
        NSColor *color;
        NSAttributedString *letter;
        
        switch (completionType) {
            case CompletionTypeConditionalRegister:
                color = [NSColor cyanColor];
                letter = [[NSAttributedString alloc] initWithString:@"c" attributes:@{ NSFontAttributeName : [NSFont userFixedPitchFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]], NSForegroundColorAttributeName : [NSColor whiteColor] }];
                break;
            case CompletionTypeDirective:
                color = [NSColor orangeColor];
                letter = [[NSAttributedString alloc] initWithString:@"d" attributes:@{ NSFontAttributeName : [NSFont userFixedPitchFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]], NSForegroundColorAttributeName : [NSColor whiteColor] }];
                break;
            case CompletionTypeOperationalCode:
                color = [NSColor blueColor];
                letter = [[NSAttributedString alloc] initWithString:@"o" attributes:@{ NSFontAttributeName : [NSFont userFixedPitchFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]], NSForegroundColorAttributeName : [NSColor whiteColor] }];
                break;
            case CompletionTypePreProcessor:
                color = [NSColor brownColor];
                letter = [[NSAttributedString alloc] initWithString:@"#" attributes:@{ NSFontAttributeName : [NSFont userFixedPitchFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]], NSForegroundColorAttributeName : [NSColor whiteColor] }];
                break;
            case CompletionTypeRegister:
                color = [NSColor redColor];
                letter = [[NSAttributedString alloc] initWithString:@"r" attributes:@{ NSFontAttributeName : [NSFont userFixedPitchFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]], NSForegroundColorAttributeName : [NSColor whiteColor] }];
                break;
            default:
                break;
        }
        
        [retval lockFocus];
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, retval.size.width, retval.size.height) xRadius:3 yRadius:3];
        
        [color setFill];
        [path fill];
        
        [[NSColor darkGrayColor] setStroke];
        [path strokeInside];
        
        [letter drawInRect:WC_NSRectCenter(NSMakeRect(0, 0, letter.size.width, letter.size.height), NSMakeRect(0, 0, retval.size.width, retval.size.height))];
        
        [retval unlockFocus];
        
        [self.imageCache setObject:retval forKey:@(completionType)];
    }
    
    return retval;
}

@end
