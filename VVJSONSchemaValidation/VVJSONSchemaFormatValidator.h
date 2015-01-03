//
//  VVJSONSchemaFormatValidator.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 3/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVJSONSchemaValidator.h"

@interface VVJSONSchemaFormatValidator : NSObject <VVJSONSchemaValidator>

@property (nonatomic, readonly, copy) NSString *formatName;

@end
