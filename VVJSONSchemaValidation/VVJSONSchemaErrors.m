//
//  VVJSONSchemaErrors.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 29/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchemaErrors.h"

NSString * const VVJSONSchemaErrorDomain = @"com.argentumko.JSONSchemaValidationError";
NSString * const VVJSONSchemaErrorFailingObjectKey = @"object";
NSString * const VVJSONSchemaErrorFailingValidatorKey = @"validator";

@implementation NSError (VVJSONSchemaError)

+ (instancetype)vv_JSONSchemaErrorWithCode:(VVJSONSchemaErrorCode)code failingObject:(id)failingObject failingValidator:(id<VVJSONSchemaValidator>)failingValidator
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (failingObject != nil) {
        userInfo[VVJSONSchemaErrorFailingObjectKey] = failingObject;
    }
    if (failingValidator != nil) {
        userInfo[VVJSONSchemaErrorFailingValidatorKey] = failingValidator;
    }
    
    NSString *localizedDescription = [self vv_localizedDescriptionForErrorCode:code];
    if (localizedDescription != nil) {
        userInfo[NSLocalizedDescriptionKey] = localizedDescription;
    }
    
    return [NSError errorWithDomain:VVJSONSchemaErrorDomain code:code userInfo:[userInfo copy]];
}

+ (NSString *)vv_localizedDescriptionForErrorCode:(VVJSONSchemaErrorCode)errorCode
{
    switch (errorCode) {
        case VVJSONSchemaErrorCodeIncompatibleMetaschema:
            return NSLocalizedString(@"Specified JSON Schema was created using incompatible metaschema, as denoted by its '$schema' keyword.", nil);

        case VVJSONSchemaErrorCodeInvalidSchemaFormat:
            return NSLocalizedString(@"Specified JSON Schema is not a valid schema.", nil);
            
        case VVJSONSchemaErrorCodeInvalidResolutionScope:
            return NSLocalizedString(@"Specified JSON Schema contains invalid resolution scope URI.", nil);
            
        case VVJSONSchemaErrorCodeDuplicateResolutionScope:
            return NSLocalizedString(@"Specified JSON Schema or Schema Storage contains duplicate resolution scope URIs.", nil);
            
        case VVJSONSchemaErrorCodeInvalidSchemaReference:
            return NSLocalizedString(@"Specified JSON Schema contains an invalid schema reference.", nil);
            
        case VVJSONSchemaErrorCodeUnresolvableSchemaReference:
            return NSLocalizedString(@"Failed to resolve a schema reference in the specified JSON Schema.", nil);
            
        case VVJSONSchemaErrorCodeReferenceCycle:
            return NSLocalizedString(@"Specified JSON Schema contains a schema reference cycle.", nil);
            
        case VVJSONSchemaErrorCodeInvalidRegularExpression:
            return NSLocalizedString(@"Specified JSON Schema contains an invalid regular expression in one of its validators.", nil);
            
        case VVJSONSchemaErrorCodeNoValidatorKeywordsDefined:
            return NSLocalizedString(@"Attempted to register a validator class with no assigned keywords.", nil);
            
        case VVJSONSchemaErrorCodeValidatorKeywordAlreadyDefined:
            return NSLocalizedString(@"Attempted to register a validator class that defines already registered keywords.", nil);
            
        case VVJSONSchemaErrorCodeValidationFailed:
            return NSLocalizedString(@"JSON instance validation against the schema failed.", nil);
            
        case VVJSONSchemaErrorCodeValidationInfiniteLoop:
            return NSLocalizedString(@"JSON instance validation got into an infinite loop.", nil);
            
        default:
            return nil;
    }
}

@end
