// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Completion.m instead.

#import "_Completion.h"

const struct CompletionAttributes CompletionAttributes = {
	.name = @"name",
	.priority = @"priority",
	.type = @"type",
};

const struct CompletionRelationships CompletionRelationships = {
	.placeholders = @"placeholders",
};

const struct CompletionFetchedProperties CompletionFetchedProperties = {
};

@implementation CompletionID
@end

@implementation _Completion

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Completion" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Completion";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Completion" inManagedObjectContext:moc_];
}

- (CompletionID*)objectID {
	return (CompletionID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"priorityValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"priority"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"typeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"type"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic name;






@dynamic priority;



- (int64_t)priorityValue {
	NSNumber *result = [self priority];
	return [result longLongValue];
}

- (void)setPriorityValue:(int64_t)value_ {
	[self setPriority:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitivePriorityValue {
	NSNumber *result = [self primitivePriority];
	return [result longLongValue];
}

- (void)setPrimitivePriorityValue:(int64_t)value_ {
	[self setPrimitivePriority:[NSNumber numberWithLongLong:value_]];
}





@dynamic type;



- (int16_t)typeValue {
	NSNumber *result = [self type];
	return [result shortValue];
}

- (void)setTypeValue:(int16_t)value_ {
	[self setType:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveTypeValue {
	NSNumber *result = [self primitiveType];
	return [result shortValue];
}

- (void)setPrimitiveTypeValue:(int16_t)value_ {
	[self setPrimitiveType:[NSNumber numberWithShort:value_]];
}





@dynamic placeholders;

	
- (NSMutableOrderedSet*)placeholdersSet {
	[self willAccessValueForKey:@"placeholders"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"placeholders"];
  
	[self didAccessValueForKey:@"placeholders"];
	return result;
}
	






@end
