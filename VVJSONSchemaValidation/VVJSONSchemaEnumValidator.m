//
//  VVJSONSchemaEnumValidator.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 31/12/2014.
//  Copyright (c) 2014 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchemaEnumValidator.h"
#import "VVJSONSchemaErrors.h"

@implementation VVJSONSchemaEnumValidator

static NSString * const kSchemaKeywordEnum = @"enum";

- (instancetype)initWithValueOptions:(NSSet *)valueOptions
{
    self = [super init];
    if (self) {
        _valueOptions = [valueOptions copy];
    }
    
    return self;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"{ %lu options }", (unsigned long)self.valueOptions.count];
}

+ (NSSet *)assignedKeywords
{
    return [NSSet setWithObject:kSchemaKeywordEnum];
}

+ (instancetype)validatorWithDictionary:(NSDictionary *)schemaDictionary schemaFactory:(VVJSONSchemaFactory *)schemaFactory error:(NSError *__autoreleasing *)error
{
    id enumObject = schemaDictionary[kSchemaKeywordEnum];
    
    // enum must be an array
    if ([enumObject isKindOfClass:[NSArray class]]) {
        NSSet *enumOptions = [NSSet setWithArray:enumObject];

        // enum array must not contain zero elements or have duplicate elements
        if (enumOptions.count != 0 && enumOptions.count == [enumObject count]) {
            return [[self alloc] initWithValueOptions:enumOptions];
        }
    }
    
    if (error != NULL) {
        *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaDictionary failingValidator:nil];
    }
    return nil;
}

- (NSSet *)subschemas
{
    return nil;
}

- (BOOL)validateInstance:(id)instance withError:(NSError *__autoreleasing *)error
{
    if ([self.valueOptions containsObject:instance]) {
        return YES;
    } else {
        if (*error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeValidationFailed failingObject:instance failingValidator:self];
        }
        return NO;
    }
}

@end
