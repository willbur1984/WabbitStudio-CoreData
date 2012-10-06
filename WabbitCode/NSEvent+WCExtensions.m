//
//  NSEvent+WCExtensions.m
//  WabbitStudio
//
//  Created by William Towe on 10/5/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "NSEvent+WCExtensions.h"

@implementation NSEvent (WCExtensions)

- (BOOL)WC_isCommandKeyPressed; {
    return ((self.modifierFlags & NSCommandKeyMask) > 0);
}
- (BOOL)WC_isOptionKeyPressed; {
    return ((self.modifierFlags & NSAlternateKeyMask) > 0);
}
- (BOOL)WC_isControlKeyPressed; {
    return ((self.modifierFlags & NSControlKeyMask) > 0);
}
- (BOOL)WC_isShiftKeyPressed; {
    return ((self.modifierFlags & NSShiftKeyMask) > 0);
}

- (BOOL)WC_isOnlyCommandKeyPressed; {
    return ((self.modifierFlags & NSDeviceIndependentModifierFlagsMask) == NSCommandKeyMask);
}
- (BOOL)WC_isOnlyOptionKeyPressed; {
    return ((self.modifierFlags & NSDeviceIndependentModifierFlagsMask) == NSAlternateKeyMask);
}
- (BOOL)WC_isOnlyControlKeyPressed; {
    return ((self.modifierFlags & NSDeviceIndependentModifierFlagsMask) == NSControlKeyMask);
}
- (BOOL)WC_isOnlyShiftKeyPressed; {
    return ((self.modifierFlags & NSDeviceIndependentModifierFlagsMask) == NSShiftKeyMask);
}

+ (BOOL)WC_isCommandKeyPressed; {
    return [[[NSApplication sharedApplication] currentEvent] WC_isCommandKeyPressed];
}
+ (BOOL)WC_isOptionKeyPressed; {
    return [[[NSApplication sharedApplication] currentEvent] WC_isOptionKeyPressed];
}
+ (BOOL)WC_isControlKeyPressed; {
    return [[[NSApplication sharedApplication] currentEvent] WC_isControlKeyPressed];
}
+ (BOOL)WC_isShiftKeyPressed; {
    return [[[NSApplication sharedApplication] currentEvent] WC_isShiftKeyPressed];
}

+ (BOOL)WC_isOnlyCommandKeyPressed; {
    return [[[NSApplication sharedApplication] currentEvent] WC_isOnlyCommandKeyPressed];
}
+ (BOOL)WC_isOnlyOptionKeyPressed; {
    return [[[NSApplication sharedApplication] currentEvent] WC_isOnlyOptionKeyPressed];
}
+ (BOOL)WC_isOnlyControlKeyPressed; {
    return [[[NSApplication sharedApplication] currentEvent] WC_isOnlyControlKeyPressed];
}
+ (BOOL)WC_isOnlyShiftKeyPressed; {
    return [[[NSApplication sharedApplication] currentEvent] WC_isOnlyShiftKeyPressed];
}

@end
