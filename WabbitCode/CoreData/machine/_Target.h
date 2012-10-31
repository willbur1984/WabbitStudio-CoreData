// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Target.h instead.

#import <CoreData/CoreData.h>
#import "Item.h"

extern const struct TargetAttributes {
	__unsafe_unretained NSString *active;
	__unsafe_unretained NSString *generateCodeListing;
	__unsafe_unretained NSString *generateLabelFile;
	__unsafe_unretained NSString *outputType;
	__unsafe_unretained NSString *symbolsAreCaseSensitive;
} TargetAttributes;

extern const struct TargetRelationships {
	__unsafe_unretained NSString *defines;
	__unsafe_unretained NSString *includes;
	__unsafe_unretained NSString *project;
} TargetRelationships;

extern const struct TargetFetchedProperties {
} TargetFetchedProperties;

@class TargetDefine;
@class TargetInclude;
@class Project;







@interface TargetID : NSManagedObjectID {}
@end

@interface _Target : Item {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TargetID*)objectID;




@property (nonatomic, strong) NSNumber* active;


@property BOOL activeValue;
- (BOOL)activeValue;
- (void)setActiveValue:(BOOL)value_;

//- (BOOL)validateActive:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* generateCodeListing;


@property BOOL generateCodeListingValue;
- (BOOL)generateCodeListingValue;
- (void)setGenerateCodeListingValue:(BOOL)value_;

//- (BOOL)validateGenerateCodeListing:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* generateLabelFile;


@property BOOL generateLabelFileValue;
- (BOOL)generateLabelFileValue;
- (void)setGenerateLabelFileValue:(BOOL)value_;

//- (BOOL)validateGenerateLabelFile:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* outputType;


@property int16_t outputTypeValue;
- (int16_t)outputTypeValue;
- (void)setOutputTypeValue:(int16_t)value_;

//- (BOOL)validateOutputType:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* symbolsAreCaseSensitive;


@property BOOL symbolsAreCaseSensitiveValue;
- (BOOL)symbolsAreCaseSensitiveValue;
- (void)setSymbolsAreCaseSensitiveValue:(BOOL)value_;

//- (BOOL)validateSymbolsAreCaseSensitive:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSOrderedSet* defines;

- (NSMutableOrderedSet*)definesSet;




@property (nonatomic, strong) NSOrderedSet* includes;

- (NSMutableOrderedSet*)includesSet;




@property (nonatomic, strong) Project* project;

//- (BOOL)validateProject:(id*)value_ error:(NSError**)error_;





@end

@interface _Target (CoreDataGeneratedAccessors)

- (void)addDefines:(NSOrderedSet*)value_;
- (void)removeDefines:(NSOrderedSet*)value_;
- (void)addDefinesObject:(TargetDefine*)value_;
- (void)removeDefinesObject:(TargetDefine*)value_;

- (void)addIncludes:(NSOrderedSet*)value_;
- (void)removeIncludes:(NSOrderedSet*)value_;
- (void)addIncludesObject:(TargetInclude*)value_;
- (void)removeIncludesObject:(TargetInclude*)value_;

@end

@interface _Target (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveActive;
- (void)setPrimitiveActive:(NSNumber*)value;

- (BOOL)primitiveActiveValue;
- (void)setPrimitiveActiveValue:(BOOL)value_;




- (NSNumber*)primitiveGenerateCodeListing;
- (void)setPrimitiveGenerateCodeListing:(NSNumber*)value;

- (BOOL)primitiveGenerateCodeListingValue;
- (void)setPrimitiveGenerateCodeListingValue:(BOOL)value_;




- (NSNumber*)primitiveGenerateLabelFile;
- (void)setPrimitiveGenerateLabelFile:(NSNumber*)value;

- (BOOL)primitiveGenerateLabelFileValue;
- (void)setPrimitiveGenerateLabelFileValue:(BOOL)value_;




- (NSNumber*)primitiveOutputType;
- (void)setPrimitiveOutputType:(NSNumber*)value;

- (int16_t)primitiveOutputTypeValue;
- (void)setPrimitiveOutputTypeValue:(int16_t)value_;




- (NSNumber*)primitiveSymbolsAreCaseSensitive;
- (void)setPrimitiveSymbolsAreCaseSensitive:(NSNumber*)value;

- (BOOL)primitiveSymbolsAreCaseSensitiveValue;
- (void)setPrimitiveSymbolsAreCaseSensitiveValue:(BOOL)value_;





- (NSMutableOrderedSet*)primitiveDefines;
- (void)setPrimitiveDefines:(NSMutableOrderedSet*)value;



- (NSMutableOrderedSet*)primitiveIncludes;
- (void)setPrimitiveIncludes:(NSMutableOrderedSet*)value;



- (Project*)primitiveProject;
- (void)setPrimitiveProject:(Project*)value;


@end
