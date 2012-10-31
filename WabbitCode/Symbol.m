//
//  Symbol.m
//  WabbitStudio
//
//  Created by William Towe on 9/24/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//

#import "Symbol.h"
#import "FileContainer.h"
#import "WCSymbolImageManager.h"


@implementation Symbol

- (NSImage *)image {
    return [[WCSymbolImageManager sharedManager] imageForSymbol:self];
}
- (NSString *)path {
    return self.file.path;
}


@dynamic location;
@dynamic name;
@dynamic range;
@dynamic type;
@dynamic lineNumber;
@dynamic file;

@end
