//
//  VVJSONSchemaErrors.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 29/12/2014.
//  Copyright (c) 2014 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVJSONInstanceValidator.h"

extern NSString * const VVJSONSchemaErrorDomain;
extern NSString * const VVJSONSchemaErrorFailingObjectKey;
extern NSString * const VVJSONSchemaErrorFailingValidatorKey;

typedef NS_ENUM(NSUInteger, VVJSONSchemaErrorCode) {
    VVJSONSchemaErrorCodeIncompatibleMetaschema = 100,
    VVJSONSchemaErrorCodeInvalidSchemaFormat = 101,
    VVJSONSchemaErrorCodeInvalidResolutionScope = 102,
    VVJSONSchemaErrorCodeDuplicateResolutionScope = 103,
    VVJSONSchemaErrorCodeInvalidSchemaReference = 104,
    VVJSONSchemaErrorCodeUnresolvableSchemaReference = 105,
    VVJSONSchemaErrorCodeReferenceCycle = 106,
    VVJSONSchemaErrorCodeInvalidRegularExpression = 107,
    
    VVJSONSchemaErrorCodeNoValidatorKeywordsDefined = 200,
    VVJSONSchemaErrorCodeValidatorKeywordAlreadyDefined = 201,
    
    VVJSONSchemaErrorCodeValidationFailed = 300
};

@interface NSError (VVJSONSchemaError)

+ (instancetype)vv_JSONSchemaErrorWithCode:(VVJSONSchemaErrorCode)code failingObject:(id)failingObject failingValidator:(id<VVJSONInstanceValidator>)failingValidator;

@end
