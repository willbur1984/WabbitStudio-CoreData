//
//  WCAppController.m
//  WabbitStudio
//
//  Created by William Towe on 11/8/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCAppController.h"
#import "NSArray+WCExtensions.h"

@implementation WCAppController

+ (WCAppController *)sharedController; {
    static id retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[[self class] alloc] init];
    });
    return retval;
}

- (NSURL *)applicationSupportDirectoryURL {
    NSArray *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    
    if (URLs.count == 0) {
        NSLog(@"Unable to locate application support directory. Something is really wrong.");
        return nil;
    }
    
    NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    NSURL *directoryURL = [[URLs WC_firstObject] URLByAppendingPathComponent:applicationName];
    
    if (![directoryURL checkResourceIsReachableAndReturnError:NULL]) {
        NSError *outError;
        if (![[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&outError]) {
            NSLog(@"Unable to create application support directory for \"%@\", error %@",[[NSProcessInfo processInfo] processName],outError);
            return nil;
        }
    }
    
    return directoryURL;
}
- (NSURL *)derivedDataDirectoryURL {
    NSURL *applicationSupportDirectoryURL = self.applicationSupportDirectoryURL;
    
    if (!applicationSupportDirectoryURL)
        return nil;
    
    NSURL *directoryURL = [applicationSupportDirectoryURL URLByAppendingPathComponent:NSLocalizedString(@"DerivedData", nil)];
    
    if (![directoryURL checkResourceIsReachableAndReturnError:NULL]) {
        NSError *outError;
        if (![[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&outError]) {
            NSLog(@"Unable to create \"%@\" directory for \"%@\", error %@",directoryURL.lastPathComponent,[[NSProcessInfo processInfo] processName],outError);
            return nil;
        }
    }
    
    return directoryURL;
}

@end
