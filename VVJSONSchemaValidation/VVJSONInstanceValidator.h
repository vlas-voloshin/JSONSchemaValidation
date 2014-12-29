//
//  VVJSONInstanceValidator.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 28/12/2014.
//  Copyright (c) 2014 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Describes an object that can be used to validate a JSON instance. */
@protocol VVJSONInstanceValidator <NSObject>

/** Returns a set of JSON Schema keywords assigned to the receiver. */
+ (NSSet *)assignedKeywords;

/**
 Instantiates the receiver with a dictionary containing data from JSON Schema.
 @param dictionary Dictionary of schema properties relevant to the created validator instance.
 @param scopeURI Resolution scope of the schema that defines the created validator instance.
 @param error Error object to contain any error encountered during initialization of the receiver.
 @return Configured validator instance, or nil if there was an error during initialization of the instance.
 */
+ (instancetype)validatorWithDictionary:(NSDictionary *)dictionary scopeURI:(NSURL *)scopeURI error:(NSError * __autoreleasing *)error;

/** Returns a set of all nested schemas used in the receiver. */
- (NSSet *)subschemas;

/**
 Attempts to validate the specified JSON instance.
 @param instance The validated JSON instance.
 @param error Error object to contain the first encountered validation error.
 @return YES, if validation passed successfully, otherwise NO.
 */
- (BOOL)validateInstance:(id)instance withError:(NSError * __autoreleasing *)error;

@end
