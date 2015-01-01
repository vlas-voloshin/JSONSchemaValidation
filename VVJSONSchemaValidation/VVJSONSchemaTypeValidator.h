//
//  VVJSONSchemaTypeValidator.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 30/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVJSONSchemaValidator.h"

typedef NS_OPTIONS(NSUInteger, VVJSONSchemaInstanceTypes) {
    VVJSONSchemaInstanceTypesNone = 0,
    VVJSONSchemaInstanceTypesObject = 1 << 0,
    VVJSONSchemaInstanceTypesArray = 1 << 1,
    VVJSONSchemaInstanceTypesString = 1 << 2,
    VVJSONSchemaInstanceTypesInteger = 1 << 3,
    VVJSONSchemaInstanceTypesNumber = 1 << 4,
    VVJSONSchemaInstanceTypesBoolean = 1 << 5,
    VVJSONSchemaInstanceTypesNull = 1 << 6
};

@interface VVJSONSchemaTypeValidator : NSObject <VVJSONSchemaValidator>

@property (nonatomic, readonly, assign) VVJSONSchemaInstanceTypes types;

@end
