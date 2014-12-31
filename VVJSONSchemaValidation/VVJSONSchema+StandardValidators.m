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

@interface VVJSONSchema (StandardValidators)

@end

@implementation VVJSONSchema (StandardValidators)

+ (void)load
{
    // register all standard validators for default metaschema
    BOOL success = YES;
    success &= [self registerValidatorClass:[VVJSONSchemaDefinitions class] forMetaschemaURI:nil withError:NULL];
    success &= [self registerValidatorClass:[VVJSONSchemaTypeValidator class] forMetaschemaURI:nil withError:NULL];
    success &= [self registerValidatorClass:[VVJSONSchemaEnumValidator class] forMetaschemaURI:nil withError:NULL];
    success &= [self registerValidatorClass:[VVJSONSchemaNumericValidator class] forMetaschemaURI:nil withError:NULL];
    success &= [self registerValidatorClass:[VVJSONSchemaStringValidator class] forMetaschemaURI:nil withError:NULL];
    // TODO: array validator (maxitems, minitems, uniqueitems)
    // TODO: array items validator (items, additional items)
    // TODO: objects validator (max properties, min properties, required)
    // TODO: object properties validator (properties, patternProperties, additionalProperties)
    // TODO: dependencies validator (dependencies)
    // TODO: combining validator (allOf, anyOf, oneOf, not)
    // TODO: format validator
    
    if (success == NO) {
        [NSException raise:NSInternalInconsistencyException format:@"Failed to register standard JSON Schema validators."];
    }
}

@end
