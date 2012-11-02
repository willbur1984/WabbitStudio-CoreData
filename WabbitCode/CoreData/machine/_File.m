// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to File.m instead.

#import "_File.h"

const struct FileAttributes FileAttributes = {
	.isGroup = @"isGroup",
	.path = @"path",
	.url = @"url",
};

const struct FileRelationships FileRelationships = {
	.breakpoints = @"breakpoints",
	.file = @"file",
	.files = @"files",
	.include = @"include",
	.issues = @"issues",
	.project = @"project",
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






@dynamic url;






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

	






@end
