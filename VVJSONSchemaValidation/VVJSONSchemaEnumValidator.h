//
//  VVJSONSchemaEnumValidator.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 31/12/2014.
//  Copyright (c) 2014 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVJSONSchemaValidator.h"

@interface VVJSONSchemaEnumValidator : NSObject <VVJSONSchemaValidator>

@property (nonatomic, readonly, strong) NSArray *valueOptions;

@end
