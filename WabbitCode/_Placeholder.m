// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Placeholder.m instead.

#import "_Placeholder.h"

const struct PlaceholderAttributes PlaceholderAttributes = {
	.arguments = @"arguments",
	.isPlaceholder = @"isPlaceholder",
	.name = @"name",
};

const struct PlaceholderRelationships PlaceholderRelationships = {
	.completion = @"completion",
};

const struct PlaceholderFetchedProperties PlaceholderFetchedProperties = {
};

@implementation PlaceholderID
@end

@implementation _Placeholder

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Placeholder" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Placeholder";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Placeholder" inManagedObjectContext:moc_];
}

- (PlaceholderID*)objectID {
	return (PlaceholderID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"isPlaceholderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isPlaceholder"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic arguments;






@dynamic isPlaceholder;



- (BOOL)isPlaceholderValue {
	NSNumber *result = [self isPlaceholder];
	return [result boolValue];
}

- (void)setIsPlaceholderValue:(BOOL)value_ {
	[self setIsPlaceholder:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsPlaceholderValue {
	NSNumber *result = [self primitiveIsPlaceholder];
	return [result boolValue];
}

- (void)setPrimitiveIsPlaceholderValue:(BOOL)value_ {
	[self setPrimitiveIsPlaceholder:[NSNumber numberWithBool:value_]];
}





@dynamic name;






@dynamic completion;

	
- (NSMutableSet*)completionSet {
	[self willAccessValueForKey:@"completion"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"completion"];
  
	[self didAccessValueForKey:@"completion"];
	return result;
}
	






@end
