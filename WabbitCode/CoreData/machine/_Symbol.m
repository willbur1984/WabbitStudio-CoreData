// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Symbol.m instead.

#import "_Symbol.h"

const struct SymbolAttributes SymbolAttributes = {
	.lineNumber = @"lineNumber",
	.location = @"location",
	.name = @"name",
	.range = @"range",
	.type = @"type",
};

const struct SymbolRelationships SymbolRelationships = {
	.fileContainer = @"fileContainer",
};

const struct SymbolFetchedProperties SymbolFetchedProperties = {
};

@implementation SymbolID
@end

@implementation _Symbol

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Symbol" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Symbol";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Symbol" inManagedObjectContext:moc_];
}

- (SymbolID*)objectID {
	return (SymbolID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"lineNumberValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lineNumber"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"locationValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"location"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"typeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"type"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic lineNumber;



- (int64_t)lineNumberValue {
	NSNumber *result = [self lineNumber];
	return [result longLongValue];
}

- (void)setLineNumberValue:(int64_t)value_ {
	[self setLineNumber:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveLineNumberValue {
	NSNumber *result = [self primitiveLineNumber];
	return [result longLongValue];
}

- (void)setPrimitiveLineNumberValue:(int64_t)value_ {
	[self setPrimitiveLineNumber:[NSNumber numberWithLongLong:value_]];
}





@dynamic location;



- (int64_t)locationValue {
	NSNumber *result = [self location];
	return [result longLongValue];
}

- (void)setLocationValue:(int64_t)value_ {
	[self setLocation:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveLocationValue {
	NSNumber *result = [self primitiveLocation];
	return [result longLongValue];
}

- (void)setPrimitiveLocationValue:(int64_t)value_ {
	[self setPrimitiveLocation:[NSNumber numberWithLongLong:value_]];
}





@dynamic name;






@dynamic range;






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





@dynamic fileContainer;

	






@end
