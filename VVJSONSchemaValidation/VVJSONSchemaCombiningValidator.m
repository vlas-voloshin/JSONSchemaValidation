//
//  VVJSONSchemaCombiningValidator.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 2/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchemaCombiningValidator.h"
#import "VVJSONSchema.h"
#import "VVJSONSchemaFactory.h"
#import "VVJSONSchemaErrors.h"

@implementation VVJSONSchemaCombiningValidator

static NSString * const kSchemaKeywordAllOf = @"allOf";
static NSString * const kSchemaKeywordAnyOf = @"anyOf";
static NSString * const kSchemaKeywordOneOf = @"oneOf";
static NSString * const kSchemaKeywordNot = @"not";

- (instancetype)initWithAllOfSchemas:(NSArray<VVJSONSchema *> *)allOfSchemas anyOfSchemas:(NSArray<VVJSONSchema *> *)anyOfSchemas oneOfSchemas:(NSArray<VVJSONSchema *> *)oneOfSchemas notSchema:(VVJSONSchema *)notSchema
{
    self = [super init];
    if (self) {
        _allOfSchemas = [allOfSchemas copy];
        _anyOfSchemas = [anyOfSchemas copy];
        _oneOfSchemas = [oneOfSchemas copy];
        _notSchema = notSchema;
    }
    
    return self;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"{ all of %lu schemas; any of %lu schemas; one of %lu schemas; not %@ }", (unsigned long)self.allOfSchemas.count, (unsigned long)self.anyOfSchemas.count, (unsigned long)self.oneOfSchemas.count, self.notSchema];
}

+ (NSSet<NSString *> *)assignedKeywords
{
    return [NSSet setWithArray:@[ kSchemaKeywordAllOf, kSchemaKeywordAnyOf, kSchemaKeywordOneOf, kSchemaKeywordNot ]];
}

+ (instancetype)validatorWithDictionary:(NSDictionary<NSString *, id> *)schemaDictionary schemaFactory:(VVJSONSchemaFactory *)schemaFactory error:(NSError *__autoreleasing *)error
{
    id allOfObject = schemaDictionary[kSchemaKeywordAllOf];
    id anyOfObject = schemaDictionary[kSchemaKeywordAnyOf];
    id oneOfObect = schemaDictionary[kSchemaKeywordOneOf];
    id notObject = schemaDictionary[kSchemaKeywordNot];
    
    // parse allOf keyword
    NSArray<VVJSONSchema *> *allOfSchemas = nil;
    if (allOfObject != nil) {
        VVJSONSchemaFactory *internalFactory = [schemaFactory factoryByAppendingScopeComponent:kSchemaKeywordAllOf];
        allOfSchemas = [self schemasArrayFromObject:allOfObject factory:internalFactory error:error];
        if (allOfSchemas == nil) {
            return nil;
        }
    }
    
    // parse anyOf keyword
    NSArray<VVJSONSchema *> *anyOfSchemas = nil;
    if (anyOfObject != nil) {
        VVJSONSchemaFactory *internalFactory = [schemaFactory factoryByAppendingScopeComponent:kSchemaKeywordAnyOf];
        anyOfSchemas = [self schemasArrayFromObject:anyOfObject factory:internalFactory error:error];
        if (anyOfSchemas == nil) {
            return nil;
        }
    }
    
    // parse oneOf keyword
    NSArray<VVJSONSchema *> *oneOfSchemas = nil;
    if (oneOfObect != nil) {
        VVJSONSchemaFactory *internalFactory = [schemaFactory factoryByAppendingScopeComponent:kSchemaKeywordOneOf];
        oneOfSchemas = [self schemasArrayFromObject:oneOfObect factory:internalFactory error:error];
        if (oneOfSchemas == nil) {
            return nil;
        }
    }
    
    // parse not keyword
    VVJSONSchema *notSchema = nil;
    if (notObject != nil) {
        // not must be a dictionary
        if ([notObject isKindOfClass:[NSDictionary class]]) {
            VVJSONSchemaFactory *internalFactory = [schemaFactory factoryByAppendingScopeComponent:kSchemaKeywordNot];
            notSchema = [internalFactory schemaWithDictionary:notObject error:error];
            if (notSchema == nil) {
                return nil;
            }
        } else {
            if (error != NULL) {
                *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaDictionary];
            }
            return nil;
        }
    }
    
    return [[self alloc] initWithAllOfSchemas:allOfSchemas anyOfSchemas:anyOfSchemas oneOfSchemas:oneOfSchemas notSchema:notSchema];
}

+ (NSArray<VVJSONSchema *> *)schemasArrayFromObject:(id)schemasObject factory:(VVJSONSchemaFactory *)factory error:(NSError * __autoreleasing *)error
{
    NSParameterAssert(schemasObject);
    NSParameterAssert(factory);
    
    if ([self validateSchemasArrayObject:schemasObject] == NO) {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemasObject];
        }
        return nil;
    }
    
    NSMutableArray<VVJSONSchema *> *schemas = [NSMutableArray arrayWithCapacity:[schemasObject count]];
    
    __block BOOL success = YES;
    __block NSError *internalError = nil;
    [(NSArray<NSDictionary *> *)schemasObject enumerateObjectsUsingBlock:^(NSDictionary *schemaObject, NSUInteger idx, BOOL *stop) {
        NSString *scopeComponent = [NSString stringWithFormat:@"%lu", (unsigned long)idx];
        VVJSONSchemaFactory *internalSchemaFactory = [factory factoryByAppendingScopeComponent:scopeComponent];
        
        VVJSONSchema *schema = [internalSchemaFactory schemaWithDictionary:schemaObject error:&internalError];
        if (schema != nil) {
            [schemas addObject:schema];
        } else {
            success = NO;
            *stop = YES;
        }
    }];
    
    if (success) {
        return [schemas copy];
    } else {
        if (error != NULL) {
            *error = internalError;
        }
        return nil;
    }
}

+ (BOOL)validateSchemasArrayObject:(id)schemasArrayObject
{
    if ([schemasArrayObject isKindOfClass:[NSArray class]] == NO || [schemasArrayObject count] == 0) {
        return NO;
    }
    for (id item in schemasArrayObject) {
        if ([item isKindOfClass:[NSDictionary class]] == NO) {
            return NO;
        }
    }
    
    return YES;
}

- (NSArray<VVJSONSchema *> *)subschemas
{
    NSMutableArray<VVJSONSchema *> *subschemas = [NSMutableArray array];

    NSArray<VVJSONSchema *> *allOfSchemas = self.allOfSchemas;
    if (allOfSchemas != nil) {
        [subschemas addObjectsFromArray:allOfSchemas];
    }

    NSArray<VVJSONSchema *> *anyOfSchemas = self.anyOfSchemas;
    if (anyOfSchemas != nil) {
        [subschemas addObjectsFromArray:anyOfSchemas];
    }

    NSArray<VVJSONSchema *> *oneOfSchemas = self.oneOfSchemas;
    if (oneOfSchemas != nil) {
        [subschemas addObjectsFromArray:oneOfSchemas];
    }

    VVJSONSchema *notSchema = self.notSchema;
    if (notSchema != nil) {
        [subschemas addObject:notSchema];
    }
    
    return [subschemas copy];
}

- (BOOL)validateInstance:(id)instance inContext:(VVJSONSchemaValidationContext *)context error:(NSError *__autoreleasing *)error
{
    // validate "all" schemas
    NSArray<VVJSONSchema *> *allOfSchemas = self.allOfSchemas;
    if (allOfSchemas != nil) {
        for (VVJSONSchema *schema in allOfSchemas) {
            if ([schema validateObject:instance inContext:context error:error] == NO) {
                return NO;
            }
        }
    }
    
    // validate "any of" schemas
    NSArray<VVJSONSchema *> *anyOfSchemas = self.anyOfSchemas;
    if (anyOfSchemas != nil) {
        BOOL success = NO;
        for (VVJSONSchema *schema in anyOfSchemas) {
            // since multiple schemas from "any of" may fail, actual internal errors are not interesting
            success = [schema validateObject:instance inContext:context error:NULL];
            if (success) {
                // no need to check for more than one successful subschema
                break;
            }
        }
        
        if (success == NO) {
            if (error != NULL) {
                NSString *failureReason = @"No 'any of' subschemas satisfied the object.";
                *error = [NSError vv_JSONSchemaValidationErrorWithFailingValidator:self reason:failureReason context:context];
            }
            return NO;
        }
    }
    
    // validate "one of" schemas
    NSArray<VVJSONSchema *> *oneOfSchemas = self.oneOfSchemas;
    if (oneOfSchemas != nil) {
        NSUInteger counter = 0;
        for (VVJSONSchema *schema in oneOfSchemas) {
            // since multiple schemas from "one of" may fail, actual internal errors are not interesting
            if ([schema validateObject:instance inContext:context error:NULL]) {
                counter++;
            }
            if (counter > 1) {
                // no need to check for more than two successul subschemas
                break;
            }
        }
        
        if (counter == 0) {
            if (error != NULL) {
                NSString *failureReason = @"No 'one of' subschemas satisfied the object.";
                *error = [NSError vv_JSONSchemaValidationErrorWithFailingValidator:self reason:failureReason context:context];
            }
            return NO;
        }
        if (counter > 1) {
            if (error != NULL) {
                NSString *failureReason = @"More than one 'one of' subschema satisfied the object.";
                *error = [NSError vv_JSONSchemaValidationErrorWithFailingValidator:self reason:failureReason context:context];
            }
            return NO;
        }
    }
    
    // validate "not" schema
    VVJSONSchema *notSchema = self.notSchema;
    if (notSchema != nil) {
        BOOL success = [notSchema validateObject:instance inContext:context error:NULL];
        if (success) {
            if (error != NULL) {
                NSString *failureReason = @"The 'not' subschema must fail.";
                *error = [NSError vv_JSONSchemaValidationErrorWithFailingValidator:self reason:failureReason context:context];
            }
            return NO;
        }
    }
    
    return YES;
}

@end
