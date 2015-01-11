//
//  VVJSONSchemaValidationContext.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 11/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VVJSONSchema;

/**
 This class is used internally in the validation process to detect infinite loops.
 */
@interface VVJSONSchemaValidationContext : NSObject

/**
 Attempts to register a schema-object pair in the receiver.
 @discussion If receiver already contains an association between `validatedSchema` and `validatedObject`, this method will fail.
 @param validatedSchema Schema to register.
 @param validatedObject Validated object to associate with `validatedSchema`.
 @param error Error object to contain any error encountered during registration.
 @return YES if the pair was registered successfully, otherwise NO.
 */
- (BOOL)registerValidatedSchema:(VVJSONSchema *)validatedSchema object:(id)validatedObject withError:(NSError * __autoreleasing *)error;
/**
 Unregisters a schema-object pair from the receiver.
 @discussion This method will throw an exception if an association between `validatedSchema` and `validatedObject` does not exist in the receiver.
 @param validatedSchema Schema to unregister.
 @param validatedObject Validated object to disassociate from `validatedSchema`.
 */
- (void)unregisterValidatedSchema:(VVJSONSchema *)validatedSchema object:(id)validatedObject;

@end
