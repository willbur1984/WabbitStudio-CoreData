// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Label.h instead.

#import <CoreData/CoreData.h>
#import "Symbol.h"

extern const struct LabelAttributes {
	__unsafe_unretained NSString *isCalled;
} LabelAttributes;

extern const struct LabelRelationships {
} LabelRelationships;

extern const struct LabelFetchedProperties {
} LabelFetchedProperties;




@interface LabelID : NSManagedObjectID {}
@end

@interface _Label : Symbol {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (LabelID*)objectID;




@property (nonatomic, strong) NSNumber* isCalled;


@property BOOL isCalledValue;
- (BOOL)isCalledValue;
- (void)setIsCalledValue:(BOOL)value_;

//- (BOOL)validateIsCalled:(id*)value_ error:(NSError**)error_;






@end

@interface _Label (CoreDataGeneratedAccessors)

@end

@interface _Label (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveIsCalled;
- (void)setPrimitiveIsCalled:(NSNumber*)value;

- (BOOL)primitiveIsCalledValue;
- (void)setPrimitiveIsCalledValue:(BOOL)value_;




@end
