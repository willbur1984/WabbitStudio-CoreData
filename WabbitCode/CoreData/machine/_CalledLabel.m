// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CalledLabel.m instead.

#import "_CalledLabel.h"

const struct CalledLabelAttributes CalledLabelAttributes = {
	.labelName = @"labelName",
	.lineNumber = @"lineNumber",
	.location = @"location",
	.name = @"name",
	.range = @"range",
};

const struct CalledLabelRelationships CalledLabelRelationships = {
	.fileContainer = @"fileContainer",
};

const struct CalledLabelFetchedProperties CalledLabelFetchedProperties = {
};

@implementation CalledLabelID
@end

@implementation _CalledLabel

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"CalledLabel" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"CalledLabel";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"CalledLabel" inManagedObjectContext:moc_];
}

- (CalledLabelID*)objectID {
	return (CalledLabelID*)[super objectID];
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

	return keyPaths;
}




@dynamic labelName;






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






@dynamic fileContainer;

	






@end
