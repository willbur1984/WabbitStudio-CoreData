// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FileBreakpoint.h instead.

#import <CoreData/CoreData.h>
#import "Breakpoint.h"

extern const struct FileBreakpointAttributes {
	__unsafe_unretained NSString *range;
	__unsafe_unretained NSString *symbolType;
} FileBreakpointAttributes;

extern const struct FileBreakpointRelationships {
	__unsafe_unretained NSString *file;
} FileBreakpointRelationships;

extern const struct FileBreakpointFetchedProperties {
} FileBreakpointFetchedProperties;

@class File;




@interface FileBreakpointID : NSManagedObjectID {}
@end

@interface _FileBreakpoint : Breakpoint {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (FileBreakpointID*)objectID;




@property (nonatomic, strong) NSString* range;


//- (BOOL)validateRange:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* symbolType;


@property int16_t symbolTypeValue;
- (int16_t)symbolTypeValue;
- (void)setSymbolTypeValue:(int16_t)value_;

//- (BOOL)validateSymbolType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) File* file;

//- (BOOL)validateFile:(id*)value_ error:(NSError**)error_;





@end

@interface _FileBreakpoint (CoreDataGeneratedAccessors)

@end

@interface _FileBreakpoint (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveRange;
- (void)setPrimitiveRange:(NSString*)value;




- (NSNumber*)primitiveSymbolType;
- (void)setPrimitiveSymbolType:(NSNumber*)value;

- (int16_t)primitiveSymbolTypeValue;
- (void)setPrimitiveSymbolTypeValue:(int16_t)value_;





- (File*)primitiveFile;
- (void)setPrimitiveFile:(File*)value;


@end
