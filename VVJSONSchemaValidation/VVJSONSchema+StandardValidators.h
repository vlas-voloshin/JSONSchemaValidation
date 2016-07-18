//
//  VVJSONSchema+StandardValidators.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 12/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchema.h"
#import "VVJSONSchemaDefinitions.h"
#import "VVJSONSchemaTypeValidator.h"
#import "VVJSONSchemaEnumValidator.h"
#import "VVJSONSchemaNumericValidator.h"
#import "VVJSONSchemaStringValidator.h"
#import "VVJSONSchemaArrayValidator.h"
#import "VVJSONSchemaArrayItemsValidator.h"
#import "VVJSONSchemaObjectValidator.h"
#import "VVJSONSchemaObjectPropertiesValidator.h"
#import "VVJSONSchemaDependenciesValidator.h"
#import "VVJSONSchemaCombiningValidator.h"
#import "VVJSONSchemaFormatValidator.h"

NS_ASSUME_NONNULL_BEGIN

/** This category provides a loading point for standard JSON Schema draft 4 validators. */
@interface VVJSONSchema (StandardValidators)

@end

NS_ASSUME_NONNULL_END
