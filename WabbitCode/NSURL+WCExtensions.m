//
//  NSURL+WCExtensions.m
//  WabbitStudio
//
//  Created by William Towe on 9/26/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "NSURL+WCExtensions.h"
#import "WCDefines.h"

@implementation NSURL (WCExtensions)

- (NSImage *)WC_effectiveIcon; {
    NSImage *retval = nil;
    NSError *outError;
    
    if (![self getResourceValue:&retval forKey:NSURLEffectiveIconKey error:&outError])
        WCLogObject(outError);
    
    return retval;
}
- (NSDate *)WC_contentModificationDate; {
    NSDate *retval = nil;
    NSError *outError;
    
    if (![self getResourceValue:&retval forKey:NSURLContentModificationDateKey error:&outError])
        WCLogObject(outError);
    
    return retval;
}
- (BOOL)WC_isDirectory; {
    NSNumber *retval = nil;
    NSError *outError;
    
    if (![self getResourceValue:&retval forKey:NSURLIsDirectoryKey error:&outError])
        WCLogObject(outError);
    
    return retval.boolValue;
}
- (NSURL *)WC_parentDirectory; {
    NSURL *retval = nil;
    NSError *outError;
    
    if (![self getResourceValue:&retval forKey:NSURLParentDirectoryURLKey error:&outError])
        WCLogObject(outError);
    
    return retval;
}
- (NSString *)WC_typeIdentifier; {
    NSString *retval = nil;
    NSError *outError;
    
    if (![self getResourceValue:&retval forKey:NSURLTypeIdentifierKey error:&outError])
        WCLogObject(outError);
    
    return retval;
}

@end
