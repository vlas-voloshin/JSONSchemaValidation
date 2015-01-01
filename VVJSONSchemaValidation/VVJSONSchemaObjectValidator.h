//
//  VVJSONSchemaObjectValidator.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 1/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVJSONSchemaValidator.h"

@interface VVJSONSchemaObjectValidator : NSObject <VVJSONSchemaValidator>

@property (nonatomic, readonly, assign) NSUInteger maximumProperties;
@property (nonatomic, readonly, assign) NSUInteger minimumProperties;
@property (nonatomic, readonly, copy) NSSet *requiredProperties;

@end
