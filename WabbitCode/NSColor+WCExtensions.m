//
//  NSColor+WCExtensions.m
//  WabbitStudio
//
//  Created by William Towe on 9/18/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "NSColor+WCExtensions.h"

@implementation NSColor (WCExtensions)

/*
 Code modified from a category found at:
 http://www.karelia.com/cocoa_legacy/Foundation_Categories/NSColor__Instantiat.m
 */

+ (NSColor *)WC_colorWithHexadecimalString:(NSString *)string {
    if (string.length > 0) {
        string = [string stringByReplacingOccurrencesOfString:@"#" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, string.length)];
        
        static NSCache *colorCache;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            colorCache = [[NSCache alloc] init];
            
            [colorCache setName:@"org.revsoft.color.cache"];
        });
        
        NSColor *retval = [colorCache objectForKey:string];
        
        if (!retval) {
            NSScanner *scanner = [NSScanner scannerWithString:string];
            
            unsigned int value;
            
            if (![scanner scanHexInt:&value])
                return nil;
            
            unsigned char red = (unsigned char)(value >> 16);
            unsigned char green = (unsigned char)(value >> 8);
            unsigned char blue = (unsigned char)value;
            
            retval = [NSColor colorWithCalibratedRed:((CGFloat)red/0xff) green:((CGFloat)green/0xff) blue:((CGFloat)blue/0xff) alpha:1];
            
            [colorCache setObject:retval forKey:string];
        }
        
        return retval;
    }
    return nil;
}

- (CGColorRef)WC_CGColorCreate; {
    NSColor *color = [self colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    
    CGFloat components[4];
    
    [color getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef retval = CGColorCreate(colorSpace, components);
    
    CGColorSpaceRelease(colorSpace);
    
    return retval;
}
- (NSColor *)WC_colorWithBrightnessAdjustment:(CGFloat)adjustment; {
    NSColor *color = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
    return [NSColor colorWithCalibratedHue:color.hueComponent saturation:color.saturationComponent brightness:(color.brightnessComponent - adjustment) alpha:color.alphaComponent];
}

@end
