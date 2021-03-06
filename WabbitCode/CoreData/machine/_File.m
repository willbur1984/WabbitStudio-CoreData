// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to File.m instead.

#import "_File.h"

const struct FileAttributes FileAttributes = {
	.isGroup = @"isGroup",
	.path = @"path",
	.uti = @"uti",
};

const struct FileRelationships FileRelationships = {
	.breakpoints = @"breakpoints",
	.file = @"file",
	.files = @"files",
	.include = @"include",
	.issues = @"issues",
	.project = @"project",
	.projectExpandedFilesProjectSettings = @"projectExpandedFilesProjectSettings",
	.projectOpenTabFilesProjectSettings = @"projectOpenTabFilesProjectSettings",
	.projectSelectedFilesProjectSettings = @"projectSelectedFilesProjectSettings",
	.projectSelectedTabFileProjectSettings = @"projectSelectedTabFileProjectSettings",
};

const struct FileFetchedProperties FileFetchedProperties = {
};

@implementation FileID
@end

@implementation _File

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"File" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"File";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"File" inManagedObjectContext:moc_];
}

- (FileID*)objectID {
	return (FileID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"isGroupValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isGroup"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic isGroup;



- (BOOL)isGroupValue {
	NSNumber *result = [self isGroup];
	return [result boolValue];
}

- (void)setIsGroupValue:(BOOL)value_ {
	[self setIsGroup:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsGroupValue {
	NSNumber *result = [self primitiveIsGroup];
	return [result boolValue];
}

- (void)setPrimitiveIsGroupValue:(BOOL)value_ {
	[self setPrimitiveIsGroup:[NSNumber numberWithBool:value_]];
}





@dynamic path;






@dynamic uti;






@dynamic breakpoints;

	
- (NSMutableSet*)breakpointsSet {
	[self willAccessValueForKey:@"breakpoints"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"breakpoints"];
  
	[self didAccessValueForKey:@"breakpoints"];
	return result;
}
	

@dynamic file;

	

@dynamic files;

	
- (NSMutableOrderedSet*)filesSet {
	[self willAccessValueForKey:@"files"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"files"];
  
	[self didAccessValueForKey:@"files"];
	return result;
}
	

@dynamic include;

	

@dynamic issues;

	
- (NSMutableSet*)issuesSet {
	[self willAccessValueForKey:@"issues"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"issues"];
  
	[self didAccessValueForKey:@"issues"];
	return result;
}
	

@dynamic project;

	

@dynamic projectExpandedFilesProjectSettings;

	
- (NSMutableSet*)projectExpandedFilesProjectSettingsSet {
	[self willAccessValueForKey:@"projectExpandedFilesProjectSettings"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"projectExpandedFilesProjectSettings"];
  
	[self didAccessValueForKey:@"projectExpandedFilesProjectSettings"];
	return result;
}
	

@dynamic projectOpenTabFilesProjectSettings;

	
- (NSMutableSet*)projectOpenTabFilesProjectSettingsSet {
	[self willAccessValueForKey:@"projectOpenTabFilesProjectSettings"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"projectOpenTabFilesProjectSettings"];
  
	[self didAccessValueForKey:@"projectOpenTabFilesProjectSettings"];
	return result;
}
	

@dynamic projectSelectedFilesProjectSettings;

	
- (NSMutableSet*)projectSelectedFilesProjectSettingsSet {
	[self willAccessValueForKey:@"projectSelectedFilesProjectSettings"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"projectSelectedFilesProjectSettings"];
  
	[self didAccessValueForKey:@"projectSelectedFilesProjectSettings"];
	return result;
}
	

@dynamic projectSelectedTabFileProjectSettings;

	
- (NSMutableSet*)projectSelectedTabFileProjectSettingsSet {
	[self willAccessValueForKey:@"projectSelectedTabFileProjectSettings"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"projectSelectedTabFileProjectSettings"];
  
	[self didAccessValueForKey:@"projectSelectedTabFileProjectSettings"];
	return result;
}
	






@end
