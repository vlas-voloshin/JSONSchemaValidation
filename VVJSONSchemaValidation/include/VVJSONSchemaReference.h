//
//  VVJSONSchemaReference.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 28/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchema.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Defines a "proxy" schema, representing a reference to another schema via an URI.
 @discussion Instances of this class delegate validation to the actual referenced schema. They are usually created as a part of root schema parsing process to represent JSON references to nested schemas, and are also resolved later on in that process. If an unresolvable reference or a reference loop is encountered, parsing process is stopped and an error is reported.
 @warning Attempting to validate an object using unresolved schema reference throws an exception.
 */
@interface VVJSONSchemaReference : VVJSONSchema

/** URI of the referenced schema. */
@property (nonatomic, readonly, strong) NSURL *referenceURI;
/** The referenced schema. The value of this property is nil until receiver is dereferenced. */
@property (nonatomic, readonly, weak) VVJSONSchema *referencedSchema;

/** Initializes the receiver with scope URI and reference URI, leaving title, description and own set of validators as nil. */
- (instancetype)initWithScopeURI:(NSURL *)uri referenceURI:(NSURL *)referenceURI;

/**
 Resolves receiver's reference URI with the specified schema.
 @warning Schema references are usually resolved automatically during the root schema parsing process. Calling this method second time will throw an exception.
 */
- (void)resolveReferenceWithSchema:(VVJSONSchema *)schema;

@end

NS_ASSUME_NONNULL_END
