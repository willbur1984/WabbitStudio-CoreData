// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ProjectSetting.m instead.

#import "_ProjectSetting.h"

const struct ProjectSettingAttributes ProjectSettingAttributes = {
	.projectFilterString = @"projectFilterString",
	.shortUserName = @"shortUserName",
};

const struct ProjectSettingRelationships ProjectSettingRelationships = {
	.project = @"project",
	.projectExpandedFiles = @"projectExpandedFiles",
	.projectOpenTabFiles = @"projectOpenTabFiles",
	.projectSelectedFiles = @"projectSelectedFiles",
	.projectSelectedTabFile = @"projectSelectedTabFile",
};

const struct ProjectSettingFetchedProperties ProjectSettingFetchedProperties = {
};

@implementation ProjectSettingID
@end

@implementation _ProjectSetting

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ProjectSetting" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ProjectSetting";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ProjectSetting" inManagedObjectContext:moc_];
}

- (ProjectSettingID*)objectID {
	return (ProjectSettingID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic projectFilterString;






@dynamic shortUserName;






@dynamic project;

	

@dynamic projectExpandedFiles;

	
- (NSMutableOrderedSet*)projectExpandedFilesSet {
	[self willAccessValueForKey:@"projectExpandedFiles"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"projectExpandedFiles"];
  
	[self didAccessValueForKey:@"projectExpandedFiles"];
	return result;
}
	

@dynamic projectOpenTabFiles;

	
- (NSMutableOrderedSet*)projectOpenTabFilesSet {
	[self willAccessValueForKey:@"projectOpenTabFiles"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"projectOpenTabFiles"];
  
	[self didAccessValueForKey:@"projectOpenTabFiles"];
	return result;
}
	

@dynamic projectSelectedFiles;

	
- (NSMutableSet*)projectSelectedFilesSet {
	[self willAccessValueForKey:@"projectSelectedFiles"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"projectSelectedFiles"];
  
	[self didAccessValueForKey:@"projectSelectedFiles"];
	return result;
}
	

@dynamic projectSelectedTabFile;

	






@end
