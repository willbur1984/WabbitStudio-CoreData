// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FileContainer.h instead.

#import <CoreData/CoreData.h>


extern const struct FileContainerAttributes {
	__unsafe_unretained NSString *path;
	__unsafe_unretained NSString *uuid;
} FileContainerAttributes;

extern const struct FileContainerRelationships {
	__unsafe_unretained NSString *calledLabels;
	__unsafe_unretained NSString *symbols;
} FileContainerRelationships;

extern const struct FileContainerFetchedProperties {
} FileContainerFetchedProperties;

@class CalledLabel;
@class Symbol;




@interface FileContainerID : NSManagedObjectID {}
@end

@interface _FileContainer : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (FileContainerID*)objectID;




@property (nonatomic, strong) NSString* path;


//- (BOOL)validatePath:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* uuid;


//- (BOOL)validateUuid:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet* calledLabels;

- (NSMutableSet*)calledLabelsSet;




@property (nonatomic, strong) NSSet* symbols;

- (NSMutableSet*)symbolsSet;





@end

@interface _FileContainer (CoreDataGeneratedAccessors)

- (void)addCalledLabels:(NSSet*)value_;
- (void)removeCalledLabels:(NSSet*)value_;
- (void)addCalledLabelsObject:(CalledLabel*)value_;
- (void)removeCalledLabelsObject:(CalledLabel*)value_;

- (void)addSymbols:(NSSet*)value_;
- (void)removeSymbols:(NSSet*)value_;
- (void)addSymbolsObject:(Symbol*)value_;
- (void)removeSymbolsObject:(Symbol*)value_;

@end

@interface _FileContainer (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitivePath;
- (void)setPrimitivePath:(NSString*)value;




- (NSString*)primitiveUuid;
- (void)setPrimitiveUuid:(NSString*)value;





- (NSMutableSet*)primitiveCalledLabels;
- (void)setPrimitiveCalledLabels:(NSMutableSet*)value;



- (NSMutableSet*)primitiveSymbols;
- (void)setPrimitiveSymbols:(NSMutableSet*)value;


@end
