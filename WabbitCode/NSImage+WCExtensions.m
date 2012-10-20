//
//  NSImage+WCExtensions.m
//  WabbitStudio
//
//  Created by William Towe on 10/19/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "NSImage+WCExtensions.h"

#import <QuartzCore/QuartzCore.h>

@implementation NSImage (WCExtensions)

- (NSImage *)WC_unsavedImageIcon; {
    return [self WC_imageWithBrightnessAdjustment:-0.5];
}
- (NSImage *)WC_imageWithBrightnessAdjustment:(CGFloat)adjustment; {
    NSImage *retval = [[NSImage alloc] initWithSize:self.size];
    NSArray *reps = [NSBitmapImageRep imageRepsWithData:self.TIFFRepresentation];
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
    
    for (NSBitmapImageRep *rep in reps) {
        CIImage *input = [[CIImage alloc] initWithBitmapImageRep:rep];
        
        [filter setDefaults];
        [filter setValue:input forKey:kCIInputImageKey];
        [filter setValue:@(adjustment) forKey:kCIInputBrightnessKey];
        
        CIImage *output = [filter valueForKey:kCIOutputImageKey];
        
        [retval addRepresentation:[NSCIImageRep imageRepWithCIImage:output]];
    }
    
    return retval;
}

@end
