//
//  VVJSONSchemaArrayValidator.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 1/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchemaArrayValidator.h"
#import "VVJSONSchemaErrors.h"
#import "NSNumber+VVJSONNumberTypes.h"
#import "NSArray+VVJSONComparison.h"

@implementation VVJSONSchemaArrayValidator

static NSString * const kSchemaKeywordMaxItems = @"maxItems";
static NSString * const kSchemaKeywordMinItems = @"minItems";
static NSString * const kSchemaKeywordUniqueItems = @"uniqueItems";

- (instancetype)initWithMaximumItems:(NSUInteger)maximumItems minimumItems:(NSUInteger)minimumItems uniqueItems:(BOOL)uniqueItems
{
    self = [super init];
    if (self) {
        _maximumItems = maximumItems;
        _minimumItems = minimumItems;
        _uniqueItems = uniqueItems;
    }
    
    return self;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"{ maximum items: %@, minimum items: %lu, unique: %@ }", (self.maximumItems != NSUIntegerMax ? @(self.maximumItems) : @"none"), (unsigned long)self.minimumItems, (self.uniqueItems ? @"YES" : @"NO")];
}

+ (NSSet *)assignedKeywords
{
    return [NSSet setWithArray:@[ kSchemaKeywordMaxItems, kSchemaKeywordMinItems, kSchemaKeywordUniqueItems ]];
}

+ (instancetype)validatorWithDictionary:(NSDictionary *)schemaDictionary schemaFactory:(VVJSONSchemaFactory *)schemaFactory error:(NSError *__autoreleasing *)error
{
    if ([self validateSchemaFormat:schemaDictionary] == NO) {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaDictionary failingValidator:nil];
        }
        return nil;
    }
    
    NSNumber *maxItems = schemaDictionary[kSchemaKeywordMaxItems];
    NSNumber *minItems = schemaDictionary[kSchemaKeywordMinItems];
    NSNumber *uniqueItems = schemaDictionary[kSchemaKeywordUniqueItems];
    
    NSUInteger maxItemsValue = (maxItems != nil ? [maxItems unsignedIntegerValue] : NSUIntegerMax);
    NSUInteger minItemsValue = (minItems != nil ? [minItems unsignedIntegerValue] : 0);
    BOOL uniqueItemsValue = (uniqueItems != nil ? [uniqueItems boolValue] : NO);
    
    return [[self alloc] initWithMaximumItems:maxItemsValue minimumItems:minItemsValue uniqueItems:uniqueItemsValue];
}

+ (BOOL)validateSchemaFormat:(NSDictionary *)schemaDictionary
{
    id maxItems = schemaDictionary[kSchemaKeywordMaxItems];
    id minItems = schemaDictionary[kSchemaKeywordMinItems];
    id uniqueItems = schemaDictionary[kSchemaKeywordUniqueItems];
    
    // maxItems must be a number and not a boolean, and must be greater than or equal to zero
    if (maxItems != nil) {
        if ([maxItems isKindOfClass:[NSNumber class]] == NO || [maxItems vv_isBoolean] || [maxItems compare:@0] == NSOrderedAscending) {
            return NO;
        }
    }
    // minItems must be a number and not a boolean, and must be greater than or equal to zero
    if (minItems != nil) {
        if ([minItems isKindOfClass:[NSNumber class]] == NO || [minItems vv_isBoolean] || [minItems compare:@0] == NSOrderedAscending) {
            return NO;
        }
    }
    // uniqueItems must be a boolean number
    if (uniqueItems != nil) {
        if ([uniqueItems isKindOfClass:[NSNumber class]] == NO || [uniqueItems vv_isBoolean] == NO) {
            return NO;
        }
    }
    
    return YES;
}

- (NSSet *)subschemas
{
    return nil;
}

- (BOOL)validateInstance:(id)instance withError:(NSError *__autoreleasing *)error
{
    // silently succeed if value of the instance is inapplicable
    if ([instance isKindOfClass:[NSArray class]] == NO) {
        return YES;
    }
    
    // check maximum and minimum counts
    NSUInteger itemsCount = [instance count];
    if (itemsCount > self.maximumItems || itemsCount < self.minimumItems) {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeValidationFailed failingObject:instance failingValidator:self];
        }
        return NO;
    }
    
    // check items uniqueness if necessary
    if (self.uniqueItems) {
        if ([instance vv_containsDuplicateJSONItems]) {
            if (error != NULL) {
                *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeValidationFailed failingObject:instance failingValidator:self];
            }
            return NO;
        }
    }
    
    return YES;
}

@end
