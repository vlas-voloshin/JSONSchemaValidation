//
//  VVJSONSchemaObjectValidator.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 1/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchemaObjectValidator.h"
#import "VVJSONSchemaErrors.h"
#import "NSNumber+VVJSONNumberTypes.h"

@implementation VVJSONSchemaObjectValidator

static NSString * const kSchemaKeywordMaxProperties = @"maxProperties";
static NSString * const kSchemaKeywordMinProperties = @"minProperties";
static NSString * const kSchemaKeywordRequired = @"required";

- (instancetype)initWithMaximumProperties:(NSUInteger)maximumProperties minimumProperties:(NSUInteger)minimumProperties requiredProperties:(NSSet *)requiredProperties
{
    self = [super init];
    if (self) {
        _maximumProperties = maximumProperties;
        _minimumProperties = minimumProperties;
        _requiredProperties = [requiredProperties copy];
    }
    
    return self;
}

- (NSString *)description
{
    NSString *requiredPropertiesDescription = (self.requiredProperties != nil ? [self.requiredProperties.allObjects componentsJoinedByString:@", "] : @"none");
    return [[super description] stringByAppendingFormat:@"{ maximum properties: %@, minimum properties: %lu, required properties: %@ }", (self.maximumProperties != NSUIntegerMax ? @(self.maximumProperties) : @"none"), (unsigned long)self.minimumProperties, requiredPropertiesDescription];
}

+ (NSSet *)assignedKeywords
{
    return [NSSet setWithArray:@[ kSchemaKeywordMaxProperties, kSchemaKeywordMinProperties, kSchemaKeywordRequired ]];
}

+ (instancetype)validatorWithDictionary:(NSDictionary *)schemaDictionary schemaFactory:(VVJSONSchemaFactory *)schemaFactory error:(NSError * __autoreleasing *)error
{
    if ([self validateSchemaFormat:schemaDictionary] == NO) {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaDictionary];
        }
        return nil;
    }
    
    NSNumber *maxProperties = schemaDictionary[kSchemaKeywordMaxProperties];
    NSNumber *minProperties = schemaDictionary[kSchemaKeywordMinProperties];
    NSArray *required = schemaDictionary[kSchemaKeywordRequired];
    
    NSUInteger maxPropertiesValue = (maxProperties != nil ? [maxProperties unsignedIntegerValue] : NSUIntegerMax);
    NSUInteger minPropertiesValue = (minProperties != nil ? [minProperties unsignedIntegerValue] : 0);
    NSSet *requiredSet = (required != nil ? [NSSet setWithArray:required] : nil);

    return [[self alloc] initWithMaximumProperties:maxPropertiesValue minimumProperties:minPropertiesValue requiredProperties:requiredSet];
}

+ (BOOL)validateSchemaFormat:(NSDictionary *)schemaDictionary
{
    id maxProperties = schemaDictionary[kSchemaKeywordMaxProperties];
    id minProperties = schemaDictionary[kSchemaKeywordMinProperties];
    id required = schemaDictionary[kSchemaKeywordRequired];
    
    // maxProperties must be a number and not a boolean, and must be greater than or equal to zero
    if (maxProperties != nil) {
        if ([maxProperties isKindOfClass:[NSNumber class]] == NO || [maxProperties vv_isBoolean] || [(NSNumber *)maxProperties compare:@0] == NSOrderedAscending) {
            return NO;
        }
    }
    // minProperties must be a number and not a boolean, and must be greater than or equal to zero
    if (minProperties != nil) {
        if ([minProperties isKindOfClass:[NSNumber class]] == NO || [minProperties vv_isBoolean] || [(NSNumber *)minProperties compare:@0] == NSOrderedAscending) {
            return NO;
        }
    }
    // required must be a non-empty array of unique strings
    if (required != nil) {
        if ([required isKindOfClass:[NSArray class]] == NO || [required count] == 0) {
            return NO;
        }
        
        for (id property in required) {
            if ([property isKindOfClass:[NSString class]] == NO) {
                return NO;
            }
        }
        
        if ([NSSet setWithArray:required].count != [required count]) {
            return NO;
        }
    }
    
    return YES;
}

- (NSArray *)subschemas
{
    return nil;
}

- (BOOL)validateInstance:(id)instance inContext:(VVJSONSchemaValidationContext *)context error:(NSError *__autoreleasing *)error
{
    // silently succeed if value of the instance is inapplicable
    if ([instance isKindOfClass:[NSDictionary class]] == NO) {
        return YES;
    }

    // check maximum and minimum counts
    NSUInteger propertiesCount = [instance count];
    if (propertiesCount > self.maximumProperties || propertiesCount < self.minimumProperties) {
        if (error != NULL) {
            NSString *failureReason = [NSString stringWithFormat:@"Object contains %lu properties.", (unsigned long)propertiesCount];
            *error = [NSError vv_JSONSchemaValidationErrorWithFailingObject:instance validator:self reason:failureReason];
        }
        return NO;
    }
    
    // check required properties
    if (self.requiredProperties != nil) {
        NSSet *keyset = [NSSet setWithArray:[instance allKeys]];
        if ([self.requiredProperties isSubsetOfSet:keyset] == NO) {
            if (error != NULL) {
                NSMutableSet *missingProperties = [self.requiredProperties mutableCopy];
                [missingProperties minusSet:keyset];
                NSString *missingPropertiesList = [[missingProperties allObjects] componentsJoinedByString:@", "];
                NSString *failureReason = [NSString stringWithFormat:@"Object is missing required properties: '%@'.", missingPropertiesList];
                *error = [NSError vv_JSONSchemaValidationErrorWithFailingObject:instance validator:self reason:failureReason];
            }
            return NO;
        }
    }

    return YES;
}

@end
