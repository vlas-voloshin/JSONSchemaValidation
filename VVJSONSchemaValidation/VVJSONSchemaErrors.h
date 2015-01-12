//
//  VVJSONSchemaErrors.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 29/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVJSONSchemaValidator.h"

/** Domain of errors generated during instantiation and validation of JSON schemas. */
extern NSString * const VVJSONSchemaErrorDomain;
/** JSON schema errors user info key for an optional reference to the object that caused the error. */
extern NSString * const VVJSONSchemaErrorFailingObjectKey;
/** JSON schema errors user info key for an optional reference to the validator that generated the error. */
extern NSString * const VVJSONSchemaErrorFailingValidatorKey;

/** Defines error codes in `VVJSONSchemaErrorDomain`. */
typedef NS_ENUM(NSUInteger, VVJSONSchemaErrorCode) {
    /** Specified JSON Schema was created using incompatible metaschema, as denoted by its "$schema" keyword. */
    VVJSONSchemaErrorCodeIncompatibleMetaschema = 100,
    /** Specified JSON Schema is invalid. */
    VVJSONSchemaErrorCodeInvalidSchemaFormat = 101,
    /** Specified JSON Schema contains invalid resolution scope URI. */
    VVJSONSchemaErrorCodeInvalidResolutionScope = 102,
    /** Specified JSON Schema or Schema Storage contains duplicate resolution scope URIs. */
    VVJSONSchemaErrorCodeDuplicateResolutionScope = 103,
    /** Specified JSON Schema contains an invalid schema reference. */
    VVJSONSchemaErrorCodeInvalidSchemaReference = 104,
    /** Specified JSON Schema contains an unresolvable schema reference. */
    VVJSONSchemaErrorCodeUnresolvableSchemaReference = 105,
    /** Specified JSON Schema contains a schema reference cycle. */
    VVJSONSchemaErrorCodeReferenceCycle = 106,
    /** Specified JSON Schema contains an invalid regular expression in one of its validators. */
    VVJSONSchemaErrorCodeInvalidRegularExpression = 107,
    
    /** Attempted to register a validator class with no assigned keywords. */
    VVJSONSchemaErrorCodeNoValidatorKeywordsDefined = 200,
    /** Attempted to register a validator class that defines already registered keywords. */
    VVJSONSchemaErrorCodeValidatorKeywordAlreadyDefined = 201,
    
    /** JSON instance validation against the schema failed. */
    VVJSONSchemaErrorCodeValidationFailed = 300,
    /** JSON instance validation got into an infinite loop. */
    VVJSONSchemaErrorCodeValidationInfiniteLoop = 301
};

@interface NSError (VVJSONSchemaError)

/**
 Creates and returns an error object with `VVJSONSchemaErrorDomain` domain, specified error code and optional objects for `userInfo`.
 @param code Error code.
 @param failingObject Object that caused the error. Depending on the error code, it might be a failing JSON Schema or invalid JSON instance, or anything else. Returned error will contain this object under `VVJSONSchemaErrorFailingObjectKey` key in `userInfo`.
 @param failingValidator If error is caused by invalid JSON instance, this parameter should be the validator object that failed validation. Returned error will contain this object under `VVJSONSchemaErrorFailingValidatorKey` key in `userInfo`.
 @return Configured error object.
 */
+ (instancetype)vv_JSONSchemaErrorWithCode:(VVJSONSchemaErrorCode)code failingObject:(id)failingObject failingValidator:(id<VVJSONSchemaValidator>)failingValidator;

@end
