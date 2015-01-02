//
//  NSString+VVJSONPointer.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 2/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (VVJSONPointer)

/** Returns a string constructed from receiver by escaping JSON Pointer special characters. */
- (NSString *)vv_stringByEncodingAsJSONPointer;
/** Returns a string constructed from receiver by unescaping JSON Pointer special characters. */
- (NSString *)vv_stringByDecodingAsJSONPointer;

@end
