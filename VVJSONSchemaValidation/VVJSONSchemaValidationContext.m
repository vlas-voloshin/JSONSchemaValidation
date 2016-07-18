//
//  VVJSONSchemaValidationContext.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 11/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchemaValidationContext.h"
#import "VVJSONSchema.h"
#import "NSString+VVJSONPointer.h"

#pragma mark - Object pair class

@interface VVJSONSchemaValidationContextPair : NSObject

@property (nonatomic, readonly, strong) VVJSONSchema *schema;
@property (nonatomic, readonly, strong) id object;

- (instancetype)initWithSchema:(VVJSONSchema *)schema object:(id)object;

@end

@implementation VVJSONSchemaValidationContextPair

- (instancetype)initWithSchema:(VVJSONSchema *)schema object:(id)object
{
    self = [super init];
    if (self) {
        _schema = schema;
        _object = object;
    }
    
    return self;
}

- (BOOL)isEqualToPair:(VVJSONSchemaValidationContextPair *)pair
{
    return self->_schema == pair->_schema && self->_object == pair->_object;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[VVJSONSchemaValidationContextPair class]] && [self isEqualToPair:object];
}

- (NSUInteger)hash
{
    // bah, just xor the pointers
    return (NSUInteger)_schema ^ (NSUInteger)_object;
}

@end

#pragma mark - Context class

@implementation VVJSONSchemaValidationContext
{
    NSMutableOrderedSet<VVJSONSchemaValidationContextPair *> *_validationStack;
    NSMutableArray<NSString *> *_validationPathStack;
    
    NSString *_validationPathCache;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // make the "call stacks" large enough in advance
        _validationStack = [NSMutableOrderedSet orderedSetWithCapacity:100];
        _validationPathStack = [NSMutableArray arrayWithCapacity:100];
    }
    
    return self;
}

- (VVJSONSchema *)validatedSchema
{
    VVJSONSchemaValidationContextPair *lastPair = _validationStack.lastObject;
    return lastPair.schema;
}

- (id)validatedObject
{
    VVJSONSchemaValidationContextPair *lastPair = _validationStack.lastObject;
    return lastPair.object;
}

- (NSString *)validationPath
{
    if (_validationPathCache == nil) {
        _validationPathCache = [NSString vv_JSONPointerStringFromPathComponents:_validationPathStack];
    }
    
    return _validationPathCache;
}

#pragma mark - Stack modification methods

- (BOOL)pushValidatedSchema:(VVJSONSchema *)validatedSchema object:(id)validatedObject withError:(NSError *__autoreleasing *)error
{
    NSParameterAssert(validatedSchema);
    NSParameterAssert(validatedObject);
    
    VVJSONSchemaValidationContextPair *registrationPair = [[VVJSONSchemaValidationContextPair alloc] initWithSchema:validatedSchema object:validatedObject];
    
    if ([_validationStack containsObject:registrationPair]) {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeValidationInfiniteLoop failingObject:validatedObject];
        }
        return NO;
    }
    
    [self willChangeValueForKey:@"validatedSchema"];
    [self willChangeValueForKey:@"validatedObject"];
    
    [_validationStack addObject:registrationPair];
    
    [self didChangeValueForKey:@"validatedSchema"];
    [self didChangeValueForKey:@"validatedObject"];
    
    return YES;
}

- (void)popValidatedSchemaAndObject
{
    NSAssert(_validationStack.count > 0, @"Attempted to pop a validated schema and object off an empty validation stack.");
    
    [self willChangeValueForKey:@"validatedSchema"];
    [self willChangeValueForKey:@"validatedObject"];
    
    NSUInteger lastIndex = _validationStack.count - 1;
    [_validationStack removeObjectAtIndex:lastIndex];
    
    [self didChangeValueForKey:@"validatedSchema"];
    [self didChangeValueForKey:@"validatedObject"];
}

- (void)pushValidationPathComponent:(NSString *)pathComponent
{
    NSParameterAssert(pathComponent);
    
    [self willChangeValueForKey:@"validationPath"];
    [_validationPathStack addObject:pathComponent];
    _validationPathCache = nil;
    [self didChangeValueForKey:@"validationPath"];
}

- (void)popValidationPathComponent
{
    NSAssert(_validationPathStack.count > 0, @"Attempted to pop a validated path component off an empty validation path stack.");
    
    [self willChangeValueForKey:@"validationPath"];
    [_validationPathStack removeLastObject];
    _validationPathCache = nil;
    [self didChangeValueForKey:@"validationPath"];
}

@end
