// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CalledLabel.h instead.

#import <CoreData/CoreData.h>


extern const struct CalledLabelAttributes {
	__unsafe_unretained NSString *labelName;
	__unsafe_unretained NSString *lineNumber;
	__unsafe_unretained NSString *location;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *range;
} CalledLabelAttributes;

extern const struct CalledLabelRelationships {
	__unsafe_unretained NSString *fileContainer;
} CalledLabelRelationships;

extern const struct CalledLabelFetchedProperties {
} CalledLabelFetchedProperties;

@class FileContainer;







@interface CalledLabelID : NSManagedObjectID {}
@end

@interface _CalledLabel : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CalledLabelID*)objectID;




@property (nonatomic, strong) NSString* labelName;


//- (BOOL)validateLabelName:(id*)value_ error:(NSError**)error_;




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





@property (nonatomic, strong) FileContainer* fileContainer;

//- (BOOL)validateFileContainer:(id*)value_ error:(NSError**)error_;





@end

@interface _CalledLabel (CoreDataGeneratedAccessors)

@end

@interface _CalledLabel (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveLabelName;
- (void)setPrimitiveLabelName:(NSString*)value;




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





- (FileContainer*)primitiveFileContainer;
- (void)setPrimitiveFileContainer:(FileContainer*)value;


@end
