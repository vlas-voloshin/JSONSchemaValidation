//
//  VVJSONSchemaNumericValidator.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 30/12/2014.
//  Copyright (c) 2014 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVJSONSchemaValidator.h"

@interface VVJSONSchemaNumericValidator : NSObject <VVJSONSchemaValidator>

@property (nonatomic, readonly, strong) NSDecimalNumber *multipleOf;

@property (nonatomic, readonly, strong) NSNumber *maximum;
@property (nonatomic, readonly, assign) BOOL exclusiveMaximum;

@property (nonatomic, readonly, strong) NSNumber *minimum;
@property (nonatomic, readonly, assign) BOOL exclusiveMinimum;

@end
