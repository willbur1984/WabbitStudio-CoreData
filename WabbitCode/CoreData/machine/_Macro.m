// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Macro.m instead.

#import "_Macro.h"

const struct MacroAttributes MacroAttributes = {
	.arguments = @"arguments",
	.value = @"value",
};

const struct MacroRelationships MacroRelationships = {
};

const struct MacroFetchedProperties MacroFetchedProperties = {
};

@implementation MacroID
@end

@implementation _Macro

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Macro" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Macro";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Macro" inManagedObjectContext:moc_];
}

- (MacroID*)objectID {
	return (MacroID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic arguments;






@dynamic value;











@end
