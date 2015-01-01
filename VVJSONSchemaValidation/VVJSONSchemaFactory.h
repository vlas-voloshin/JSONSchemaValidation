//
//  VVJSONSchemaFactory.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 29/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VVJSONSchema;

/**
 Defines an object capable of creating schema and validator instances.
 @discussion This class is used by the implementation of the schema and validator classes. Schema instantiation process starts by creating a root factory object, configured with the keywords mapping and base scope URI. This factory is then used to create the root schema and instantiate its validators. Validators receive a factory and use it to generate sub-factories for instantiating nested schemas.
 */
@interface VVJSONSchemaFactory : NSObject

/** Resolution scope URI of the receiver. */
@property (nonatomic, readonly, strong) NSURL *scopeURI;
/**
 Keywords mapping used to create validators for the schema.
 */
@property (nonatomic, readonly, copy) NSDictionary *keywordsMapping;

/** Creates a root factory object with specified base resolution scope URI and keywords mapping. */
+ (instancetype)factoryWithScopeURI:(NSURL *)scopeURI keywordsMapping:(NSDictionary *)keywordsMapping;

/** Returns a new factory object with the specified resolution scope and the same keywords mapping as the receiver. */
- (instancetype)factoryByReplacingScopeURI:(NSURL *)scopeURI;
/** Returns a new factory object with the resolution scope appended the specified fragment component and the same keywords mapping as the receiver. */
- (instancetype)factoryByAppendingScopeComponent:(NSString *)scopeComponent;

/**
 Returns a schema configured using the contents of specified JSON dictionary.
 @discussion Note that returned schema may have a different resolution scrope URI than the value of `scopeURI` property, if that schema alters its scope with an "id" property.
 @param dictionary Dictionary containing the JSON Schema representation.
 @param error Error object to contain any error encountered during schema instantiation.
 @return Configured schema instance, or nil if an error occurred.
 */
- (VVJSONSchema *)schemaWithDictionary:(NSDictionary *)schemaDictionary error:(NSError * __autoreleasing *)error;

@end
