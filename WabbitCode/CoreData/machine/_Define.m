// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Define.m instead.

#import "_Define.h"

const struct DefineAttributes DefineAttributes = {
	.arguments = @"arguments",
	.value = @"value",
};

const struct DefineRelationships DefineRelationships = {
};

const struct DefineFetchedProperties DefineFetchedProperties = {
};

@implementation DefineID
@end

@implementation _Define

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Define" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Define";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Define" inManagedObjectContext:moc_];
}

- (DefineID*)objectID {
	return (DefineID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic arguments;






@dynamic value;











@end
