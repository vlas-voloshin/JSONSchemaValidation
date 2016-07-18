//
//  VVJSONSchemaObjectPropertiesValidator.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 1/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchemaObjectPropertiesValidator.h"
#import "VVJSONSchema.h"
#import "VVJSONSchemaFactory.h"
#import "VVJSONSchemaErrors.h"
#import "VVJSONSchemaValidationContext.h"
#import "NSNumber+VVJSONNumberTypes.h"

@implementation VVJSONSchemaObjectPropertiesValidator

static NSString * const kSchemaKeywordProperties = @"properties";
static NSString * const kSchemaKeywordAdditionalProperties = @"additionalProperties";
static NSString * const kSchemaKeywordPatternProperties = @"patternProperties";

- (instancetype)initWithPropertySchemas:(NSDictionary<NSString *, VVJSONSchema *> *)propertySchemas additionalPropertiesSchema:(VVJSONSchema *)additionalPropertiesSchema additionalPropertiesAllowed:(BOOL)additionalPropertiesAllowed patternBasedPropertySchemas:(NSDictionary<NSRegularExpression *, VVJSONSchema *> *)patternBasedPropertySchemas
{
    NSAssert(additionalPropertiesSchema == nil || additionalPropertiesAllowed, @"Cannot have additional properties schema if additional properties are not allowed.");
    
    self = [super init];
    if (self) {
        _propertySchemas = [propertySchemas copy];
        _additionalPropertiesSchema = additionalPropertiesSchema;
        _additionalPropertiesAllowed = additionalPropertiesAllowed;
        _patternBasedPropertySchemas = [patternBasedPropertySchemas copy];
    }
    
    return self;
}

- (NSString *)description
{
    NSString *additionalPropertiesDescription;
    if (self.additionalPropertiesSchema != nil) {
        additionalPropertiesDescription = self.additionalPropertiesSchema.description;
    } else {
        additionalPropertiesDescription = (self.additionalPropertiesAllowed ? @"allowed" : @"not allowed");
    }
    
    return [[super description] stringByAppendingFormat:@"{ %lu properties; additional properties: %@; %lu pattern properties }", (unsigned long)self.propertySchemas.count, additionalPropertiesDescription, (unsigned long)self.patternBasedPropertySchemas.count];
}

+ (NSSet<NSString *> *)assignedKeywords
{
    return [NSSet setWithArray:@[ kSchemaKeywordProperties, kSchemaKeywordAdditionalProperties, kSchemaKeywordPatternProperties ]];
}

+ (instancetype)validatorWithDictionary:(NSDictionary<NSString *, id> *)schemaDictionary schemaFactory:(VVJSONSchemaFactory *)schemaFactory error:(NSError *__autoreleasing *)error
{
    id propertiesObject = schemaDictionary[kSchemaKeywordProperties];
    id additionalPropertiesObject = schemaDictionary[kSchemaKeywordAdditionalProperties];
    id patternPropertiesObject = schemaDictionary[kSchemaKeywordPatternProperties];
    
    // parse properties keyword
    NSDictionary<NSString *, VVJSONSchema *> *propertySchemas = nil;
    // properties must be a dictionary
    if ([propertiesObject isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary<NSString *, VVJSONSchema *> *schemas = [NSMutableDictionary dictionaryWithCapacity:[propertiesObject count]];
        
        __block BOOL success = YES;
        __block NSError *internalError = nil;
        [propertiesObject enumerateKeysAndObjectsUsingBlock:^(NSString *property, id schemaObject, BOOL *stop) {
            // schema object must be a dictionary
            if ([schemaObject isKindOfClass:[NSDictionary class]]) {
                // each schema will have scope extended by "/properties/#" where # is property name
                VVJSONSchemaFactory *propertySchemaFactory = [schemaFactory factoryByAppendingScopeComponentsFromArray:@[ kSchemaKeywordProperties, property ]];
                
                VVJSONSchema *propertySchema = [propertySchemaFactory schemaWithDictionary:schemaObject error:&internalError];
                if (propertySchema != nil) {
                    schemas[property] = propertySchema;
                } else {
                    success = NO;
                }
            } else {
                success = NO;
                internalError = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaObject];
            }
            
            if (success == NO) {
                *stop = YES;
            }
        }];
        
        if (success) {
            propertySchemas = [schemas copy];
        } else {
            if (error != NULL) {
                *error = internalError;
            }
            return nil;
        }
    } else if (propertiesObject != nil) {
        // invalid instance
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaDictionary];
        }
        return nil;
    }
    
    // parse additionalProperties keyword
    VVJSONSchema *additionalPropertiesSchema = nil;
    BOOL additionalPropertiesAllowed = YES;
    if ([additionalPropertiesObject isKindOfClass:[NSDictionary class]]) {
        // parse as a schema object; schema will have scope extended by "/additionalProperties"
        VVJSONSchemaFactory *additionalSchemaFactory = [schemaFactory factoryByAppendingScopeComponent:kSchemaKeywordAdditionalProperties];
        
        additionalPropertiesSchema = [additionalSchemaFactory schemaWithDictionary:additionalPropertiesObject error:error];
        if (additionalPropertiesSchema == nil) {
            return nil;
        }
    } else if ([additionalPropertiesObject isKindOfClass:[NSNumber class]] && [additionalPropertiesObject vv_isBoolean]) {
        // parse as a boolean
        additionalPropertiesAllowed = [additionalPropertiesObject boolValue];
    } else if (additionalPropertiesObject != nil) {
        // invalid instance
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaDictionary];
        }
        return nil;
    }
    
    // parse patternProperties keyword
    NSDictionary<NSRegularExpression *, VVJSONSchema *> *patternBasedProperties = nil;
    // patternProperties must be a dictionary
    if ([patternPropertiesObject isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary<NSRegularExpression *, VVJSONSchema *> *schemas = [NSMutableDictionary dictionaryWithCapacity:[patternPropertiesObject count]];
        
        __block BOOL success = YES;
        __block NSError *internalError = nil;
        [patternPropertiesObject enumerateKeysAndObjectsUsingBlock:^(NSString *pattern, id schemaObject, BOOL *stop) {
            // schema object must be a dictionary
            if ([schemaObject isKindOfClass:[NSDictionary class]]) {
                // pattern must be a valid regular expression
                NSError *underlyingError;
                NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:(NSRegularExpressionOptions)0 error:&underlyingError];
                if (regexp != nil) {
                    // each schema will have scope extended by "/patternProperties/#" where # is the pattern
                    VVJSONSchemaFactory *propertySchemaFactory = [schemaFactory factoryByAppendingScopeComponentsFromArray:@[ kSchemaKeywordPatternProperties, pattern ]];
                    
                    VVJSONSchema *propertySchema = [propertySchemaFactory schemaWithDictionary:schemaObject error:&internalError];
                    if (propertySchema != nil) {
                        schemas[regexp] = propertySchema;
                    } else {
                        success = NO;
                    }
                } else {
                    success = NO;
                    internalError = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidRegularExpression failingObject:pattern underlyingError:underlyingError];
                }
            } else {
                success = NO;
                internalError = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaObject];
            }
            
            if (success == NO) {
                *stop = YES;
            }
        }];
        
        if (success) {
            patternBasedProperties = [schemas copy];
        } else {
            if (error != NULL) {
                *error = internalError;
            }
            return nil;
        }
    } else if (patternPropertiesObject != nil) {
        // invalid instance
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaDictionary];
        }
        return nil;
    }
    
    return [[self alloc] initWithPropertySchemas:propertySchemas additionalPropertiesSchema:additionalPropertiesSchema additionalPropertiesAllowed:additionalPropertiesAllowed patternBasedPropertySchemas:patternBasedProperties];
}

- (NSArray<VVJSONSchema *> *)subschemas
{
    NSMutableArray<VVJSONSchema *> *subschemas = [NSMutableArray array];

    NSDictionary<NSString *, VVJSONSchema *> *propertySchemas = self.propertySchemas;
    if (propertySchemas != nil) {
        [subschemas addObjectsFromArray:propertySchemas.allValues];
    }

    VVJSONSchema *additionalPropertiesSchema = self.additionalPropertiesSchema;
    if (additionalPropertiesSchema != nil) {
        [subschemas addObject:additionalPropertiesSchema];
    }

    NSDictionary<NSRegularExpression *, VVJSONSchema *> *patternBasedPropertySchemas = self.patternBasedPropertySchemas;
    if (patternBasedPropertySchemas != nil) {
        [subschemas addObjectsFromArray:patternBasedPropertySchemas.allValues];
    }
    
    return [subschemas copy];
}

- (BOOL)validateInstance:(id)instance inContext:(VVJSONSchemaValidationContext *)context error:(NSError *__autoreleasing *)error
{
    // silently succeed if value of the instance is inapplicable
    if ([instance isKindOfClass:[NSDictionary class]] == NO) {
        return YES;
    }

    // validate each item with the corresponding schema
    __block BOOL success = YES;
    __block NSError *internalError = nil;
    [instance enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        // enumerate and validate all schemas applicable to the property
        BOOL enumerationSuccess = [self enumerateSchemasForProperty:key withBlock:^(VVJSONSchema *schema, BOOL *innerStop) {
            [context pushValidationPathComponent:key];
            BOOL result = [schema validateObject:obj inContext:context error:&internalError];
            [context popValidationPathComponent];
            
            if (result == NO) {
                success = NO;
                *innerStop = YES;
                *stop = YES;
            }
        }];
        
        // stop if enumeration failed (property is not acceptable)
        if (enumerationSuccess == NO) {
            NSString *failureReason = [NSString stringWithFormat:@"Additional property '%@' is not allowed.", key];
            internalError = [NSError vv_JSONSchemaValidationErrorWithFailingValidator:self reason:failureReason context:context];
            success = NO;
            *stop = YES;
        }
    }];
    
    if (success == NO) {
        if (error != NULL) {
            *error = internalError;
        }
    }
    
    return success;
}

- (BOOL)enumerateSchemasForProperty:(NSString *)property withBlock:(void (^)(VVJSONSchema *schema, BOOL *stop))block
{
    NSParameterAssert(property);
    NSParameterAssert(block);
    
    __block BOOL visitedOnce = NO;
    __block BOOL enumerationStop = NO;
    
    // visit schema defined for the property, if present
    VVJSONSchema *propertySchema = self.propertySchemas[property];
    if (propertySchema != nil) {
        visitedOnce = YES;
        block(propertySchema, &enumerationStop);
        if (enumerationStop) {
            return YES;
        }
    }
    
    // visit each schema with a matching property pattern
    NSRange propertyFullRange = NSMakeRange(0, property.length);
    [self.patternBasedPropertySchemas enumerateKeysAndObjectsUsingBlock:^(NSRegularExpression *regexp, VVJSONSchema *schema, BOOL *stop) {
        if ([regexp numberOfMatchesInString:property options:(NSMatchingOptions)0 range:propertyFullRange] != 0) {
            visitedOnce = YES;
            block(schema, &enumerationStop);
            if (enumerationStop) {
                *stop = YES;
            }
        }
    }];
    if (enumerationStop) {
        return YES;
    }

    if (visitedOnce == NO) {
        // if applicable schema was not found, respect additional properties configuration:
        VVJSONSchema *additionalPropertiesSchema = self.additionalPropertiesSchema;
        if (additionalPropertiesSchema != nil) {
            // visit additional properties schema, if it's present;
            // stop parameter is passed in the block, but not used anymore
            block(additionalPropertiesSchema, &enumerationStop);
            return YES;
        } else if (self.additionalPropertiesAllowed) {
            // additional properties schema is not defined, but any additional properties are allowed
            return YES;
        } else {
            // additional properties are not allowed
            return NO;
        }
    } else {
        return YES;
    }
}

@end
