//
//  NSNumber+VVNumberTypes.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 30/12/2014.
//  Copyright (c) 2014 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (VVNumberTypes)

- (BOOL)vv_isInteger;
- (BOOL)vv_isFloat;
- (BOOL)vv_isBoolean;

@end
