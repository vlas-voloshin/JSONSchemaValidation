//
//  VVJSONSchemaValidationContext.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 11/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchemaValidationContext.h"
#import "VVJSONSchema.h"

#pragma mark - Object pair class

@interface VVJSONSchemaValidationContextPair : NSObject

- (instancetype)initWithFirstObject:(id)firstObject secondObject:(id)secondObject;

@end

@implementation VVJSONSchemaValidationContextPair
{
    id _firstObject;
    id _secondObject;
}

- (instancetype)initWithFirstObject:(id)firstObject secondObject:(id)secondObject
{
    self = [super init];
    if (self) {
        _firstObject = firstObject;
        _secondObject = secondObject;
    }
    
    return self;
}

- (BOOL)isEqualToPair:(VVJSONSchemaValidationContextPair *)pair
{
    return self->_firstObject == pair->_firstObject && self->_secondObject == pair->_secondObject;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[VVJSONSchemaValidationContextPair class]] && [self isEqualToPair:object];
}

- (NSUInteger)hash
{
    // bah, just xor the pointers
    return (NSUInteger)_firstObject ^ (NSUInteger)_secondObject;
}

@end

#pragma mark - Context class

@implementation VVJSONSchemaValidationContext
{
    NSMutableSet *_registeredPairs;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // the set will contain the validation "call stack", so make it large enough in advance
        _registeredPairs = [NSMutableSet setWithCapacity:100];
    }
    
    return self;
}

- (BOOL)registerValidatedSchema:(VVJSONSchema *)validatedSchema object:(id)validatedObject withError:(NSError *__autoreleasing *)error
{
    NSParameterAssert(validatedSchema);
    NSParameterAssert(validatedObject);
    
    id registrationPair = [self.class registrationPairFromSchema:validatedSchema object:validatedObject];
    
    if ([_registeredPairs containsObject:registrationPair]) {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeValidationInfiniteLoop failingObject:validatedObject];
        }
        return NO;
    }
    
    [_registeredPairs addObject:registrationPair];
    
    return YES;
}

- (void)unregisterValidatedSchema:(VVJSONSchema *)validatedSchema object:(id)validatedObject
{
    NSParameterAssert(validatedSchema);
    NSParameterAssert(validatedObject);
    
    id registrationPair = [self.class registrationPairFromSchema:validatedSchema object:validatedObject];

    if ([_registeredPairs containsObject:registrationPair] == NO) {
        [NSException raise:NSInternalInconsistencyException format:@"Attempted to unregister a missing association between %@ and %@.", validatedSchema, validatedObject];
    }
    
    [_registeredPairs removeObject:registrationPair];
}

+ (id)registrationPairFromSchema:(VVJSONSchema *)schema object:(id)object
{
    return [[VVJSONSchemaValidationContextPair alloc] initWithFirstObject:schema secondObject:object];
}

@end
