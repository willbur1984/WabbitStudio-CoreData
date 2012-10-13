// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Placeholder.h instead.

#import <CoreData/CoreData.h>


extern const struct PlaceholderAttributes {
	__unsafe_unretained NSString *arguments;
	__unsafe_unretained NSString *isPlaceholder;
	__unsafe_unretained NSString *name;
} PlaceholderAttributes;

extern const struct PlaceholderRelationships {
	__unsafe_unretained NSString *completion;
} PlaceholderRelationships;

extern const struct PlaceholderFetchedProperties {
} PlaceholderFetchedProperties;

@class Completion;





@interface PlaceholderID : NSManagedObjectID {}
@end

@interface _Placeholder : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PlaceholderID*)objectID;




@property (nonatomic, strong) NSString* arguments;


//- (BOOL)validateArguments:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* isPlaceholder;


@property BOOL isPlaceholderValue;
- (BOOL)isPlaceholderValue;
- (void)setIsPlaceholderValue:(BOOL)value_;

//- (BOOL)validateIsPlaceholder:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet* completion;

- (NSMutableSet*)completionSet;





@end

@interface _Placeholder (CoreDataGeneratedAccessors)

- (void)addCompletion:(NSSet*)value_;
- (void)removeCompletion:(NSSet*)value_;
- (void)addCompletionObject:(Completion*)value_;
- (void)removeCompletionObject:(Completion*)value_;

@end

@interface _Placeholder (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveArguments;
- (void)setPrimitiveArguments:(NSString*)value;




- (NSNumber*)primitiveIsPlaceholder;
- (void)setPrimitiveIsPlaceholder:(NSNumber*)value;

- (BOOL)primitiveIsPlaceholderValue;
- (void)setPrimitiveIsPlaceholderValue:(BOOL)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableSet*)primitiveCompletion;
- (void)setPrimitiveCompletion:(NSMutableSet*)value;


@end
