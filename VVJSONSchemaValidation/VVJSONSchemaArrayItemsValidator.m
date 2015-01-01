//
//  VVJSONSchemaArrayItemsValidator.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 1/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchemaArrayItemsValidator.h"
#import "VVJSONSchema.h"
#import "VVJSONSchemaFactory.h"
#import "VVJSONSchemaErrors.h"
#import "NSNumber+VVJSONNumberTypes.h"

@implementation VVJSONSchemaArrayItemsValidator

static NSString * const kSchemaKeywordItems = @"items";
static NSString * const kSchemaKeywordAdditionalItems = @"additionalItems";

- (instancetype)initWithItemsSchema:(VVJSONSchema *)itemsSchema orItemSchemas:(NSArray *)itemSchemas additionalItemsSchema:(VVJSONSchema *)additionalItemsSchema additionalItemsAllowed:(BOOL)additionalItemsAllowed
{
    NSAssert(itemsSchema == nil || itemSchemas == nil, @"Can either have single item schema or item schemas array.");
    NSAssert(additionalItemsSchema == nil || additionalItemsAllowed, @"Cannot have additional items schema if additional items are not allowed.");
    
    self = [super init];
    if (self) {
        _itemsSchema = itemsSchema;
        _itemSchemas = [itemSchemas copy];
        _additionalItemsSchema = additionalItemsSchema;
        _additionalItemsAllowed = additionalItemsAllowed;
    }
    
    return self;
}

- (NSString *)description
{
    NSString *itemSchemasDescription;
    if (self.itemsSchema != nil) {
        itemSchemasDescription = self.itemsSchema.description;
    } else {
        itemSchemasDescription = [NSString stringWithFormat:@"%lu schemas", (unsigned long)self.itemSchemas.count];
    }
    
    NSString *additionalItemsDescription;
    if (self.additionalItemsSchema != nil) {
        additionalItemsDescription = self.additionalItemsSchema.description;
    } else {
        additionalItemsDescription = (self.additionalItemsAllowed ? @"allowed" : @"not allowed");
    }
    
    return [[super description] stringByAppendingFormat:@"{ items: %@; additional items: %@ }", itemSchemasDescription, additionalItemsDescription];
}

+ (NSSet *)assignedKeywords
{
    return [NSSet setWithArray:@[ kSchemaKeywordItems, kSchemaKeywordAdditionalItems ]];
}

+ (instancetype)validatorWithDictionary:(NSDictionary *)schemaDictionary schemaFactory:(VVJSONSchemaFactory *)schemaFactory error:(NSError * __autoreleasing *)error
{
    id itemsObject = schemaDictionary[kSchemaKeywordItems];
    id additionalItemsObject = schemaDictionary[kSchemaKeywordAdditionalItems];
    
    // parse items keyword
    VVJSONSchema *itemsSchema = nil;
    NSArray *itemSchemas = nil;
    if ([itemsObject isKindOfClass:[NSDictionary class]]) {
        // parse as a schema object; schema will have scope extended by "/items"
        VVJSONSchemaFactory *itemsSchemaFactory = [schemaFactory factoryByAppendingScopeComponent:kSchemaKeywordItems];
        itemsSchema = [itemsSchemaFactory schemaWithDictionary:itemsObject error:error];
        if (itemsSchema == nil) {
            return nil;
        }
    } else if ([itemsObject isKindOfClass:[NSArray class]]) {
        // parse as a schemas array
        NSMutableArray *schemas = [NSMutableArray arrayWithCapacity:[itemsObject count]];
        
        __block BOOL success = YES;
        __block NSError *internalError = nil;
        [itemsObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            // schema object must be a dictionary
            if ([obj isKindOfClass:[NSDictionary class]]) {
                // each schema will have scope extended by "/items/#" where # is its index
                NSString *scopeExtension = [kSchemaKeywordItems stringByAppendingPathComponent:[NSString stringWithFormat:@"%lu", (unsigned long)idx]];
                VVJSONSchemaFactory *itemSchemaFactory = [schemaFactory factoryByAppendingScopeComponent:scopeExtension];
                
                VVJSONSchema *itemSchema = [itemSchemaFactory schemaWithDictionary:obj error:&internalError];
                if (itemSchema != nil) {
                    [schemas addObject:itemSchema];
                } else {
                    success = NO;
                }
            } else {
                success = NO;
                internalError = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:itemsObject failingValidator:nil];
            }
            
            if (success == NO) {
                *stop = YES;
            }
        }];
        
        if (success) {
            itemSchemas = [schemas copy];
        } else {
            if (error != NULL) {
                *error = internalError;
            }
            return nil;
        }
    } else if (itemsObject != nil) {
        // invalid instance
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaDictionary failingValidator:nil];
        }
        return nil;
    }
    
    // parse additionalItems keyword
    VVJSONSchema *additionalItemsSchema = nil;
    BOOL additionalItemsAllowed = YES;
    if ([additionalItemsObject isKindOfClass:[NSDictionary class]]) {
        // parse as a schema object; schema will have scope extended by "/additionalItems"
        VVJSONSchemaFactory *additionalSchemaFactory = [schemaFactory factoryByAppendingScopeComponent:kSchemaKeywordAdditionalItems];
        additionalItemsSchema = [additionalSchemaFactory schemaWithDictionary:additionalItemsObject error:error];
        if (additionalItemsSchema == nil) {
            return nil;
        }
    } else if ([additionalItemsObject isKindOfClass:[NSNumber class]] && [additionalItemsObject vv_isBoolean]) {
        // parse as a boolean
        additionalItemsAllowed = [additionalItemsObject boolValue];
    } else if (additionalItemsObject != nil) {
        // invalid instance
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaDictionary failingValidator:nil];
        }
        return nil;
    }
    
    return [[self alloc] initWithItemsSchema:itemsSchema orItemSchemas:itemSchemas additionalItemsSchema:additionalItemsSchema additionalItemsAllowed:additionalItemsAllowed];
}

- (NSSet *)subschemas
{
    NSMutableSet *subschemas = [NSMutableSet set];
    if (self.itemsSchema != nil) {
        [subschemas addObject:self.itemsSchema];
    }
    if (self.itemSchemas != nil) {
        [subschemas addObjectsFromArray:self.itemSchemas];
    }
    if (self.additionalItemsSchema != nil) {
        [subschemas addObject:self.additionalItemsSchema];
    }
    
    return [subschemas copy];
}

- (BOOL)validateInstance:(id)instance withError:(NSError * __autoreleasing *)error
{
    // silently succeed if value of the instance is inapplicable
    if ([instance isKindOfClass:[NSArray class]] == NO) {
        return YES;
    }
    
    // validate each item with the corresponding schema
    __block BOOL success = YES;
    [instance enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop) {
        BOOL schemaFailure = NO;
        VVJSONSchema *schema = [self schemaForInstanceItemAtIndex:idx failure:&schemaFailure];
        if (schema != nil) {
            if ([schema validateObject:item withError:error] == NO) {
                success = NO;
                *stop = YES;
            }
        } else if (schemaFailure) {
            success = NO;
            *stop = YES;
        }
    }];
    
    if (success == NO) {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeValidationFailed failingObject:instance failingValidator:self];
        }
    }
    
    return success;
}

- (VVJSONSchema *)schemaForInstanceItemAtIndex:(NSUInteger)itemIndex failure:(BOOL *)failure
{
    if (self.itemsSchema != nil) {
        // item schemas are defined as a single schema - return this schema
        return self.itemsSchema;
    } else if (self.itemSchemas != nil) {
        // item schemas are defined as an array
        if (itemIndex < self.itemSchemas.count) {
            // item index is within bounds of the schema array - return schema at that index
            return self.itemSchemas[itemIndex];
        } else {
            // otherwise, respect the additional items configuration
            if (self.additionalItemsSchema != nil) {
                // additional items schema is defined - return this schema
                return self.additionalItemsSchema;
            } else if (self.additionalItemsAllowed) {
                // additional items schema is not defined, but any additional items are allowed
                return nil;
            } else {
                // additional items are not allowed
                *failure = YES;
                return nil;
            }
        }
    } else {
        // if item schemas are defined neither as a single schema nor a schema array,
        // it is equivalent to defining a single empty schema, which means any instance is valid,
        // regardless of "additional items" configuration
        return nil;
    }
}

@end
