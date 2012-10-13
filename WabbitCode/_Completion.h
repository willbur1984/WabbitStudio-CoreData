// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Completion.h instead.

#import <CoreData/CoreData.h>


extern const struct CompletionAttributes {
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *priority;
	__unsafe_unretained NSString *type;
} CompletionAttributes;

extern const struct CompletionRelationships {
	__unsafe_unretained NSString *placeholders;
} CompletionRelationships;

extern const struct CompletionFetchedProperties {
} CompletionFetchedProperties;

@class Placeholder;





@interface CompletionID : NSManagedObjectID {}
@end

@interface _Completion : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CompletionID*)objectID;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* priority;


@property int64_t priorityValue;
- (int64_t)priorityValue;
- (void)setPriorityValue:(int64_t)value_;

//- (BOOL)validatePriority:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* type;


@property int16_t typeValue;
- (int16_t)typeValue;
- (void)setTypeValue:(int16_t)value_;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSOrderedSet* placeholders;

- (NSMutableOrderedSet*)placeholdersSet;





@end

@interface _Completion (CoreDataGeneratedAccessors)

- (void)addPlaceholders:(NSOrderedSet*)value_;
- (void)removePlaceholders:(NSOrderedSet*)value_;
- (void)addPlaceholdersObject:(Placeholder*)value_;
- (void)removePlaceholdersObject:(Placeholder*)value_;

@end

@interface _Completion (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitivePriority;
- (void)setPrimitivePriority:(NSNumber*)value;

- (int64_t)primitivePriorityValue;
- (void)setPrimitivePriorityValue:(int64_t)value_;




- (NSNumber*)primitiveType;
- (void)setPrimitiveType:(NSNumber*)value;

- (int16_t)primitiveTypeValue;
- (void)setPrimitiveTypeValue:(int16_t)value_;





- (NSMutableOrderedSet*)primitivePlaceholders;
- (void)setPrimitivePlaceholders:(NSMutableOrderedSet*)value;


@end
