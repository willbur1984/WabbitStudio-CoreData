// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Macro.h instead.

#import <CoreData/CoreData.h>
#import "Symbol.h"

extern const struct MacroAttributes {
	__unsafe_unretained NSString *arguments;
	__unsafe_unretained NSString *value;
} MacroAttributes;

extern const struct MacroRelationships {
} MacroRelationships;

extern const struct MacroFetchedProperties {
} MacroFetchedProperties;





@interface MacroID : NSManagedObjectID {}
@end

@interface _Macro : Symbol {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MacroID*)objectID;




@property (nonatomic, strong) NSString* arguments;


//- (BOOL)validateArguments:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* value;


//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;






@end

@interface _Macro (CoreDataGeneratedAccessors)

@end

@interface _Macro (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveArguments;
- (void)setPrimitiveArguments:(NSString*)value;




- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;




@end
