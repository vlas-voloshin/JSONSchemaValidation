//
//  VVJSONSchemaStringValidator.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 31/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVJSONSchemaValidator.h"

/**
 Implements "maxLength", "minLength" and "pattern" properties. Applicable to string instances.
 */
@interface VVJSONSchemaStringValidator : NSObject <VVJSONSchemaValidator>

/** Maximum length of a valid string instance. Unapplicable value is NSUIntegerMax. */
@property (nonatomic, readonly, assign) NSUInteger maximumLength;
/** Minimum length of a valid string instance. Unapplicable value is 0. */
@property (nonatomic, readonly, assign) NSUInteger minimumLength;
/** Regular expression a valid string instance must match to. If nil, regular expression is not validated. */
@property (nonatomic, readonly, strong) NSRegularExpression *regularExpression;

@end
