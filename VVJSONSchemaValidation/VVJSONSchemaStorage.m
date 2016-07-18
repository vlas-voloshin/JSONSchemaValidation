//
//  VVJSONSchemaStorage.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 7/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchemaStorage.h"
#import "VVJSONSchema.h"
#import "NSURL+VVJSONReferencing.h"

#pragma mark - VVJSONSchemaStorage

@interface VVJSONSchemaStorage ()
{
@protected
    NSMutableDictionary<NSURL *, VVJSONSchema *> *_mapping;
}

@end

@implementation VVJSONSchemaStorage

+ (instancetype)storage
{
    return [[self alloc] init];
}

+ (instancetype)storageWithSchema:(VVJSONSchema *)schema
{
    NSDictionary<NSURL *, VVJSONSchema *> *mapping = [self scopeURIMappingFromSchema:schema];
    if (mapping != nil) {
        return [[self alloc] initWithMapping:mapping];
    } else {
        return nil;
    }
}

+ (instancetype)storageWithSchemasArray:(NSArray<VVJSONSchema *> *)schemas
{
    VVJSONSchemaStorage *storage = [[self alloc] init];
    
    for (VVJSONSchema *schema in schemas) {
        NSDictionary<NSURL *, VVJSONSchema *> *mapping = [self scopeURIMappingFromSchema:schema];
        if (mapping != nil) {
            BOOL success = [storage addMapping:mapping];
            if (success == NO) {
                return nil;
            }
        } else {
            return nil;
        }
    }
    
    return storage;
}

- (instancetype)init
{
    return [self initWithMapping:nil];
}

- (instancetype)initWithMapping:(NSDictionary<NSURL *, VVJSONSchema *> *)mapping
{
    self = [super init];
    if (self) {
        _mapping = [NSMutableDictionary dictionaryWithDictionary:mapping];
    }
    
    return self;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@" { %lu schemas }", (unsigned long)_mapping.count];
}

- (instancetype)storageByAddingSchema:(VVJSONSchema *)schema
{
    VVJSONSchemaStorage *newStorage = [[self.class alloc] initWithMapping:_mapping];
    NSDictionary<NSURL *, VVJSONSchema *> *newMapping = [self.class scopeURIMappingFromSchema:schema];
    if (newMapping != nil) {
        BOOL success = [newStorage addMapping:newMapping];
        if (success) {
            return newStorage;
        }
    }
    
    return nil;
}

- (VVJSONSchema *)schemaForURI:(NSURL *)schemaURI
{
    return _mapping[schemaURI.vv_normalizedURI];
}

- (BOOL)addMapping:(NSDictionary<NSURL *, VVJSONSchema *> *)mapping
{
    if (mapping == nil) {
        return NO;
    }
    
    if (_mapping.count != 0) {
        // if adding to a non-empty container, check for duplicates first
        NSSet<NSURL *> *existingURIs = [NSSet setWithArray:_mapping.allKeys];
        NSSet<NSURL *> *newURIs = [NSSet setWithArray:mapping.allKeys];
        if ([existingURIs intersectsSet:newURIs]) {
            return NO;
        }
    }
    
    [_mapping addEntriesFromDictionary:mapping];
    
    return YES;
}

+ (NSDictionary<NSURL *, VVJSONSchema *> *)scopeURIMappingFromSchema:(VVJSONSchema *)schema
{
    NSMutableDictionary<NSURL *, VVJSONSchema *> *schemaURIMapping = [NSMutableDictionary dictionary];
    
    __block BOOL success = YES;
    [schema visitUsingBlock:^(VVJSONSchema *subschema, BOOL *stop) {
        NSURL *subschemaURI = subschema.uri;
        if (schemaURIMapping[subschemaURI] == nil) {
            schemaURIMapping[subschemaURI] = subschema;
        } else {
            // fail on duplicate scopes
            success = NO;
            *stop = YES;
        }
    }];
    
    if (success) {
        return [schemaURIMapping copy];
    } else {
        return nil;
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(__unused NSZone *)zone
{
    // VVJSONSchemaStorage is immutable
    return self;
}

- (id)mutableCopyWithZone:(__unused NSZone *)zone
{
    return [[VVMutableJSONSchemaStorage alloc] initWithMapping:_mapping];
}

@end

#pragma mark - VVMutableJSONSchemaStorage

@implementation VVMutableJSONSchemaStorage

- (BOOL)addSchema:(VVJSONSchema *)schema
{
    NSDictionary<NSURL *, VVJSONSchema *> *mapping = [self.class scopeURIMappingFromSchema:schema];
    if (mapping != nil) {
        return [self addMapping:mapping];
    } else {
        return NO;
    }
}

- (id)copyWithZone:(__unused NSZone *)zone
{
    return [[VVJSONSchemaStorage alloc] initWithMapping:_mapping];
}

@end
