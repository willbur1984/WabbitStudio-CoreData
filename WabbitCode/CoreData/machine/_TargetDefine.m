// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TargetDefine.m instead.

#import "_TargetDefine.h"

const struct TargetDefineAttributes TargetDefineAttributes = {
	.value = @"value",
};

const struct TargetDefineRelationships TargetDefineRelationships = {
	.target = @"target",
};

const struct TargetDefineFetchedProperties TargetDefineFetchedProperties = {
};

@implementation TargetDefineID
@end

@implementation _TargetDefine

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TargetDefine" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TargetDefine";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TargetDefine" inManagedObjectContext:moc_];
}

- (TargetDefineID*)objectID {
	return (TargetDefineID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic value;






@dynamic target;

	






@end
