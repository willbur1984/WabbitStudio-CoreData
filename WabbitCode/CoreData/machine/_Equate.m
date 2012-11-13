// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Equate.m instead.

#import "_Equate.h"

const struct EquateAttributes EquateAttributes = {
	.value = @"value",
};

const struct EquateRelationships EquateRelationships = {
};

const struct EquateFetchedProperties EquateFetchedProperties = {
};

@implementation EquateID
@end

@implementation _Equate

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Equate" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Equate";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Equate" inManagedObjectContext:moc_];
}

- (EquateID*)objectID {
	return (EquateID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic value;











@end
