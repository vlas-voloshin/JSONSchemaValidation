//
//  VVJSONSchema.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 28/12/2014.
//  Copyright (c) 2014 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVJSONInstanceValidator.h"
#import "VVJSONSchemaErrors.h"

/**
 Defines an object describing a JSON Schema, capable of validating objects against its configuration.
 @discussion
 Basic setup of this class allows validating JSON-decoded objects with schemas authored in JSON Schema, draft 4 format. To create a schema object, use one of the provided factory methods, specifying the root schema object to parse, either JSON-encoded or decoded. Note that creating schema objects is a resource-heavy process, so created schemas should be cached as possible.
 Root schema parsing process uses $schema property to check that specified schema object was created using an expected schema format. If it is not present or not recognized, default (JSON Schema, draft 4) is implied. If an incompatible schema format is encountered, creating the schema instance will fail.
 To extend the functionality of schema validation beyond the standard keywords, users of this class may register validator classes with custom keywords that will be used as necessary. To make sure that custom keywords are processed, specified root schema must contain a $schema property with a value equal to the one specified when the custom validator was registered.
 @warning
 There are a few caveats of using this class:
 * External schema references are not yet supported.
 * Regular expression patterns are validated using NSRegularExpression, which uses ICU implementation, not ECMA 262. Thus, some features like look-behind are not supported.
 * 'format' keyword is not supported yet.
 */
@interface VVJSONSchema : NSObject

/** URI resolution scope of the reciever. */
@property (nonatomic, readonly, strong) NSURL *uri;
/** Title of the receiver. */
@property (nonatomic, readonly, copy) NSString *title;
/** Description of the receiver. */
@property (nonatomic, readonly, copy) NSString *schemaDescription;
/** The set of validators defined in the receiver. */
@property (nonatomic, readonly, copy) NSSet *validators;

/**
 Instantiates the receiver and configures it using a dictionary containing the JSON Schema representation.
 @param schemaDictionary Dictionary containing the JSON Schema representation.
 @param baseURI Base resolution scope URI of the created schema (e.g., URL the schema was loaded from). Resolution scope of the created schema may be overriden by "id" property of the schema.
 @param error Error object to contain any error encountered during instantiation of the schema.
 @return Configured schema instance, or nil if there was an error occurred.
 */
+ (instancetype)schemaWithDictionary:(NSDictionary *)schemaDictionary baseURI:(NSURL *)baseURI error:(NSError * __autoreleasing *)error;
/**
 Instantiates the receiver and configures it using data containing JSON-encoded Schema representation.
 @param schemaData Data containing the JSON-encoded Schema representation.
 @param baseURI Base resolution scope URI of the created schema (e.g., URL the schema was loaded from). Resolution scope of the created schema may be overriden by "id" property of the schema.
 @param error Error object to contain any error encountered during instantiation of the schema.
 @return Configured schema instance, or nil if an error occurred.
 */
+ (instancetype)schemaWithData:(NSData *)schemaData baseURI:(NSURL *)baseURI error:(NSError * __autoreleasing *)error;

/**
 Designated initializer.
 @discussion This initializer is used by the implementation and subclasses. Use one of the convenience factory methods instead.
 */
- (instancetype)initWithScopeURI:(NSURL *)uri title:(NSString *)title description:(NSString *)description validators:(NSSet *)validators;

/**
 Attempts to validate the specified object against the configuration of the receiver.
 @param object The validated object.
 @param error Error object to contain the first encountered validation error.
 @return YES, if validation passed successfully, otherwise NO.
 */
- (BOOL)validateObject:(id)object withError:(NSError * __autoreleasing *)error;
/**
 Attempts to validate an object represented by the specified JSON-encoded data against the configuration of the receiver.
 @param data JSON-encoded representation of the validated object.
 @param error Error object to contain the first encountered validation error.
 @return YES, if validation passed successfully, otherwise NO.
 */
- (BOOL)validateObjectWithData:(NSData *)data error:(NSError * __autoreleasing *)error;

/**
 Registers the specified validator to be used with the specified metaschema URI.
 @discussion This method allows extending basic functionality of the schema validators by registering custom validators to be used with custom schema keywords. Set of keywords used in any particular case is determined by the $schema property of the root schema: if it's not present or its value corresponds to the standard schema format, only default validators are used; if other value is present, custom validators registered for that value will be used in addition to the standard validators.
 @warning Specifying nil or one of the standard values for `metaschemaURI` parameter results in the validator class being registered for all schemas and is thus discouraged. Attempting to register a validator class that handles a keyword (or keywords) already handled by another class will fail.
 @param validator Validator class to register.
 @param metaschemaURI URI of the custom metaschema. This URI is only used for comparing purposes: the metaschema itself is not fetched from the URI.
 @param error Error object to contain any error encountered during registration of the validator class.
 @return YES, if validator class was registered successfully, otherwise NO.
 */
+ (BOOL)registerValidatorClass:(Class<VVJSONInstanceValidator>)validatorClass forMetaschemaURI:(NSURL *)metaschemaURI withError:(NSError * __autoreleasing *)error;

@end
