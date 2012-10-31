// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Breakpoint.m instead.

#import "_Breakpoint.h"

const struct BreakpointAttributes BreakpointAttributes = {
	.active = @"active",
	.address = @"address",
	.page = @"page",
	.type = @"type",
};

const struct BreakpointRelationships BreakpointRelationships = {
	.project = @"project",
};

const struct BreakpointFetchedProperties BreakpointFetchedProperties = {
};

@implementation BreakpointID
@end

@implementation _Breakpoint

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Breakpoint" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Breakpoint";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Breakpoint" inManagedObjectContext:moc_];
}

- (BreakpointID*)objectID {
	return (BreakpointID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"activeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"active"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"addressValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"address"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"pageValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"page"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"typeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"type"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic active;



- (BOOL)activeValue {
	NSNumber *result = [self active];
	return [result boolValue];
}

- (void)setActiveValue:(BOOL)value_ {
	[self setActive:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveActiveValue {
	NSNumber *result = [self primitiveActive];
	return [result boolValue];
}

- (void)setPrimitiveActiveValue:(BOOL)value_ {
	[self setPrimitiveActive:[NSNumber numberWithBool:value_]];
}





@dynamic address;



- (int16_t)addressValue {
	NSNumber *result = [self address];
	return [result shortValue];
}

- (void)setAddressValue:(int16_t)value_ {
	[self setAddress:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveAddressValue {
	NSNumber *result = [self primitiveAddress];
	return [result shortValue];
}

- (void)setPrimitiveAddressValue:(int16_t)value_ {
	[self setPrimitiveAddress:[NSNumber numberWithShort:value_]];
}





@dynamic page;



- (int16_t)pageValue {
	NSNumber *result = [self page];
	return [result shortValue];
}

- (void)setPageValue:(int16_t)value_ {
	[self setPage:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitivePageValue {
	NSNumber *result = [self primitivePage];
	return [result shortValue];
}

- (void)setPrimitivePageValue:(int16_t)value_ {
	[self setPrimitivePage:[NSNumber numberWithShort:value_]];
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





@dynamic project;

	






@end
