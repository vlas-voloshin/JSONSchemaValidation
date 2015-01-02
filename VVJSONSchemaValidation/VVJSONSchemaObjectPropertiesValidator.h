//
//  VVJSONSchemaObjectPropertiesValidator.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 1/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVJSONSchemaValidator.h"

@class VVJSONSchema;

@interface VVJSONSchemaObjectPropertiesValidator : NSObject <VVJSONSchemaValidator>

/** Keys are property names, values are schemas. */
@property (nonatomic, readonly, copy) NSDictionary *propertySchemas;

@property (nonatomic, readonly, strong) VVJSONSchema *additionalPropertiesSchema;
@property (nonatomic, readonly, assign) BOOL additionalPropertiesAllowed;

/** Keys are regular expressions, values are schemas. */
@property (nonatomic, readonly, copy) NSDictionary *patternBasedPropertySchemas;

@end
