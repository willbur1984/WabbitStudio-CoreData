// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FileContainer.m instead.

#import "_FileContainer.h"

const struct FileContainerAttributes FileContainerAttributes = {
	.path = @"path",
	.uuid = @"uuid",
};

const struct FileContainerRelationships FileContainerRelationships = {
	.symbols = @"symbols",
};

const struct FileContainerFetchedProperties FileContainerFetchedProperties = {
};

@implementation FileContainerID
@end

@implementation _FileContainer

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"FileContainer" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"FileContainer";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"FileContainer" inManagedObjectContext:moc_];
}

- (FileContainerID*)objectID {
	return (FileContainerID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic path;






@dynamic uuid;






@dynamic symbols;

	
- (NSMutableSet*)symbolsSet {
	[self willAccessValueForKey:@"symbols"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"symbols"];
  
	[self didAccessValueForKey:@"symbols"];
	return result;
}
	






@end
