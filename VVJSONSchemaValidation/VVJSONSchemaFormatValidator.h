//
//  VVJSONSchemaFormatValidator.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 3/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVJSONSchemaValidator.h"

/**
 Implements "format" keyword. Applicable to all instance types, though currently only string instances can be valid against standard formats.
 */
@interface VVJSONSchemaFormatValidator : NSObject <VVJSONSchemaValidator>

/** Name of the standard format a valid instance must comply to. */
@property (nonatomic, readonly, copy) NSString *formatName;

@end
