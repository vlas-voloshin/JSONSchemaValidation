//
//  VVJSONSchemaReference.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 28/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchemaReference.h"

@implementation VVJSONSchemaReference

- (instancetype)initWithScopeURI:(NSURL *)uri referenceURI:(NSURL *)referenceURI
{
    NSParameterAssert(uri);
    NSParameterAssert(referenceURI);
    
    self = [super initWithScopeURI:uri title:nil description:nil validators:nil subschemas:nil];
    if (self) {
        _referenceURI = referenceURI;
    }
    
    return self;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"{ referencing %@ }", self.referencedSchema ?: self.referenceURI];
}

- (BOOL)validateObject:(id)object inContext:(VVJSONSchemaValidationContext *)context error:(NSError *__autoreleasing *)error
{
    VVJSONSchema *referencedSchema = self.referencedSchema;
    if (referencedSchema != nil) {
        return [referencedSchema validateObject:object inContext:context error:error];
    } else {
        [NSException raise:NSInternalInconsistencyException format:@"Can't validate an object using an unresolved schema reference."];
        return NO;
    }
}

- (void)resolveReferenceWithSchema:(VVJSONSchema *)schema
{
    if (_referencedSchema != nil) {
        [NSException raise:NSInternalInconsistencyException format:@"Attempted to resolve already resolved schema reference."];
        return;
    }
    
    _referencedSchema = schema;
}

@end
