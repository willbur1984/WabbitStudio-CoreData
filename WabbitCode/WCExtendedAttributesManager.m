//
//  WCExtendedAttributesManager.m
//  WabbitStudio
//
//  Created by William Towe on 10/6/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "WCExtendedAttributesManager.h"
#import "WCDefines.h"

#include <sys/xattr.h>
#include <sys/errno.h>

NSString *const WCExtendedAttributesManagerAppleTextEncodingAttributeName = @"com.apple.TextEncoding";

static NSDictionary *kErrnoCodeToErrorString;

@implementation WCExtendedAttributesManager

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kErrnoCodeToErrorString = @{
        @(ENOATTR) : @"The extended attribute does not exist.",
        @(ENOTSUP) : @"The file system does not support extended attributes or has the feature disabled.",
        @(ERANGE) : @"value (as indicated by size) is too small to hold the extended attribute data.",
        @(EPERM) : @"The named attribute is not permitted for this type of object.",
        @(EINVAL) : @"name is invalid or options has an unsupported bit set.",
        @(EISDIR) : @"path or fd do not refer to a regular file and the attribute in question is only applicable to files.",
        @(ENOTDIR) : @"A component of path 's prefix is not a directory.",
        @(ENAMETOOLONG) : @"The length of name exceeds XATTR_MAXNAMELEN UTF-8 bytes, or a component of path exceeds NAME_MAX characters, or the entire path exceeds PATH_MAX characters.",
        @(EACCES) : @"Search permission is denied for a component of path or the attribute is not allowed to be read (e.g. an ACL prohibits reading the attributes of this file).",
        @(ELOOP) : @"Too many symbolic links were encountered in translating the pathname.",
        @(EFAULT) : @"path or name points to an invalid address.",
        @(EIO) : @"An I/O error occurred while reading from or writing to the file system."
        };
    });
}

+ (WCExtendedAttributesManager *)sharedManager; {
    static id retval;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        retval = [[[self class] alloc] init];
    });
    return retval;
}

- (NSString *)stringForAttribute:(NSString *)attribute atURL:(NSURL *)url; {
    return [self stringForAttribute:attribute atPath:url.path];
}
- (void)setString:(NSString *)string forAttribute:(NSString *)attribute atURL:(NSURL *)url; {
    [self setString:string forAttribute:attribute atPath:url.path];
}

- (NSString *)stringForAttribute:(NSString *)attribute atPath:(NSString *)path; {
    NSData *data = [self dataForAttribute:attribute atPath:path];
    
    if (!data)
        return nil;
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
- (void)setString:(NSString *)string forAttribute:(NSString *)attribute atPath:(NSString *)path; {
    [self setData:[string dataUsingEncoding:NSUTF8StringEncoding] forAttribute:attribute atPath:path];
}

- (id)objectForAttribute:(NSString *)attribute atURL:(NSURL *)url; {
    return [self objectForAttribute:attribute atPath:url.path];
}
- (void)setObject:(id)object forAttribute:(NSString *)attribute atURL:(NSURL *)url; {
    [self setObject:object forAttribute:attribute atPath:url.path];
}

- (id)objectForAttribute:(NSString *)attribute atPath:(NSString *)path; {
    NSData *data = [self dataForAttribute:attribute atPath:path];
    
    if (!data)
        return nil;
    
    NSError *outError;
    id retval = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&outError];
    
    if (!retval)
        WCLogObject(outError);
    
    return retval;
}
- (void)setObject:(id)object forAttribute:(NSString *)attribute atPath:(NSString *)path; {
    NSError *outError;
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:object format:NSPropertyListXMLFormat_v1_0 options:0 error:&outError];
    
    if (!data)
        WCLogObject(outError);
    
    [self setData:data forAttribute:attribute atPath:path];
}

- (NSData *)dataForAttribute:(NSString *)attribute atURL:(NSURL *)url; {
    return [self dataForAttribute:attribute atPath:url.path];
}
- (void)setData:(NSData *)data forAttribute:(NSString *)attribute atURL:(NSURL *)url; {
    [self setData:data forAttribute:attribute atPath:url.path];
}

- (NSData *)dataForAttribute:(NSString *)attribute atPath:(NSString *)path; {
    WCAssert(attribute.length,@"attribute cannot be nil!");
    WCAssert(path.length,@"path cannot be nil!");
    
    size_t length = getxattr(path.fileSystemRepresentation, attribute.UTF8String, NULL, ULONG_MAX, 0, 0);
    
    if (length == ULONG_MAX || length == -1) {
        WCLog(@"unable to retrieve attribute %@ at path %@, error %i, %@",attribute,path,errno,[kErrnoCodeToErrorString objectForKey:@(errno)]);
        return nil;
    }
    
    NSMutableData *data = [NSMutableData dataWithLength:length];
    
    getxattr(path.fileSystemRepresentation, attribute.UTF8String, data.mutableBytes, data.length, 0, 0);
    
    return data;
}
- (void)setData:(NSData *)data forAttribute:(NSString *)attribute atPath:(NSString *)path; {
    WCAssert(data,@"data cannot be nil!");
    WCAssert(attribute.length,@"attribute cannot be nil!");
    WCAssert(path.length,@"path cannot be nil!");
    
    int retval = setxattr(path.fileSystemRepresentation, attribute.UTF8String, data.bytes, data.length, 0, 0);
    
    if (retval == -1) {
        WCLog(@"unable to set data for attribute %@ at path %@, error %i, %@",attribute,path,errno,[kErrnoCodeToErrorString objectForKey:@(errno)]);
    }
}

- (void)removeAttribute:(NSString *)attribute atURL:(NSURL *)url; {
    [self removeAttribute:attribute atPath:url.path];
}
- (void)removeAttribute:(NSString *)attribute atPath:(NSString *)path; {
    WCAssert(attribute.length,@"attribute cannot be nil!");
    WCAssert(path.length,@"path cannot be nil!");
    
    removexattr(path.fileSystemRepresentation, attribute.UTF8String, 0);
}

- (NSArray *)attributesAtURL:(NSURL *)url; {
    return [self attributesAtPath:url.path];
}
- (NSArray *)attributesAtPath:(NSString *)path; {
    size_t length = listxattr(path.fileSystemRepresentation, NULL, ULONG_MAX, 0);
    
    if (length == ULONG_MAX || length == -1) {
        WCLog(@"unable to retrieve attributes at path %@, error %i, %@",path,errno,[kErrnoCodeToErrorString objectForKey:@(errno)]);
        return nil;
    }
    
    NSMutableArray *retval = [NSMutableArray arrayWithCapacity:0];
    NSMutableData *data = [NSMutableData dataWithLength:length];
    
    listxattr(path.fileSystemRepresentation, data.mutableBytes, data.length, 0);
    
    size_t charIndex, startIndex;
    
    for (charIndex=0, startIndex=0; charIndex<length; charIndex++) {
        if (((char *)data.mutableBytes)[charIndex] == 0) {
            NSString *string = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(startIndex, charIndex - startIndex)] encoding:NSUTF8StringEncoding];
            
            [retval addObject:string];
            
            startIndex = charIndex;
        }
    }
    
    return retval;
}

@end
