// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Equate.h instead.

#import <CoreData/CoreData.h>
#import "Symbol.h"

extern const struct EquateAttributes {
	__unsafe_unretained NSString *value;
} EquateAttributes;

extern const struct EquateRelationships {
} EquateRelationships;

extern const struct EquateFetchedProperties {
} EquateFetchedProperties;




@interface EquateID : NSManagedObjectID {}
@end

@interface _Equate : Symbol {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (EquateID*)objectID;




@property (nonatomic, strong) NSString* value;


//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;






@end

@interface _Equate (CoreDataGeneratedAccessors)

@end

@interface _Equate (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;




@end
