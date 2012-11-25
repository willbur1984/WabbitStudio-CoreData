// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ProjectSetting.h instead.

#import <CoreData/CoreData.h>


extern const struct ProjectSettingAttributes {
	__unsafe_unretained NSString *shortUserName;
} ProjectSettingAttributes;

extern const struct ProjectSettingRelationships {
	__unsafe_unretained NSString *project;
	__unsafe_unretained NSString *projectExpandedFiles;
	__unsafe_unretained NSString *projectOpenTabFiles;
	__unsafe_unretained NSString *projectSelectedFiles;
	__unsafe_unretained NSString *projectSelectedTabFile;
} ProjectSettingRelationships;

extern const struct ProjectSettingFetchedProperties {
} ProjectSettingFetchedProperties;

@class Project;
@class File;
@class File;
@class File;
@class File;



@interface ProjectSettingID : NSManagedObjectID {}
@end

@interface _ProjectSetting : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ProjectSettingID*)objectID;




@property (nonatomic, strong) NSString* shortUserName;


//- (BOOL)validateShortUserName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Project* project;

//- (BOOL)validateProject:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSOrderedSet* projectExpandedFiles;

- (NSMutableOrderedSet*)projectExpandedFilesSet;




@property (nonatomic, strong) NSOrderedSet* projectOpenTabFiles;

- (NSMutableOrderedSet*)projectOpenTabFilesSet;




@property (nonatomic, strong) NSSet* projectSelectedFiles;

- (NSMutableSet*)projectSelectedFilesSet;




@property (nonatomic, strong) File* projectSelectedTabFile;

//- (BOOL)validateProjectSelectedTabFile:(id*)value_ error:(NSError**)error_;





@end

@interface _ProjectSetting (CoreDataGeneratedAccessors)

- (void)addProjectExpandedFiles:(NSOrderedSet*)value_;
- (void)removeProjectExpandedFiles:(NSOrderedSet*)value_;
- (void)addProjectExpandedFilesObject:(File*)value_;
- (void)removeProjectExpandedFilesObject:(File*)value_;

- (void)addProjectOpenTabFiles:(NSOrderedSet*)value_;
- (void)removeProjectOpenTabFiles:(NSOrderedSet*)value_;
- (void)addProjectOpenTabFilesObject:(File*)value_;
- (void)removeProjectOpenTabFilesObject:(File*)value_;

- (void)addProjectSelectedFiles:(NSSet*)value_;
- (void)removeProjectSelectedFiles:(NSSet*)value_;
- (void)addProjectSelectedFilesObject:(File*)value_;
- (void)removeProjectSelectedFilesObject:(File*)value_;

@end

@interface _ProjectSetting (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveShortUserName;
- (void)setPrimitiveShortUserName:(NSString*)value;





- (Project*)primitiveProject;
- (void)setPrimitiveProject:(Project*)value;



- (NSMutableOrderedSet*)primitiveProjectExpandedFiles;
- (void)setPrimitiveProjectExpandedFiles:(NSMutableOrderedSet*)value;



- (NSMutableOrderedSet*)primitiveProjectOpenTabFiles;
- (void)setPrimitiveProjectOpenTabFiles:(NSMutableOrderedSet*)value;



- (NSMutableSet*)primitiveProjectSelectedFiles;
- (void)setPrimitiveProjectSelectedFiles:(NSMutableSet*)value;



- (File*)primitiveProjectSelectedTabFile;
- (void)setPrimitiveProjectSelectedTabFile:(File*)value;


@end
