// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to File.h instead.

#import <CoreData/CoreData.h>
#import "Item.h"

extern const struct FileAttributes {
	__unsafe_unretained NSString *path;
	__unsafe_unretained NSString *url;
} FileAttributes;

extern const struct FileRelationships {
	__unsafe_unretained NSString *breakpoints;
	__unsafe_unretained NSString *file;
	__unsafe_unretained NSString *files;
	__unsafe_unretained NSString *include;
	__unsafe_unretained NSString *issues;
	__unsafe_unretained NSString *project;
} FileRelationships;

extern const struct FileFetchedProperties {
} FileFetchedProperties;

@class FileBreakpoint;
@class File;
@class File;
@class TargetInclude;
@class Issue;
@class Project;


@class NSObject;

@interface FileID : NSManagedObjectID {}
@end

@interface _File : Item {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (FileID*)objectID;




@property (nonatomic, strong) NSString* path;


//- (BOOL)validatePath:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) id url;


//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet* breakpoints;

- (NSMutableSet*)breakpointsSet;




@property (nonatomic, strong) File* file;

//- (BOOL)validateFile:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSOrderedSet* files;

- (NSMutableOrderedSet*)filesSet;




@property (nonatomic, strong) TargetInclude* include;

//- (BOOL)validateInclude:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet* issues;

- (NSMutableSet*)issuesSet;




@property (nonatomic, strong) Project* project;

//- (BOOL)validateProject:(id*)value_ error:(NSError**)error_;





@end

@interface _File (CoreDataGeneratedAccessors)

- (void)addBreakpoints:(NSSet*)value_;
- (void)removeBreakpoints:(NSSet*)value_;
- (void)addBreakpointsObject:(FileBreakpoint*)value_;
- (void)removeBreakpointsObject:(FileBreakpoint*)value_;

- (void)addFiles:(NSOrderedSet*)value_;
- (void)removeFiles:(NSOrderedSet*)value_;
- (void)addFilesObject:(File*)value_;
- (void)removeFilesObject:(File*)value_;

- (void)addIssues:(NSSet*)value_;
- (void)removeIssues:(NSSet*)value_;
- (void)addIssuesObject:(Issue*)value_;
- (void)removeIssuesObject:(Issue*)value_;

@end

@interface _File (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitivePath;
- (void)setPrimitivePath:(NSString*)value;




- (id)primitiveUrl;
- (void)setPrimitiveUrl:(id)value;





- (NSMutableSet*)primitiveBreakpoints;
- (void)setPrimitiveBreakpoints:(NSMutableSet*)value;



- (File*)primitiveFile;
- (void)setPrimitiveFile:(File*)value;



- (NSMutableOrderedSet*)primitiveFiles;
- (void)setPrimitiveFiles:(NSMutableOrderedSet*)value;



- (TargetInclude*)primitiveInclude;
- (void)setPrimitiveInclude:(TargetInclude*)value;



- (NSMutableSet*)primitiveIssues;
- (void)setPrimitiveIssues:(NSMutableSet*)value;



- (Project*)primitiveProject;
- (void)setPrimitiveProject:(Project*)value;


@end
