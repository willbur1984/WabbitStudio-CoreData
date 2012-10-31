// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TargetInclude.m instead.

#import "_TargetInclude.h"

const struct TargetIncludeAttributes TargetIncludeAttributes = {
};

const struct TargetIncludeRelationships TargetIncludeRelationships = {
	.file = @"file",
	.target = @"target",
};

const struct TargetIncludeFetchedProperties TargetIncludeFetchedProperties = {
};

@implementation TargetIncludeID
@end

@implementation _TargetInclude

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TargetInclude" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TargetInclude";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TargetInclude" inManagedObjectContext:moc_];
}

- (TargetIncludeID*)objectID {
	return (TargetIncludeID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic file;

	

@dynamic target;

	






@end
