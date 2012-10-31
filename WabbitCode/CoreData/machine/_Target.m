// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Target.m instead.

#import "_Target.h"

const struct TargetAttributes TargetAttributes = {
	.active = @"active",
	.generateCodeListing = @"generateCodeListing",
	.generateLabelFile = @"generateLabelFile",
	.outputType = @"outputType",
	.symbolsAreCaseSensitive = @"symbolsAreCaseSensitive",
};

const struct TargetRelationships TargetRelationships = {
	.defines = @"defines",
	.includes = @"includes",
	.project = @"project",
};

const struct TargetFetchedProperties TargetFetchedProperties = {
};

@implementation TargetID
@end

@implementation _Target

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Target" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Target";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Target" inManagedObjectContext:moc_];
}

- (TargetID*)objectID {
	return (TargetID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"activeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"active"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"generateCodeListingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"generateCodeListing"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"generateLabelFileValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"generateLabelFile"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"outputTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"outputType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"symbolsAreCaseSensitiveValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"symbolsAreCaseSensitive"];
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





@dynamic generateCodeListing;



- (BOOL)generateCodeListingValue {
	NSNumber *result = [self generateCodeListing];
	return [result boolValue];
}

- (void)setGenerateCodeListingValue:(BOOL)value_ {
	[self setGenerateCodeListing:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveGenerateCodeListingValue {
	NSNumber *result = [self primitiveGenerateCodeListing];
	return [result boolValue];
}

- (void)setPrimitiveGenerateCodeListingValue:(BOOL)value_ {
	[self setPrimitiveGenerateCodeListing:[NSNumber numberWithBool:value_]];
}





@dynamic generateLabelFile;



- (BOOL)generateLabelFileValue {
	NSNumber *result = [self generateLabelFile];
	return [result boolValue];
}

- (void)setGenerateLabelFileValue:(BOOL)value_ {
	[self setGenerateLabelFile:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveGenerateLabelFileValue {
	NSNumber *result = [self primitiveGenerateLabelFile];
	return [result boolValue];
}

- (void)setPrimitiveGenerateLabelFileValue:(BOOL)value_ {
	[self setPrimitiveGenerateLabelFile:[NSNumber numberWithBool:value_]];
}





@dynamic outputType;



- (int16_t)outputTypeValue {
	NSNumber *result = [self outputType];
	return [result shortValue];
}

- (void)setOutputTypeValue:(int16_t)value_ {
	[self setOutputType:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveOutputTypeValue {
	NSNumber *result = [self primitiveOutputType];
	return [result shortValue];
}

- (void)setPrimitiveOutputTypeValue:(int16_t)value_ {
	[self setPrimitiveOutputType:[NSNumber numberWithShort:value_]];
}





@dynamic symbolsAreCaseSensitive;



- (BOOL)symbolsAreCaseSensitiveValue {
	NSNumber *result = [self symbolsAreCaseSensitive];
	return [result boolValue];
}

- (void)setSymbolsAreCaseSensitiveValue:(BOOL)value_ {
	[self setSymbolsAreCaseSensitive:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveSymbolsAreCaseSensitiveValue {
	NSNumber *result = [self primitiveSymbolsAreCaseSensitive];
	return [result boolValue];
}

- (void)setPrimitiveSymbolsAreCaseSensitiveValue:(BOOL)value_ {
	[self setPrimitiveSymbolsAreCaseSensitive:[NSNumber numberWithBool:value_]];
}





@dynamic defines;

	
- (NSMutableOrderedSet*)definesSet {
	[self willAccessValueForKey:@"defines"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"defines"];
  
	[self didAccessValueForKey:@"defines"];
	return result;
}
	

@dynamic includes;

	
- (NSMutableOrderedSet*)includesSet {
	[self willAccessValueForKey:@"includes"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"includes"];
  
	[self didAccessValueForKey:@"includes"];
	return result;
}
	

@dynamic project;

	






@end
