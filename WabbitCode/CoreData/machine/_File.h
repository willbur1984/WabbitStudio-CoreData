// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to File.h instead.

#import <CoreData/CoreData.h>
#import "Item.h"

extern const struct FileAttributes {
	__unsafe_unretained NSString *isGroup;
	__unsafe_unretained NSString *path;
	__unsafe_unretained NSString *uti;
} FileAttributes;

extern const struct FileRelationships {
	__unsafe_unretained NSString *breakpoints;
	__unsafe_unretained NSString *file;
	__unsafe_unretained NSString *files;
	__unsafe_unretained NSString *include;
	__unsafe_unretained NSString *issues;
	__unsafe_unretained NSString *project;
	__unsafe_unretained NSString *projectExpandedFilesProjectSettings;
	__unsafe_unretained NSString *projectOpenTabFilesProjectSettings;
	__unsafe_unretained NSString *projectSelectedFilesProjectSettings;
	__unsafe_unretained NSString *projectSelectedTabFileProjectSettings;
} FileRelationships;

extern const struct FileFetchedProperties {
} FileFetchedProperties;

@class FileBreakpoint;
@class File;
@class File;
@class TargetInclude;
@class Issue;
@class Project;
@class ProjectSetting;
@class ProjectSetting;
@class ProjectSetting;
@class ProjectSetting;





@interface FileID : NSManagedObjectID {}
@end

@interface _File : Item {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (FileID*)objectID;




@property (nonatomic, strong) NSNumber* isGroup;


@property BOOL isGroupValue;
- (BOOL)isGroupValue;
- (void)setIsGroupValue:(BOOL)value_;

//- (BOOL)validateIsGroup:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* path;


//- (BOOL)validatePath:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* uti;


//- (BOOL)validateUti:(id*)value_ error:(NSError**)error_;





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




@property (nonatomic, strong) NSSet* projectExpandedFilesProjectSettings;

- (NSMutableSet*)projectExpandedFilesProjectSettingsSet;




@property (nonatomic, strong) NSSet* projectOpenTabFilesProjectSettings;

- (NSMutableSet*)projectOpenTabFilesProjectSettingsSet;




@property (nonatomic, strong) NSSet* projectSelectedFilesProjectSettings;

- (NSMutableSet*)projectSelectedFilesProjectSettingsSet;




@property (nonatomic, strong) NSSet* projectSelectedTabFileProjectSettings;

- (NSMutableSet*)projectSelectedTabFileProjectSettingsSet;





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

- (void)addProjectExpandedFilesProjectSettings:(NSSet*)value_;
- (void)removeProjectExpandedFilesProjectSettings:(NSSet*)value_;
- (void)addProjectExpandedFilesProjectSettingsObject:(ProjectSetting*)value_;
- (void)removeProjectExpandedFilesProjectSettingsObject:(ProjectSetting*)value_;

- (void)addProjectOpenTabFilesProjectSettings:(NSSet*)value_;
- (void)removeProjectOpenTabFilesProjectSettings:(NSSet*)value_;
- (void)addProjectOpenTabFilesProjectSettingsObject:(ProjectSetting*)value_;
- (void)removeProjectOpenTabFilesProjectSettingsObject:(ProjectSetting*)value_;

- (void)addProjectSelectedFilesProjectSettings:(NSSet*)value_;
- (void)removeProjectSelectedFilesProjectSettings:(NSSet*)value_;
- (void)addProjectSelectedFilesProjectSettingsObject:(ProjectSetting*)value_;
- (void)removeProjectSelectedFilesProjectSettingsObject:(ProjectSetting*)value_;

- (void)addProjectSelectedTabFileProjectSettings:(NSSet*)value_;
- (void)removeProjectSelectedTabFileProjectSettings:(NSSet*)value_;
- (void)addProjectSelectedTabFileProjectSettingsObject:(ProjectSetting*)value_;
- (void)removeProjectSelectedTabFileProjectSettingsObject:(ProjectSetting*)value_;

@end

@interface _File (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveIsGroup;
- (void)setPrimitiveIsGroup:(NSNumber*)value;

- (BOOL)primitiveIsGroupValue;
- (void)setPrimitiveIsGroupValue:(BOOL)value_;




- (NSString*)primitivePath;
- (void)setPrimitivePath:(NSString*)value;




- (NSString*)primitiveUti;
- (void)setPrimitiveUti:(NSString*)value;





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



- (NSMutableSet*)primitiveProjectExpandedFilesProjectSettings;
- (void)setPrimitiveProjectExpandedFilesProjectSettings:(NSMutableSet*)value;



- (NSMutableSet*)primitiveProjectOpenTabFilesProjectSettings;
- (void)setPrimitiveProjectOpenTabFilesProjectSettings:(NSMutableSet*)value;



- (NSMutableSet*)primitiveProjectSelectedFilesProjectSettings;
- (void)setPrimitiveProjectSelectedFilesProjectSettings:(NSMutableSet*)value;



- (NSMutableSet*)primitiveProjectSelectedTabFileProjectSettings;
- (void)setPrimitiveProjectSelectedTabFileProjectSettings:(NSMutableSet*)value;


@end
