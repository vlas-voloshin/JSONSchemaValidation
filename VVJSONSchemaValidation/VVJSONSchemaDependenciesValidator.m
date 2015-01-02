//
//  VVJSONSchemaDependenciesValidator.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 1/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchemaDependenciesValidator.h"
#import "VVJSONSchema.h"
#import "VVJSONSchemaFactory.h"
#import "VVJSONSchemaErrors.h"
#import "NSArray+VVJSONComparison.h"

@implementation VVJSONSchemaDependenciesValidator

static NSString * const kSchemaKeywordDependencies = @"dependencies";

- (instancetype)initWithSchemaDependencies:(NSDictionary *)schemaDependencies propertyDependencies:(NSDictionary *)propertyDependencies
{
    self = [super init];
    if (self) {
        _schemaDependencies = [schemaDependencies copy];
        _propertyDependencies = [propertyDependencies copy];
    }
    
    return self;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"{ %lu schema dependencies; %lu property dependencies }", (unsigned long)self.schemaDependencies.count, (unsigned long)self.propertyDependencies.count];
}

+ (NSSet *)assignedKeywords
{
    return [NSSet setWithObject:kSchemaKeywordDependencies];
}

+ (instancetype)validatorWithDictionary:(NSDictionary *)schemaDictionary schemaFactory:(VVJSONSchemaFactory *)schemaFactory error:(NSError * __autoreleasing *)error
{
    id dependencies = schemaDictionary[kSchemaKeywordDependencies];
    
    // dependencies must be a dictionary
    if ([dependencies isKindOfClass:[NSDictionary class]] == NO) {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaDictionary failingValidator:nil];
        }
        return nil;
    }
    
    NSMutableDictionary *schemaDependencies = [NSMutableDictionary dictionary];
    NSMutableDictionary *propertyDependencies = [NSMutableDictionary dictionary];
    
    // parse the dependencies
    __block BOOL success = YES;
    __block NSError *internalError = nil;
    [dependencies enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, id dependencyObject, BOOL *stop) {
        if ([dependencyObject isKindOfClass:[NSDictionary class]]) {
            // dependency object is a dictionary - parse it as a schema dependency;
            // schema will have scope extended by "/dependencies/#" where # is dependent property name
            VVJSONSchemaFactory *dependencySchemaFactory = [schemaFactory factoryByAppendingScopeComponentsFromArray:@[ kSchemaKeywordDependencies, propertyName ]];
            
            VVJSONSchema *dependencySchema = [dependencySchemaFactory schemaWithDictionary:dependencyObject error:&internalError];
            if (dependencySchema != nil) {
                schemaDependencies[propertyName] = dependencySchema;
            } else {
                *stop = YES;
                success = NO;
            }
        } else if ([dependencyObject isKindOfClass:[NSArray class]]) {
            // dependency object is an array - parse it as a property dependency;
            // each property names array must be non-empty and contain unique strings
            for (id dependentProperty in dependencyObject) {
                if ([dependentProperty isKindOfClass:[NSString class]] == NO) {
                    *stop = YES;
                    success = NO;
                    return;
                }
            }
            
            NSSet *dependentPropertiesSet = [NSSet setWithArray:dependencyObject];
            if (dependentPropertiesSet.count == 0 || dependentPropertiesSet.count != [dependencyObject count]) {
                *stop = YES;
                success = NO;
                return;
            }
            
            propertyDependencies[propertyName] = dependentPropertiesSet;
        } else {
            // invalid dependency object
            *stop = YES;
            success = NO;
        }
    }];
    
    if (success) {
        return [[self alloc] initWithSchemaDependencies:schemaDependencies propertyDependencies:propertyDependencies];
    } else {
        if (error != NULL) {
            *error = internalError ?: [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaDictionary failingValidator:nil];
        }
        return nil;
    }
}

- (NSSet *)subschemas
{
    return [NSSet setWithArray:self.schemaDependencies.allValues];
}

- (BOOL)validateInstance:(id)instance withError:(NSError * __autoreleasing *)error
{
    // silently succeed if value of the instance is inapplicable
    if ([instance isKindOfClass:[NSDictionary class]] == NO) {
        return YES;
    }
    
    NSSet *propertyNames = [NSSet setWithArray:[instance allKeys]];
    __block BOOL success = YES;

    // validate property dependencies
    [self.propertyDependencies enumerateKeysAndObjectsUsingBlock:^(NSString *property, NSSet *dependingProperties, BOOL *stop) {
        if ([propertyNames containsObject:property]) {
            if ([dependingProperties isSubsetOfSet:propertyNames] == NO) {
                success = NO;
                *stop = YES;
            }
        }
    }];
    if (success == NO) {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeValidationFailed failingObject:instance failingValidator:self];
        }
        return NO;
    }
    
    // validate schema dependencies
    __block NSError *internalError;
    [self.schemaDependencies enumerateKeysAndObjectsUsingBlock:^(NSString *property, VVJSONSchema *schema, BOOL *stop) {
        if ([propertyNames containsObject:property]) {
            if ([schema validateObject:instance withError:&internalError] == NO) {
                success = NO;
                *stop = YES;
            }
        }
    }];
    if (success == NO) {
        if (error != NULL) {
            *error = internalError;
        }
    }
    
    return success;
}

@end
