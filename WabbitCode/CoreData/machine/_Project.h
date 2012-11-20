// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Project.h instead.

#import <CoreData/CoreData.h>
#import "Item.h"

extern const struct ProjectAttributes {
} ProjectAttributes;

extern const struct ProjectRelationships {
	__unsafe_unretained NSString *breakpoints;
	__unsafe_unretained NSString *file;
	__unsafe_unretained NSString *issues;
	__unsafe_unretained NSString *projectSettings;
	__unsafe_unretained NSString *targets;
} ProjectRelationships;

extern const struct ProjectFetchedProperties {
} ProjectFetchedProperties;

@class Breakpoint;
@class File;
@class Issue;
@class ProjectSetting;
@class Target;


@interface ProjectID : NSManagedObjectID {}
@end

@interface _Project : Item {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ProjectID*)objectID;





@property (nonatomic, strong) NSSet* breakpoints;

- (NSMutableSet*)breakpointsSet;




@property (nonatomic, strong) File* file;

//- (BOOL)validateFile:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet* issues;

- (NSMutableSet*)issuesSet;




@property (nonatomic, strong) NSSet* projectSettings;

- (NSMutableSet*)projectSettingsSet;




@property (nonatomic, strong) NSSet* targets;

- (NSMutableSet*)targetsSet;





@end

@interface _Project (CoreDataGeneratedAccessors)

- (void)addBreakpoints:(NSSet*)value_;
- (void)removeBreakpoints:(NSSet*)value_;
- (void)addBreakpointsObject:(Breakpoint*)value_;
- (void)removeBreakpointsObject:(Breakpoint*)value_;

- (void)addIssues:(NSSet*)value_;
- (void)removeIssues:(NSSet*)value_;
- (void)addIssuesObject:(Issue*)value_;
- (void)removeIssuesObject:(Issue*)value_;

- (void)addProjectSettings:(NSSet*)value_;
- (void)removeProjectSettings:(NSSet*)value_;
- (void)addProjectSettingsObject:(ProjectSetting*)value_;
- (void)removeProjectSettingsObject:(ProjectSetting*)value_;

- (void)addTargets:(NSSet*)value_;
- (void)removeTargets:(NSSet*)value_;
- (void)addTargetsObject:(Target*)value_;
- (void)removeTargetsObject:(Target*)value_;

@end

@interface _Project (CoreDataGeneratedPrimitiveAccessors)



- (NSMutableSet*)primitiveBreakpoints;
- (void)setPrimitiveBreakpoints:(NSMutableSet*)value;



- (File*)primitiveFile;
- (void)setPrimitiveFile:(File*)value;



- (NSMutableSet*)primitiveIssues;
- (void)setPrimitiveIssues:(NSMutableSet*)value;



- (NSMutableSet*)primitiveProjectSettings;
- (void)setPrimitiveProjectSettings:(NSMutableSet*)value;



- (NSMutableSet*)primitiveTargets;
- (void)setPrimitiveTargets:(NSMutableSet*)value;


@end
