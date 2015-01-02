//
//  VVJSONSchemaDefinitions.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 30/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchemaDefinitions.h"
#import "VVJSONSchemaFactory.h"
#import "VVJSONSchemaErrors.h"
#import "NSURL+VVJSONReferencing.h"

@implementation VVJSONSchemaDefinitions
{
    NSSet *_schemas;
}

static NSString * const kSchemaKeywordDefinitions = @"definitions";

- (instancetype)initWithSchemas:(NSSet *)schemas
{
    self = [super init];
    if (self) {
        _schemas = [schemas copy];
    }
    
    return self;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"{ %lu schemas }", (unsigned long)_schemas.count];
}

+ (NSSet *)assignedKeywords
{
    return [NSSet setWithObject:kSchemaKeywordDefinitions];
}

+ (instancetype)validatorWithDictionary:(NSDictionary *)schemaDictionary schemaFactory:(VVJSONSchemaFactory *)schemaFactory error:(NSError * __autoreleasing *)error
{
    // check that "definitions" is a dictionary
    id definitions = schemaDictionary[kSchemaKeywordDefinitions];
    if ([definitions isKindOfClass:[NSDictionary class]] == NO) {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaDictionary failingValidator:nil];
        }
        return nil;
    }
    
    // parse the subschemas
    NSMutableSet *schemas = [NSMutableSet setWithCapacity:[definitions count]];
    __block BOOL success = YES;
    __block NSError *internalError = nil;
    [definitions enumerateKeysAndObjectsUsingBlock:^(NSString *key, id schemaObject, BOOL *stop) {
        if ([schemaObject isKindOfClass:[NSDictionary class]] == NO) {
            internalError = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaObject failingValidator:nil];
            success = NO;
            *stop = YES;
            return;
        }
        
        // each subschema has its resolution scope extended by "definitions/[schema_name]"
        VVJSONSchemaFactory *definitionFactory = [schemaFactory factoryByAppendingScopeComponentsFromArray:@[ kSchemaKeywordDefinitions, key ]];
        
        VVJSONSchema *schema = [definitionFactory schemaWithDictionary:schemaObject error:&internalError];
        if (schema != nil) {
            [schemas addObject:schema];
        } else {
            success = NO;
            *stop = YES;
            return;
        }
    }];
    
    if (success) {
        return [[self alloc] initWithSchemas:schemas];
    } else {
        if (error != NULL) {
            *error = internalError;
        }
        return nil;
    }
}

- (NSSet *)subschemas
{
    return _schemas;
}

- (BOOL)validateInstance:(id)instance withError:(NSError * __autoreleasing *)error
{
    // definitions "validator" always succeeds
    return YES;
}

@end
