// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TargetInclude.h instead.

#import <CoreData/CoreData.h>
#import "Item.h"

extern const struct TargetIncludeAttributes {
} TargetIncludeAttributes;

extern const struct TargetIncludeRelationships {
	__unsafe_unretained NSString *file;
	__unsafe_unretained NSString *target;
} TargetIncludeRelationships;

extern const struct TargetIncludeFetchedProperties {
} TargetIncludeFetchedProperties;

@class File;
@class Target;


@interface TargetIncludeID : NSManagedObjectID {}
@end

@interface _TargetInclude : Item {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TargetIncludeID*)objectID;





@property (nonatomic, strong) File* file;

//- (BOOL)validateFile:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) Target* target;

//- (BOOL)validateTarget:(id*)value_ error:(NSError**)error_;





@end

@interface _TargetInclude (CoreDataGeneratedAccessors)

@end

@interface _TargetInclude (CoreDataGeneratedPrimitiveAccessors)



- (File*)primitiveFile;
- (void)setPrimitiveFile:(File*)value;



- (Target*)primitiveTarget;
- (void)setPrimitiveTarget:(Target*)value;


@end
