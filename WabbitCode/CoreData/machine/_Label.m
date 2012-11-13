// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Label.m instead.

#import "_Label.h"

const struct LabelAttributes LabelAttributes = {
};

const struct LabelRelationships LabelRelationships = {
};

const struct LabelFetchedProperties LabelFetchedProperties = {
};

@implementation LabelID
@end

@implementation _Label

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Label" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Label";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Label" inManagedObjectContext:moc_];
}

- (LabelID*)objectID {
	return (LabelID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}









@end
