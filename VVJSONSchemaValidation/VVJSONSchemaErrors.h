//
//  VVJSONSchemaErrors.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 29/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVJSONSchemaValidator.h"
#import "VVJSONSchemaValidationContext.h"

NS_ASSUME_NONNULL_BEGIN

/** Domain of errors generated during instantiation and validation of JSON schemas. */
extern NSString * const VVJSONSchemaErrorDomain;
/** JSON schema errors user info key for an optional reference to the object that caused the error or its JSON representation. */
extern NSString * const VVJSONSchemaErrorFailingObjectKey;
/** JSON schema errors user info key for an optional reference to the validator that generated the error. */
extern NSString * const VVJSONSchemaErrorFailingValidatorKey;
/** JSON schema errors user info key for an optional path to the object that caused the error in the form of JSON Pointer. */
extern NSString * const VVJSONSchemaErrorFailingObjectPathKey;

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
    /** Attempted to register a format validator with already defined format name. */
    VVJSONSchemaErrorCodeFormatNameAlreadyDefined = 202,
    
    /** JSON instance validation against the schema failed. */
    VVJSONSchemaErrorCodeValidationFailed = 300,
    /** JSON instance validation got into an infinite loop. */
    VVJSONSchemaErrorCodeValidationInfiniteLoop = 301
};

@interface NSError (VVJSONSchemaError)

/**
 Calls `+vv_JSONSchemaErrorWithCode:failingObject:underlyingError:` with nil for `underlyingError`.
 */
+ (instancetype)vv_JSONSchemaErrorWithCode:(VVJSONSchemaErrorCode)code failingObject:(nullable id)failingObject;
/**
 Creates and returns an error object with `VVJSONSchemaErrorDomain` domain, specified error code, optional failing object and underlying error.
 @discussion This convenience method is intended to be used with error codes other than `VVJSONSchemaErrorCodeValidationFailed` - if the error is not related to actual JSON failing validation.
 @param code Error code.
 @param failingObject Object that caused the error. Depending on the error code, it might be a failing JSON Schema or invalid JSON instance, or anything else. Returned error will contain this object under `VVJSONSchemaErrorFailingObjectKey` key in `userInfo`, encoded back into a JSON string if possible. Can be nil.
 @param underlyingError Error that was encountered in an underlying implementation and caused the returned error. Returned error will contain this object under `NSUnderlyingErrorKey` key in `userInfo`. Can be nil.
 @return Configured error object.
 */
+ (instancetype)vv_JSONSchemaErrorWithCode:(VVJSONSchemaErrorCode)code failingObject:(nullable id)failingObject underlyingError:(nullable NSError *)underlyingError;
/**
 Creates and returns a validation error object with `VVJSONSchemaErrorDomain` domain, `VVJSONSchemaErrorCodeValidationFailed` error code.
 @discussion This convenience method is intended to be used for creating error objects caused by failing JSON validation. Validation context is used to infer current validated object and validation path stored in the returned error object. Validated object is encoded as a JSON string for human-readability.
 @param failingObject Object that caused the error (invalid JSON instance). Returned error will contain this object under `VVJSONSchemaErrorFailingObjectKey` key in `userInfo`, encoded back into a JSON string if possible. Must not be nil.
 @param failingValidator Validator object that failed JSON validation. Returned error will contain this object under `VVJSONSchemaErrorFailingValidatorKey` key in `userInfo`. Must not be nil.
 @param failureReason Validation reason as defined by the failing validator object. Returned error will contain this string in `localizedFailureReason`. Must not be nil.
 @return Configured error object.
 */
+ (instancetype)vv_JSONSchemaValidationErrorWithFailingValidator:(id<VVJSONSchemaValidator>)failingValidator reason:(NSString *)failureReason context:(VVJSONSchemaValidationContext *)validationContext;

@end

NS_ASSUME_NONNULL_END
