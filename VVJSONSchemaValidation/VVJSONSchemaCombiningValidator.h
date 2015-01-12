//
//  VVJSONSchemaCombiningValidator.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 2/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVJSONSchemaValidator.h"

@class VVJSONSchema;

/**
 Implements "allOf", "anyOf", "oneOf" and "not" keywords. Applicable to all instance types.
 */
@interface VVJSONSchemaCombiningValidator : NSObject <VVJSONSchemaValidator>

/** A valid instance must be valid against all schemas in this property, unless it is nil. */
@property (nonatomic, readonly, copy) NSArray *allOfSchemas;
/** A valid instance must be valid against at least one schema in this property, unless it is nil. */
@property (nonatomic, readonly, copy) NSArray *anyOfSchemas;
/** A valid instance must be valid against exactly one schema in this property, unless it is nil. */
@property (nonatomic, readonly, copy) NSArray *oneOfSchemas;
/** A valid instance must *not* be valid against this schema, unless it is nil. */
@property (nonatomic, readonly, copy) VVJSONSchema *notSchema;

@end
