//
//  VVJSONSchema.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 28/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchema.h"
#import "VVJSONSchemaReference.h"
#import "VVJSONSchemaFactory.h"
#import "VVJSONSchemaValidationContext.h"
#import "NSURL+VVJSONReferencing.h"

@implementation VVJSONSchema

static NSString * const kJSONSchemaDefaultString = @"http://json-schema.org/draft-04/schema#";
static NSString * const kSchemaKeywordSchema = @"$schema";

+ (NSURL *)defaultMetaschemaURI
{
    static NSURL *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NSURL URLWithString:kJSONSchemaDefaultString];
    });
    
    return instance;
}

+ (NSSet<NSURL *> *)supportedMetaschemaURIs
{
    static NSSet<NSURL *> *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray<NSURL *> *uris = @[ [NSURL URLWithString:kJSONSchemaDefaultString],
                                    [NSURL URLWithString:@"http://json-schema.org/schema#"] ];
        
        instance = [NSSet setWithArray:uris];
    });
    
    return instance;
}

+ (NSSet<NSURL *> *)unsupportedMetaschemaURIs
{
    static NSSet<NSURL *> *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray<NSURL *> *uris = @[ [NSURL URLWithString:@"http://json-schema.org/hyper-schema#"],
                                    [NSURL URLWithString:@"http://json-schema.org/draft-04/hyper-schema#"],
                                    [NSURL URLWithString:@"http://json-schema.org/draft-03/schema#"],
                                    [NSURL URLWithString:@"http://json-schema.org/draft-03/hyper-schema#"] ];
        
        instance = [NSSet setWithArray:uris];
    });
    
    return instance;
}

- (instancetype)initWithScopeURI:(NSURL *)uri title:(NSString *)title description:(NSString *)description validators:(NSArray<id<VVJSONSchemaValidator>> *)validators subschemas:(NSArray<VVJSONSchema *> *)subschemas
{
    NSParameterAssert(uri);
    
    self = [super init];
    if (self) {
        _uri = uri;
        _title = [title copy];
        _schemaDescription = [description copy];
        _validators = [validators copy];
        _subschemas = [subschemas copy];
    }
    
    return self;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"{ %@; '%@': '%@'; %lu validators; %lu subschemas }", self.uri, self.title, self.schemaDescription, (unsigned long)self.validators.count, (unsigned long)self.subschemas.count];
}

#pragma mark - Schema parsing

+ (instancetype)schemaWithDictionary:(NSDictionary<NSString *, id> *)schemaDictionary baseURI:(NSURL *)baseURI referenceStorage:(VVJSONSchemaStorage *)referenceStorage error:(NSError *__autoreleasing *)error
{
    // retrieve metaschema URI
    id metaschemaURIString = schemaDictionary[kSchemaKeywordSchema];
    if (metaschemaURIString != nil && [metaschemaURIString isKindOfClass:[NSString class]] == NO) {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaDictionary];
        }
        return nil;
    }
    NSURL *metaschemaURI = [NSURL URLWithString:metaschemaURIString];
    
    // check that metaschema is supported
    if ([[self unsupportedMetaschemaURIs] containsObject:metaschemaURI]) {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeIncompatibleMetaschema failingObject:metaschemaURIString];
        }
        return nil;
    }
    
    // retrieve validator mapping for this metaschema
    NSDictionary<NSString *, Class> *keywordsMapping = [self validatorsMappingForMetaschemaURI:metaschemaURI];
    NSAssert(keywordsMapping.count > 0, @"No keywords defined!");
    
    // if base URI is not present, replace it with an empty one
    if (baseURI == nil) {
        baseURI = [NSURL URLWithString:@""];
    }
    // normalize the base URI
    baseURI = baseURI.vv_normalizedURI;
    
    VVJSONSchema *schema = nil;
    // have to be careful around autorelease pool and reference-returned autoreleasing objects...
    NSError *internalError = nil;
    @autoreleasepool {
        // instantiate a root schema factory and use it to create the schema
        VVJSONSchemaFactory *factory = [VVJSONSchemaFactory factoryWithScopeURI:baseURI keywordsMapping:keywordsMapping];
        schema = [factory schemaWithDictionary:schemaDictionary error:&internalError];
        
        if (schema != nil) {
            // create a schema storage to resolve references
            VVJSONSchemaStorage *resolvingStorage;
            if (referenceStorage != nil) {
                resolvingStorage = [referenceStorage storageByAddingSchema:schema];
            } else {
                resolvingStorage = [VVJSONSchemaStorage storageWithSchema:schema];
            }
            
            if (resolvingStorage != nil) {
                // resolve all schema references
                BOOL success = [schema resolveReferencesWithSchemaStorage:resolvingStorage error:&internalError];
                
                if (success) {
                    // detect reference cycles
                    [schema detectReferenceCyclesWithError:&internalError];
                }
            } else {
                // if creating a schema storage failed, it means there are duplicate scope URIs
                internalError = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeDuplicateResolutionScope failingObject:schemaDictionary];
            }
        }
    }

    if (internalError == nil) {
        return schema;
    } else {
        if (error != NULL) {
            *error = internalError;
        }
        return nil;
    }
}

+ (instancetype)schemaWithData:(NSData *)schemaData baseURI:(NSURL *)baseURI referenceStorage:(VVJSONSchemaStorage *)referenceStorage error:(NSError *__autoreleasing *)error
{
    id object = [NSJSONSerialization JSONObjectWithData:schemaData options:(NSJSONReadingOptions)0 error:error];
    if ([object isKindOfClass:[NSDictionary class]]) {
        return [self schemaWithDictionary:object baseURI:baseURI referenceStorage:referenceStorage error:error];
    } else if (object != nil) {
        // schema object must be a dictionary
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:object];
        }
        return nil;
    } else {
        return nil;
    }
}

- (BOOL)visitUsingBlock:(void (^)(VVJSONSchema *subschema, BOOL *stop))block
{
    NSParameterAssert(block);
    
    BOOL stop = NO;
    // visit self first
    block(self, &stop);
    if (stop) {
        return YES;
    }
    
    // visit subschemas in validators
    for (id<VVJSONSchemaValidator> validator in self.validators) {
        for (VVJSONSchema *subschema in [validator subschemas]) {
            stop = [subschema visitUsingBlock:block];
            if (stop) {
                return YES;
            }
        }
    }
    
    // visit unbound subschemas
    for (VVJSONSchema *subschema in self.subschemas) {
        stop = [subschema visitUsingBlock:block];
        if (stop) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)resolveReferencesWithSchemaStorage:(VVJSONSchemaStorage *)schemaStorage error:(NSError * __autoreleasing *)error
{
    __block NSError *internalError = nil;
    [self visitUsingBlock:^(VVJSONSchema *subschema, BOOL *stop) {
        // do not process normal schemas
        if ([subschema isKindOfClass:[VVJSONSchemaReference class]] == NO) {
            return;
        }
        
        VVJSONSchemaReference *referenceSubschema = (VVJSONSchemaReference *)subschema;
        // do not process already resolved references
        if (referenceSubschema.referencedSchema != nil) {
            return;
        }
        
        // try resolving the reference
        NSURL *referenceURI = referenceSubschema.referenceURI;
        VVJSONSchema *referencedSchema = [schemaStorage schemaForURI:referenceURI];
        if (referencedSchema != nil) {
            [referenceSubschema resolveReferenceWithSchema:referencedSchema];
        } else {
            internalError = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeUnresolvableSchemaReference failingObject:referenceURI];
            *stop = YES;
        }
    }];
    
    if (internalError == nil) {
        return YES;
    } else {
        if (error != NULL) {
            *error = internalError;
        }
        return NO;
    }
}

- (BOOL)detectReferenceCyclesWithError:(NSError * __autoreleasing *)error
{
    __block NSError *internalError = nil;
    [self visitUsingBlock:^(VVJSONSchema *subschema, BOOL *stop) {
        // do not process normal schemas
        if ([subschema isKindOfClass:[VVJSONSchemaReference class]] == NO) {
            return;
        }
        
        VVJSONSchemaReference *referencePointer = (VVJSONSchemaReference *)subschema;
        NSMutableSet<VVJSONSchemaReference *> *referenceChain = [NSMutableSet set];
        do {
            if ([referenceChain containsObject:referencePointer] == NO) {
                [referenceChain addObject:referencePointer];
                
                VVJSONSchema *referencedSchema = [referencePointer referencedSchema];
                NSAssert(referencedSchema != nil, @"Assuming all schema references are already resolved.");
                
                if ([referencedSchema isKindOfClass:[VVJSONSchemaReference class]]) {
                    referencePointer = (VVJSONSchemaReference *)referencedSchema;
                } else {
                    referencePointer = nil;
                }
            } else {
                internalError = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeReferenceCycle failingObject:referencePointer];
                *stop = YES;
                return;
            }
        } while (referencePointer != nil);
    }];
    
    if (internalError == nil) {
        return YES;
    } else {
        if (error != NULL) {
            *error = internalError;
        }
        return NO;
    }
}

#pragma mark - Schema validation

- (BOOL)validateObject:(id)object inContext:(VVJSONSchemaValidationContext *)context error:(NSError *__autoreleasing *)error
{
    // create a validation context if necessary
    if (context == nil) {
        context = [[VVJSONSchemaValidationContext alloc] init];
    }
    
    // try to register a new entry in the validation context
    BOOL success = [context pushValidatedSchema:self object:object withError:error];
    if (success == NO) {
        return NO;
    }
    
    for (id<VVJSONSchemaValidator> validator in self.validators) {
        if ([validator validateInstance:object inContext:context error:error] == NO) {
            success = NO;
            break;
        }
    }
    
    // unregister the current entry from the validation context
    [context popValidatedSchemaAndObject];
    
    return success;
}

- (BOOL)validateObject:(id)object withError:(NSError *__autoreleasing *)error
{
    return [self validateObject:object inContext:nil error:error];
}

- (BOOL)validateObjectWithData:(NSData *)data error:(NSError * __autoreleasing *)error
{
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
    if (object != nil) {
        return [self validateObject:object withError:error];
    } else {
        return NO;
    }
}

#pragma mark - Validators registry

// maps metaschema URIs to dictionaries which, in turn, map string keywords to validator classes
static NSMutableDictionary<NSURL *, NSDictionary<NSString *, Class> *> *schemaKeywordsMapping;

+ (NSDictionary<NSString *, Class> *)validatorsMappingForMetaschemaURI:(NSURL *)metaschemaURI
{
    // return nil for unsupported metaschemas
    if ([[self unsupportedMetaschemaURIs] containsObject:metaschemaURI]) {
        return nil;
    }
    
    // if not a standard supported supported metaschema URI, retrieve its custom keywords
    NSDictionary<NSString *, Class> *customKeywordsMapping = nil;
    if (metaschemaURI != nil && [[self supportedMetaschemaURIs] containsObject:metaschemaURI] == NO) {
        customKeywordsMapping = schemaKeywordsMapping[metaschemaURI];
    }
    
    // retrieve keywords mapping for standard metaschema and extend it with custom one if necessary
    NSDictionary<NSString *, Class> *effectiveKeywordsMapping = schemaKeywordsMapping[[self defaultMetaschemaURI]];
    if (customKeywordsMapping.count > 0) {
        NSMutableDictionary<NSString *, Class> *extendedMapping = [effectiveKeywordsMapping mutableCopy];
        [extendedMapping addEntriesFromDictionary:customKeywordsMapping];
        effectiveKeywordsMapping = extendedMapping;
    }
    
    return [effectiveKeywordsMapping copy];
}

+ (BOOL)registerValidatorClass:(Class<VVJSONSchemaValidator>)validatorClass forMetaschemaURI:(NSURL *)metaschemaURI withError:(NSError * __autoreleasing *)error
{
    // initialize the mapping dictionary if necessary
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        schemaKeywordsMapping = [NSMutableDictionary dictionary];
    });
    
    // fail for unsupported metaschemas
    if ([[self unsupportedMetaschemaURIs] containsObject:metaschemaURI]) {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeIncompatibleMetaschema failingObject:metaschemaURI];
        }
        return NO;
    }
    
    // replace nil and any supported metaschema URI with default one
    if (metaschemaURI == nil || [[self supportedMetaschemaURIs] containsObject:metaschemaURI]) {
        metaschemaURI = [self defaultMetaschemaURI];
    }
    
    // retrieve keywords set for the validator class
    NSSet<NSString *> *keywords = [validatorClass assignedKeywords];
    // fail if validator does not define any keywords
    if (keywords.count == 0) {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeNoValidatorKeywordsDefined failingObject:validatorClass];
        }
        return NO;
    }
    
    // check that the new validator does not define any keywords already defined by another validator in the same scope
    NSDictionary<NSString *, Class> *effectiveValidatorsMapping = [self validatorsMappingForMetaschemaURI:metaschemaURI];
    if ([[NSSet setWithArray:effectiveValidatorsMapping.allKeys] intersectsSet:keywords]) {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeValidatorKeywordAlreadyDefined failingObject:validatorClass];
        }
        return NO;
    }
    
    // finally, register the new keywords
    NSMutableDictionary<NSString *, Class> *mapping = [schemaKeywordsMapping[metaschemaURI] mutableCopy] ?: [NSMutableDictionary dictionary];
    for (NSString *keyword in keywords) {
        mapping[keyword] = validatorClass;
    }
    schemaKeywordsMapping[metaschemaURI] = [mapping copy];
    
    return YES;
}

@end
