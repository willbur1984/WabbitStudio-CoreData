// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Placeholder.h instead.

#import <CoreData/CoreData.h>


extern const struct PlaceholderAttributes {
	 NSString *choices;
	 NSString *isPlaceholder;
	 NSString *name;
} PlaceholderAttributes;

extern const struct PlaceholderRelationships {
	 NSString *completion;
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




@property (nonatomic, retain) NSString* choices;


//- (BOOL)validateChoices:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber* isPlaceholder;


@property BOOL isPlaceholderValue;
- (BOOL)isPlaceholderValue;
- (void)setIsPlaceholderValue:(BOOL)value_;

//- (BOOL)validateIsPlaceholder:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, retain) Completion* completion;

//- (BOOL)validateCompletion:(id*)value_ error:(NSError**)error_;





@end

@interface _Placeholder (CoreDataGeneratedAccessors)

@end

@interface _Placeholder (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveChoices;
- (void)setPrimitiveChoices:(NSString*)value;




- (NSNumber*)primitiveIsPlaceholder;
- (void)setPrimitiveIsPlaceholder:(NSNumber*)value;

- (BOOL)primitiveIsPlaceholderValue;
- (void)setPrimitiveIsPlaceholderValue:(BOOL)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (Completion*)primitiveCompletion;
- (void)setPrimitiveCompletion:(Completion*)value;


@end
