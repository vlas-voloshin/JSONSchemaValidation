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

NS_ASSUME_NONNULL_BEGIN

/**
 Implements "dependencies" keyword. Applicable to object instances.
 */
@interface VVJSONSchemaDependenciesValidator : NSObject <VVJSONSchemaValidator>

/**
 Dictionary of schema dependencies: keys are property names, values are schemas. If an object instance contains a property with name among the keys of this dictionary, it must also validate against the corresponding schema value.
 */
@property (nonatomic, readonly, copy) NSDictionary<NSString *, VVJSONSchema *> *schemaDependencies;
/**
 Dictionary of property dependencies: keys are property names, values are sets of property names. If an object instance contains a property with name among the keys of this dictionary, it must also contain properties with names from the corresponding set value.
 */
@property (nonatomic, readonly, copy) NSDictionary<NSString *, NSSet<NSString *> *> *propertyDependencies;

@end

NS_ASSUME_NONNULL_END
