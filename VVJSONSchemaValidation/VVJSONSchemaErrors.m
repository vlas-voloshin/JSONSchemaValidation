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
NSString * const VVJSONSchemaErrorFailingObjectPathKey = @"path";

@implementation NSError (VVJSONSchemaError)

+ (instancetype)vv_JSONSchemaErrorWithCode:(VVJSONSchemaErrorCode)code failingObject:(id)failingObject
{
    return [self vv_JSONSchemaErrorWithCode:code failingObject:failingObject underlyingError:nil];
}

+ (instancetype)vv_JSONSchemaErrorWithCode:(VVJSONSchemaErrorCode)code failingObject:(id)failingObject underlyingError:(NSError *)underlyingError
{
    NSMutableDictionary<NSString *, id> *userInfo = [NSMutableDictionary dictionary];
    if (failingObject != nil) {
        userInfo[VVJSONSchemaErrorFailingObjectKey] = [self vv_jsonDescriptionForObject:failingObject];
    }
    if (underlyingError != nil) {
        userInfo[NSUnderlyingErrorKey] = underlyingError;
    }
    
    NSString *localizedDescription = [self vv_localizedDescriptionForErrorCode:code];
    if (localizedDescription != nil) {
        userInfo[NSLocalizedDescriptionKey] = localizedDescription;
    }
    
    return [NSError errorWithDomain:VVJSONSchemaErrorDomain code:code userInfo:[userInfo copy]];
}

+ (instancetype)vv_JSONSchemaValidationErrorWithFailingValidator:(id<VVJSONSchemaValidator>)failingValidator reason:(NSString *)failureReason context:(VVJSONSchemaValidationContext *)validationContext
{
    NSParameterAssert(failingValidator);
    NSParameterAssert(failureReason);
    NSParameterAssert(validationContext);
    
    NSMutableDictionary<NSString *, id> *userInfo = [NSMutableDictionary dictionary];
    userInfo[VVJSONSchemaErrorFailingObjectKey] = [self vv_jsonDescriptionForObject:validationContext.validatedObject];
    userInfo[VVJSONSchemaErrorFailingValidatorKey] = failingValidator;
    userInfo[VVJSONSchemaErrorFailingObjectPathKey] = validationContext.validationPath;
    userInfo[NSLocalizedFailureReasonErrorKey] = failureReason;
    
    NSString *localizedDescription = [self vv_localizedDescriptionForErrorCode:VVJSONSchemaErrorCodeValidationFailed];
    if (localizedDescription != nil) {
        userInfo[NSLocalizedDescriptionKey] = localizedDescription;
    }
    
    return [NSError errorWithDomain:VVJSONSchemaErrorDomain code:VVJSONSchemaErrorCodeValidationFailed userInfo:[userInfo copy]];
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
            
        case VVJSONSchemaErrorCodeFormatNameAlreadyDefined:
            return NSLocalizedString(@"Attempted to register a format validator with already defined format name.", nil);
            
        case VVJSONSchemaErrorCodeValidationFailed:
            return NSLocalizedString(@"JSON instance validation against the schema failed.", nil);
            
        case VVJSONSchemaErrorCodeValidationInfiniteLoop:
            return NSLocalizedString(@"JSON instance validation got into an infinite loop.", nil);
            
        default:
            return nil;
    }
}

+ (id)vv_jsonDescriptionForObject:(id)object
{
    if ([NSJSONSerialization isValidJSONObject:object]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:NULL];
        if (data != nil) {
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    
    // If object cannot be serialized back into JSON or an error occurred, just return it as-is
    return object;
}

@end
