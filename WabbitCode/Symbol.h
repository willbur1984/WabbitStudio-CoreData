//
//  Symbol.h
//  WabbitStudio
//
//  Created by William Towe on 9/24/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    SymbolTypeLabel,
    SymbolTypeEquate,
    SymbolTypeDefine,
    SymbolTypeMacro
} SymbolType;

@class File;

@interface Symbol : NSManagedObject

@property (nonatomic, retain) NSNumber * location;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * range;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * lineNumber;
@property (nonatomic, retain) File *file;

@end
