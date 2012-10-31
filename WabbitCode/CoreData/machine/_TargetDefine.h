// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TargetDefine.h instead.

#import <CoreData/CoreData.h>
#import "Item.h"

extern const struct TargetDefineAttributes {
	__unsafe_unretained NSString *value;
} TargetDefineAttributes;

extern const struct TargetDefineRelationships {
	__unsafe_unretained NSString *target;
} TargetDefineRelationships;

extern const struct TargetDefineFetchedProperties {
} TargetDefineFetchedProperties;

@class Target;



@interface TargetDefineID : NSManagedObjectID {}
@end

@interface _TargetDefine : Item {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TargetDefineID*)objectID;




@property (nonatomic, strong) NSString* value;


//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Target* target;

//- (BOOL)validateTarget:(id*)value_ error:(NSError**)error_;





@end

@interface _TargetDefine (CoreDataGeneratedAccessors)

@end

@interface _TargetDefine (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;





- (Target*)primitiveTarget;
- (void)setPrimitiveTarget:(Target*)value;


@end
