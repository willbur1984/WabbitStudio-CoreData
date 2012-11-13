// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Define.h instead.

#import <CoreData/CoreData.h>
#import "Symbol.h"

extern const struct DefineAttributes {
	__unsafe_unretained NSString *arguments;
	__unsafe_unretained NSString *value;
} DefineAttributes;

extern const struct DefineRelationships {
} DefineRelationships;

extern const struct DefineFetchedProperties {
} DefineFetchedProperties;





@interface DefineID : NSManagedObjectID {}
@end

@interface _Define : Symbol {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (DefineID*)objectID;




@property (nonatomic, strong) NSString* arguments;


//- (BOOL)validateArguments:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* value;


//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;






@end

@interface _Define (CoreDataGeneratedAccessors)

@end

@interface _Define (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveArguments;
- (void)setPrimitiveArguments:(NSString*)value;




- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;




@end
