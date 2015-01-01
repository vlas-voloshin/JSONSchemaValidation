//
//  VVJSONSchema+StandardValidators.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 30/12/2014.
//  Copyright (c) 2014 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchema.h"
#import "VVJSONSchemaDefinitions.h"
#import "VVJSONSchemaTypeValidator.h"
#import "VVJSONSchemaEnumValidator.h"
#import "VVJSONSchemaNumericValidator.h"
#import "VVJSONSchemaStringValidator.h"
#import "VVJSONSchemaArrayValidator.h"
#import "VVJSONSchemaArrayItemsValidator.h"

@interface VVJSONSchema (StandardValidators)

@end

@implementation VVJSONSchema (StandardValidators)

+ (void)load
{
    // register all standard validators for default metaschema
    NSArray *validatorClasses = @[ [VVJSONSchemaDefinitions class], [VVJSONSchemaTypeValidator class], [VVJSONSchemaEnumValidator class], [VVJSONSchemaNumericValidator class], [VVJSONSchemaStringValidator class], [VVJSONSchemaArrayValidator class], [VVJSONSchemaArrayItemsValidator class] ];
    // TODO: objects validator (max properties, min properties, required)
    // TODO: object properties validator (properties, patternProperties, additionalProperties)
    // TODO: dependencies validator (dependencies)
    // TODO: combining validator (allOf, anyOf, oneOf, not)
    // TODO: format validator
    
    for (Class<VVJSONSchemaValidator> validatorClass in validatorClasses) {
        if ([self registerValidatorClass:validatorClass forMetaschemaURI:nil withError:NULL] == NO) {
            [NSException raise:NSInternalInconsistencyException format:@"Failed to register standard JSON Schema validators."];
        }
    }
}

@end
