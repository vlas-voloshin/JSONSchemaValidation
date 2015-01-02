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

@interface VVJSONSchemaCombiningValidator : NSObject <VVJSONSchemaValidator>

@property (nonatomic, readonly, copy) NSArray *allOfSchemas;
@property (nonatomic, readonly, copy) NSArray *anyOfSchemas;
@property (nonatomic, readonly, copy) NSArray *oneOfSchemas;
@property (nonatomic, readonly, copy) VVJSONSchema *notSchema;

@end
