// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Issue.h instead.

#import <CoreData/CoreData.h>
#import "Item.h"

extern const struct IssueAttributes {
	__unsafe_unretained NSString *active;
	__unsafe_unretained NSString *code;
	__unsafe_unretained NSString *range;
	__unsafe_unretained NSString *type;
} IssueAttributes;

extern const struct IssueRelationships {
	__unsafe_unretained NSString *file;
	__unsafe_unretained NSString *project;
} IssueRelationships;

extern const struct IssueFetchedProperties {
} IssueFetchedProperties;

@class File;
@class Project;






@interface IssueID : NSManagedObjectID {}
@end

@interface _Issue : Item {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (IssueID*)objectID;




@property (nonatomic, strong) NSNumber* active;


@property BOOL activeValue;
- (BOOL)activeValue;
- (void)setActiveValue:(BOOL)value_;

//- (BOOL)validateActive:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* code;


//- (BOOL)validateCode:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* range;


//- (BOOL)validateRange:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* type;


@property int16_t typeValue;
- (int16_t)typeValue;
- (void)setTypeValue:(int16_t)value_;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) File* file;

//- (BOOL)validateFile:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) Project* project;

//- (BOOL)validateProject:(id*)value_ error:(NSError**)error_;





@end

@interface _Issue (CoreDataGeneratedAccessors)

@end

@interface _Issue (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveActive;
- (void)setPrimitiveActive:(NSNumber*)value;

- (BOOL)primitiveActiveValue;
- (void)setPrimitiveActiveValue:(BOOL)value_;




- (NSString*)primitiveCode;
- (void)setPrimitiveCode:(NSString*)value;




- (NSString*)primitiveRange;
- (void)setPrimitiveRange:(NSString*)value;




- (NSNumber*)primitiveType;
- (void)setPrimitiveType:(NSNumber*)value;

- (int16_t)primitiveTypeValue;
- (void)setPrimitiveTypeValue:(int16_t)value_;





- (File*)primitiveFile;
- (void)setPrimitiveFile:(File*)value;



- (Project*)primitiveProject;
- (void)setPrimitiveProject:(Project*)value;


@end
