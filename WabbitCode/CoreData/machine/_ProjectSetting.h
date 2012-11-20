// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ProjectSetting.h instead.

#import <CoreData/CoreData.h>


extern const struct ProjectSettingAttributes {
	__unsafe_unretained NSString *shortUserName;
} ProjectSettingAttributes;

extern const struct ProjectSettingRelationships {
	__unsafe_unretained NSString *project;
	__unsafe_unretained NSString *projectExpandedFiles;
	__unsafe_unretained NSString *projectSelectedFiles;
} ProjectSettingRelationships;

extern const struct ProjectSettingFetchedProperties {
} ProjectSettingFetchedProperties;

@class Project;
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




@property (nonatomic, strong) NSSet* projectSelectedFiles;

- (NSMutableSet*)projectSelectedFilesSet;





@end

@interface _ProjectSetting (CoreDataGeneratedAccessors)

- (void)addProjectExpandedFiles:(NSOrderedSet*)value_;
- (void)removeProjectExpandedFiles:(NSOrderedSet*)value_;
- (void)addProjectExpandedFilesObject:(File*)value_;
- (void)removeProjectExpandedFilesObject:(File*)value_;

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



- (NSMutableSet*)primitiveProjectSelectedFiles;
- (void)setPrimitiveProjectSelectedFiles:(NSMutableSet*)value;


@end
