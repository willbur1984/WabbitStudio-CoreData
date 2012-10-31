// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to FileBreakpoint.m instead.

#import "_FileBreakpoint.h"

const struct FileBreakpointAttributes FileBreakpointAttributes = {
	.range = @"range",
	.symbolType = @"symbolType",
};

const struct FileBreakpointRelationships FileBreakpointRelationships = {
	.file = @"file",
};

const struct FileBreakpointFetchedProperties FileBreakpointFetchedProperties = {
};

@implementation FileBreakpointID
@end

@implementation _FileBreakpoint

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"FileBreakpoint" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"FileBreakpoint";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"FileBreakpoint" inManagedObjectContext:moc_];
}

- (FileBreakpointID*)objectID {
	return (FileBreakpointID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"symbolTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"symbolType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic range;






@dynamic symbolType;



- (int16_t)symbolTypeValue {
	NSNumber *result = [self symbolType];
	return [result shortValue];
}

- (void)setSymbolTypeValue:(int16_t)value_ {
	[self setSymbolType:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveSymbolTypeValue {
	NSNumber *result = [self primitiveSymbolType];
	return [result shortValue];
}

- (void)setPrimitiveSymbolTypeValue:(int16_t)value_ {
	[self setPrimitiveSymbolType:[NSNumber numberWithShort:value_]];
}





@dynamic file;

	






@end
