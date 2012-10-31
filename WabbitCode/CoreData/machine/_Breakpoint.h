// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Breakpoint.h instead.

#import <CoreData/CoreData.h>
#import "Item.h"

extern const struct BreakpointAttributes {
	__unsafe_unretained NSString *active;
	__unsafe_unretained NSString *address;
	__unsafe_unretained NSString *page;
	__unsafe_unretained NSString *type;
} BreakpointAttributes;

extern const struct BreakpointRelationships {
	__unsafe_unretained NSString *project;
} BreakpointRelationships;

extern const struct BreakpointFetchedProperties {
} BreakpointFetchedProperties;

@class Project;






@interface BreakpointID : NSManagedObjectID {}
@end

@interface _Breakpoint : Item {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (BreakpointID*)objectID;




@property (nonatomic, strong) NSNumber* active;


@property BOOL activeValue;
- (BOOL)activeValue;
- (void)setActiveValue:(BOOL)value_;

//- (BOOL)validateActive:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* address;


@property int16_t addressValue;
- (int16_t)addressValue;
- (void)setAddressValue:(int16_t)value_;

//- (BOOL)validateAddress:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* page;


@property int16_t pageValue;
- (int16_t)pageValue;
- (void)setPageValue:(int16_t)value_;

//- (BOOL)validatePage:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* type;


@property int16_t typeValue;
- (int16_t)typeValue;
- (void)setTypeValue:(int16_t)value_;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Project* project;

//- (BOOL)validateProject:(id*)value_ error:(NSError**)error_;





@end

@interface _Breakpoint (CoreDataGeneratedAccessors)

@end

@interface _Breakpoint (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveActive;
- (void)setPrimitiveActive:(NSNumber*)value;

- (BOOL)primitiveActiveValue;
- (void)setPrimitiveActiveValue:(BOOL)value_;




- (NSNumber*)primitiveAddress;
- (void)setPrimitiveAddress:(NSNumber*)value;

- (int16_t)primitiveAddressValue;
- (void)setPrimitiveAddressValue:(int16_t)value_;




- (NSNumber*)primitivePage;
- (void)setPrimitivePage:(NSNumber*)value;

- (int16_t)primitivePageValue;
- (void)setPrimitivePageValue:(int16_t)value_;




- (NSNumber*)primitiveType;
- (void)setPrimitiveType:(NSNumber*)value;

- (int16_t)primitiveTypeValue;
- (void)setPrimitiveTypeValue:(int16_t)value_;





- (Project*)primitiveProject;
- (void)setPrimitiveProject:(Project*)value;


@end
