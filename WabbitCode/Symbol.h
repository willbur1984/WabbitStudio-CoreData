//
//  Symbol.h
//  WabbitStudio
//
//  Created by William Towe on 9/22/12.
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

@interface Symbol : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * range;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * location;

@end
