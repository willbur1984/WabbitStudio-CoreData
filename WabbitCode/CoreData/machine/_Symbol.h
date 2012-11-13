// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Symbol.h instead.

#import <CoreData/CoreData.h>


extern const struct SymbolAttributes {
	__unsafe_unretained NSString *lineNumber;
	__unsafe_unretained NSString *location;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *range;
	__unsafe_unretained NSString *type;
} SymbolAttributes;

extern const struct SymbolRelationships {
	__unsafe_unretained NSString *fileContainer;
} SymbolRelationships;

extern const struct SymbolFetchedProperties {
} SymbolFetchedProperties;

@class FileContainer;







@interface SymbolID : NSManagedObjectID {}
@end

@interface _Symbol : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SymbolID*)objectID;




@property (nonatomic, strong) NSNumber* lineNumber;


@property int64_t lineNumberValue;
- (int64_t)lineNumberValue;
- (void)setLineNumberValue:(int64_t)value_;

//- (BOOL)validateLineNumber:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* location;


@property int64_t locationValue;
- (int64_t)locationValue;
- (void)setLocationValue:(int64_t)value_;

//- (BOOL)validateLocation:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* range;


//- (BOOL)validateRange:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* type;


@property int16_t typeValue;
- (int16_t)typeValue;
- (void)setTypeValue:(int16_t)value_;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) FileContainer* fileContainer;

//- (BOOL)validateFileContainer:(id*)value_ error:(NSError**)error_;





@end

@interface _Symbol (CoreDataGeneratedAccessors)

@end

@interface _Symbol (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveLineNumber;
- (void)setPrimitiveLineNumber:(NSNumber*)value;

- (int64_t)primitiveLineNumberValue;
- (void)setPrimitiveLineNumberValue:(int64_t)value_;




- (NSNumber*)primitiveLocation;
- (void)setPrimitiveLocation:(NSNumber*)value;

- (int64_t)primitiveLocationValue;
- (void)setPrimitiveLocationValue:(int64_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveRange;
- (void)setPrimitiveRange:(NSString*)value;




- (NSNumber*)primitiveType;
- (void)setPrimitiveType:(NSNumber*)value;

- (int16_t)primitiveTypeValue;
- (void)setPrimitiveTypeValue:(int16_t)value_;





- (FileContainer*)primitiveFileContainer;
- (void)setPrimitiveFileContainer:(FileContainer*)value;


@end
