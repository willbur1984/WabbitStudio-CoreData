//
//  File.h
//  WabbitStudio
//
//  Created by William Towe on 9/24/12.
//  Copyright (c) 2012 William Towe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Symbol;

@interface File : NSManagedObject

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSSet *symbols;
@end

@interface File (CoreDataGeneratedAccessors)

- (void)addSymbolsObject:(Symbol *)value;
- (void)removeSymbolsObject:(Symbol *)value;
- (void)addSymbols:(NSSet *)values;
- (void)removeSymbols:(NSSet *)values;

@end
