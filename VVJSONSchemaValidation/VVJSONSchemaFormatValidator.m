//
//  VVJSONSchemaFormatValidator.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 3/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchemaFormatValidator.h"
#import "VVJSONSchemaErrors.h"
#import <arpa/inet.h>

@implementation VVJSONSchemaFormatValidator

static NSString * const kSchemaKeywordFormat = @"format";

+ (void)initialize
{
    if (self == VVJSONSchemaFormatValidator.class) {
        // register standard formats
        BOOL success = YES;
        
        success &= [self registerFormat:@"date-time" withRegularExpression:[self dateTimeRegularExpression] error:NULL];
        success &= [self registerFormat:@"email" withRegularExpression:[self emailRegularExpression] error:NULL];
        success &= [self registerFormat:@"hostname" withRegularExpression:[self hostnameRegularExpression] error:NULL];
        success &= [self registerFormat:@"uri" withRegularExpression:[self URIRegularExpression] error:NULL];

        success &= [self registerFormat:@"ipv4" withBlock:[self IPv4AddressValidationBlock] error:NULL];
        success &= [self registerFormat:@"ipv6" withBlock:[self IPv6AddressValidationBlock] error:NULL];
        
        NSAssert(success, @"Registering standard formats must succeed!");
    }
}

- (instancetype)initWithFormatName:(NSString *)formatName
{
    self = [super init];
    if (self) {
        _formatName = [formatName copy];
    }
    
    return self;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"{ format: %@ }", self.formatName];
}

+ (NSSet<NSString *> *)assignedKeywords
{
    return [NSSet setWithObject:kSchemaKeywordFormat];
}

+ (instancetype)validatorWithDictionary:(NSDictionary<NSString *, id> *)schemaDictionary schemaFactory:(__unused VVJSONSchemaFactory *)schemaFactory error:(NSError *__autoreleasing *)error
{
    id formatObject = schemaDictionary[kSchemaKeywordFormat];
    
    if ([formatObject isKindOfClass:[NSString class]]) {
        return [[self alloc] initWithFormatName:formatObject];
    } else {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaDictionary];
        }
        return nil;
    }
}

- (NSArray<VVJSONSchema *> *)subschemas
{
    return nil;
}

- (BOOL)validateInstance:(id)instance inContext:(VVJSONSchemaValidationContext *)context error:(NSError *__autoreleasing *)error
{
    BOOL success;
    NSRegularExpression *regexp = [self.class regularExpressionForFormat:self.formatName];
    if (regexp != nil) {
        if ([instance isKindOfClass:[NSString class]]) {
            NSRange fullRange = NSMakeRange(0, [(NSString *)instance length]);
            success = [regexp numberOfMatchesInString:instance options:(NSMatchingOptions)0 range:fullRange] != 0;
        } else {
            // silently succeed in case of unsupported instance type
            success = YES;
        }
    } else {
        VVJSONSchemaFormatValidatorBlock block = [self.class validationBlockForFormat:self.formatName];
        if (block != nil) {
            success = block(instance);
        } else {
            // silently succeed in case of unknown format name
            success = YES;
        }
    }
    
    if (success == NO) {
        if (error != NULL) {
            NSString *failureReason = @"Object does not validate against the format.";
            *error = [NSError vv_JSONSchemaValidationErrorWithFailingValidator:self reason:failureReason context:context];
        }
    }
    return success;
}

#pragma mark - Formats registration

// maps format names to regular expressions validating them
static NSMutableDictionary<NSString *, NSRegularExpression *> *regularExpressionFormats;

+ (NSRegularExpression *)regularExpressionForFormat:(NSString *)format
{
    if (regularExpressionFormats == nil) {
        return nil;
    }
    
    @synchronized(regularExpressionFormats) {
        return regularExpressionFormats[format];
    }
}

+ (BOOL)registerFormat:(NSString *)format withRegularExpression:(NSRegularExpression *)regularExpression error:(NSError * __autoreleasing *)error
{
    NSParameterAssert(format);
    NSParameterAssert(regularExpression);
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        regularExpressionFormats = [NSMutableDictionary dictionary];
    });
    
    @synchronized(regularExpressionFormats) {
        if (regularExpressionFormats[format] == nil && [self validationBlockForFormat:format] == nil) {
            regularExpressionFormats[format] = regularExpression;
            return YES;
        } else {
            if (error != NULL) {
                *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeFormatNameAlreadyDefined failingObject:format];
            }
            return NO;
        }
    }
}

// maps format names to blocks validating them
static NSMutableDictionary<NSString *, VVJSONSchemaFormatValidatorBlock> *blockBasedFormats;

+ (VVJSONSchemaFormatValidatorBlock)validationBlockForFormat:(NSString *)format
{
    if (blockBasedFormats == nil) {
        return nil;
    }
    
    @synchronized(blockBasedFormats) {
        return blockBasedFormats[format];
    }
}

+ (BOOL)registerFormat:(NSString *)format withBlock:(VVJSONSchemaFormatValidatorBlock)block error:(NSError * __autoreleasing *)error
{
    NSParameterAssert(format);
    NSParameterAssert(block);
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        blockBasedFormats = [NSMutableDictionary dictionary];
    });
    
    @synchronized(blockBasedFormats) {
        if (blockBasedFormats[format] == nil && [self regularExpressionForFormat:format] == nil) {
            blockBasedFormats[format] = block;
            return YES;
        } else {
            if (error != NULL) {
                *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeFormatNameAlreadyDefined failingObject:format];
            }
            return NO;
        }
    }
}

#pragma mark - Standard formats

+ (VVJSONSchemaFormatValidatorBlock)IPv4AddressValidationBlock
{
    return ^BOOL(id instance) {
        if ([instance isKindOfClass:[NSString class]] == NO) {
            return NO;
        }
        
        const char *utf8 = [instance UTF8String];
        struct in_addr dst;
        int result = inet_pton(AF_INET, utf8, &dst);
        
        return result == 1;
    };
}

+ (VVJSONSchemaFormatValidatorBlock)IPv6AddressValidationBlock
{
    return ^BOOL(id instance) {
        if ([instance isKindOfClass:[NSString class]] == NO) {
            return NO;
        }
        
        const char *utf8 = [instance UTF8String];
        struct in_addr dst;
        int result = inet_pton(AF_INET6, utf8, &dst);
        
        return result == 1;
    };
}

+ (NSRegularExpression *)dateTimeRegularExpression
{
    NSString *pattern = @"^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(?:.\\d+)?((\\-|\\+)\\d{2}:\\d{2}|Z)$";
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:(NSRegularExpressionOptions)0 error:NULL];
    NSAssert(regexp != nil, @"Format regular expression must be valid.");
    
    return regexp;
}

+ (NSRegularExpression *)emailRegularExpression
{
    // Credit: HTML5 W3C Recommendation
    // http://www.w3.org/TR/html5/forms.html#valid-e-mail-address
    // Note that this regular expression is, strictly, a violation of the RFC 5322 standard.
    NSString *pattern =
    @"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
    @"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$";
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:(NSRegularExpressionOptions)0 error:NULL];
    NSAssert(regexp != nil, @"Format regular expression must be valid.");
    
    return regexp;
}

+ (NSRegularExpression *)hostnameRegularExpression
{
    NSString *pattern =
    @"^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])"
    @"(\\.([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9]))*$";
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:(NSRegularExpressionOptions)0 error:NULL];
    NSAssert(regexp != nil, @"Format regular expression must be valid.");
    
    return regexp;
}

+ (NSRegularExpression *)URIRegularExpression
{
    // Credit: Diego Perini
    // https://gist.github.com/dperini/729294
    // Copyright (c) 2010-2013 Diego Perini (http://www.iport.it)
    //
    // Permission is hereby granted, free of charge, to any person
    // obtaining a copy of this software and associated documentation
    // files (the "Software"), to deal in the Software without
    // restriction, including without limitation the rights to use,
    // copy, modify, merge, publish, distribute, sublicense, and/or sell
    // copies of the Software, and to permit persons to whom the
    // Software is furnished to do so, subject to the following
    // conditions:
    //
    // The above copyright notice and this permission notice shall be
    // included in all copies or substantial portions of the Software.
    NSString *pattern =
    @"^"
    @"(?:(?:https?|ftp):\\/\\/)"
    @"(?:\\S+(?::\\S*)?@)?"
    @"(?:"
    @"(?!(?:10|127)(?:\\.\\d{1,3}){3})"
    @"(?!(?:169\\.254|192\\.168)(?:\\.\\d{1,3}){2})"
    @"(?!172\\.(?:1[6-9]|2\\d|3[0-1])(?:\\.\\d{1,3}){2})"
    @"(?:[1-9]\\d?|1\\d\\d|2[01]\\d|22[0-3])"
    @"(?:\\.(?:1?\\d{1,2}|2[0-4]\\d|25[0-5])){2}"
    @"(?:\\.(?:[1-9]\\d?|1\\d\\d|2[0-4]\\d|25[0-4]))"
    @"|"
    @"(?:(?:[a-z\\u00a1-\\uffff0-9]-*)*[a-z\\u00a1-\\uffff0-9]+)"
    @"(?:\\.(?:[a-z\\u00a1-\\uffff0-9]-*)*[a-z\\u00a1-\\uffff0-9]+)*"
    @"(?:\\.(?:[a-z\\u00a1-\\uffff]{2,}))"
    @")"
    @"(?::\\d{2,5})?"
    @"(?:\\/\\S*)?"
    @"$";
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:NULL];
    NSAssert(regexp != nil, @"Format regular expression must be valid.");
    
    return regexp;
}

@end
