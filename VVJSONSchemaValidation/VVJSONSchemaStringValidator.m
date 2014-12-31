//
//  VVJSONSchemaStringValidator.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 31/12/2014.
//  Copyright (c) 2014 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchemaStringValidator.h"
#import "VVJSONSchemaErrors.h"
#import "NSNumber+VVNumberTypes.h"

@implementation VVJSONSchemaStringValidator

static NSString * const kSchemaKeywordMaxLength = @"maxLength";
static NSString * const kSchemaKeywordMinLength = @"minLength";
static NSString * const kSchemaKeywordPattern = @"pattern";

- (instancetype)initWithMaximumLength:(NSUInteger)maximumLength minimumLength:(NSUInteger)minimumLength regularExpression:(NSRegularExpression *)regularExpression
{
    self = [super init];
    if (self) {
        _maximumLength = maximumLength;
        _minimumLength = minimumLength;
        _regularExpression = regularExpression;
    }
    
    return self;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"{ maximum length: %@, minimum length: %lu, pattern: %@ }", (self.maximumLength != NSUIntegerMax ? @(self.maximumLength) : @"none"), (unsigned long)self.minimumLength, self.regularExpression.pattern];
}

+ (NSSet *)assignedKeywords
{
    return [NSSet setWithArray:@[ kSchemaKeywordMaxLength, kSchemaKeywordMinLength, kSchemaKeywordPattern ]];
}

+ (instancetype)validatorWithDictionary:(NSDictionary *)schemaDictionary schemaFactory:(VVJSONSchemaFactory *)schemaFactory error:(NSError *__autoreleasing *)error
{
    if ([self validateSchemaFormat:schemaDictionary] == NO) {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaDictionary failingValidator:nil];
        }
        return nil;
    }
    
    NSNumber *maxLength = schemaDictionary[kSchemaKeywordMaxLength];
    NSNumber *minLength = schemaDictionary[kSchemaKeywordMinLength];
    NSString *pattern = schemaDictionary[kSchemaKeywordPattern];
    
    NSUInteger maxLengthValue = (maxLength != nil ? [maxLength unsignedIntegerValue] : NSUIntegerMax);
    NSUInteger minLengthValue = (minLength != nil ? [minLength unsignedIntegerValue] : 0);
    
    NSRegularExpression *regexp = nil;
    if (pattern.length > 0) {
        NSError *regexpError = nil;
        regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&regexpError];
        if (regexp == nil) {
            if (error != NULL) {
                *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidRegularExpression failingObject:pattern failingValidator:nil];
            }
            return nil;
        }
    }
    
    return [[self alloc] initWithMaximumLength:maxLengthValue minimumLength:minLengthValue regularExpression:regexp];
}

+ (BOOL)validateSchemaFormat:(NSDictionary *)schemaDictionary
{
    id maxLength = schemaDictionary[kSchemaKeywordMaxLength];
    id minLength = schemaDictionary[kSchemaKeywordMinLength];
    id pattern = schemaDictionary[kSchemaKeywordPattern];
    
    // maxLength must be a number and not a boolean, and must be greater than or equal to zero
    if (maxLength != nil) {
        if ([maxLength isKindOfClass:[NSNumber class]] == NO || [maxLength vv_isBoolean] || [maxLength compare:@0] == NSOrderedAscending) {
            return NO;
        }
    }
    // minLength must be a number and not a boolean, and must be greater than or equal to zero
    if (minLength != nil) {
        if ([minLength isKindOfClass:[NSNumber class]] == NO || [minLength vv_isBoolean] || [minLength compare:@0] == NSOrderedAscending) {
            return NO;
        }
    }
    // pattern must be a string
    if (pattern != nil) {
        if ([pattern isKindOfClass:[NSString class]] == NO) {
            return NO;
        }
    }
    
    return YES;
}

- (NSSet *)subschemas
{
    return nil;
}

- (BOOL)validateInstance:(id)instance withError:(NSError *__autoreleasing *)error
{
    // silently succeed if value of the instance is inapplicable
    if ([instance isKindOfClass:[NSString class]] == NO) {
        return YES;
    }
    
    // retrieve actual string length by converting it to UTF32 representation and calculating number of 4-byte charaters
    // (see http://www.objc.io/issue-9/unicode.html for details)
    NSUInteger realLength = [instance lengthOfBytesUsingEncoding:NSUTF32StringEncoding] / 4;
    // check maximum and minimum length
    if (realLength > self.maximumLength || realLength < self.minimumLength) {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeValidationFailed failingObject:instance failingValidator:self];
        }
        return NO;
    }
    
    // check regexp pattern
    if (self.regularExpression != nil) {
        if ([self.regularExpression numberOfMatchesInString:instance options:0 range:NSMakeRange(0, [instance length])] == 0) {
            if (error != NULL) {
                *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeValidationFailed failingObject:instance failingValidator:self];
            }
            return NO;
        }
    }
    
    return YES;
}

@end
