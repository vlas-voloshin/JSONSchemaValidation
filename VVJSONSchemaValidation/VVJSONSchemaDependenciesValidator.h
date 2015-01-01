//
//  VVJSONSchemaDependenciesValidator.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 1/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVJSONSchemaValidator.h"

@class VVJSONSchema;

@interface VVJSONSchemaDependenciesValidator : NSObject <VVJSONSchemaValidator>

/** Keys are property names, values are schemas. */
@property (nonatomic, readonly, copy) NSDictionary *schemaDependencies;
/** Keys are property names, values are sets of property names. */
@property (nonatomic, readonly, copy) NSDictionary *propertyDependencies;

@end
