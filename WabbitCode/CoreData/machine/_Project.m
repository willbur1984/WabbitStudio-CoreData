// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Project.m instead.

#import "_Project.h"

const struct ProjectAttributes ProjectAttributes = {
};

const struct ProjectRelationships ProjectRelationships = {
	.breakpoints = @"breakpoints",
	.file = @"file",
	.issues = @"issues",
	.targets = @"targets",
};

const struct ProjectFetchedProperties ProjectFetchedProperties = {
};

@implementation ProjectID
@end

@implementation _Project

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Project";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Project" inManagedObjectContext:moc_];
}

- (ProjectID*)objectID {
	return (ProjectID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic breakpoints;

	
- (NSMutableSet*)breakpointsSet {
	[self willAccessValueForKey:@"breakpoints"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"breakpoints"];
  
	[self didAccessValueForKey:@"breakpoints"];
	return result;
}
	

@dynamic file;

	

@dynamic issues;

	
- (NSMutableSet*)issuesSet {
	[self willAccessValueForKey:@"issues"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"issues"];
  
	[self didAccessValueForKey:@"issues"];
	return result;
}
	

@dynamic targets;

	
- (NSMutableSet*)targetsSet {
	[self willAccessValueForKey:@"targets"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"targets"];
  
	[self didAccessValueForKey:@"targets"];
	return result;
}
	






@end
