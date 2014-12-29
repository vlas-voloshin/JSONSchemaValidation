//
//  NSNumber+VVNumberTypes.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 30/12/2014.
//  Copyright (c) 2014 Vlas Voloshin. All rights reserved.
//

#import "NSNumber+VVNumberTypes.h"

@implementation NSNumber (VVNumberTypes)

- (BOOL)vv_isInteger
{
    if (self.vv_isBoolean == NO) {
        return self.vv_isFloat == NO;
    } else {
        return NO;
    }
}

- (BOOL)vv_isFloat
{
    CFNumberRef underlyingNumberRef = (__bridge CFNumberRef)self;
    return CFNumberIsFloatType(underlyingNumberRef);
}

- (BOOL)vv_isBoolean
{
    // this is a bit fragile!
    return [self isKindOfClass:[@YES class]];
}

@end
