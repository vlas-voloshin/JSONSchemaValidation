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

static NSString * const kSchemaFormatIPv4 = @"ipv4";
static NSString * const kSchemaFormatIPv6 = @"ipv6";

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

+ (NSSet *)assignedKeywords
{
    return [NSSet setWithObject:kSchemaKeywordFormat];
}

+ (instancetype)validatorWithDictionary:(NSDictionary *)schemaDictionary schemaFactory:(VVJSONSchemaFactory *)schemaFactory error:(NSError *__autoreleasing *)error
{
    id formatObject = schemaDictionary[kSchemaKeywordFormat];
    
    if ([formatObject isKindOfClass:[NSString class]] && [self isValidFormatName:formatObject]) {
        return [[self alloc] initWithFormatName:formatObject];
    } else {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeInvalidSchemaFormat failingObject:schemaDictionary failingValidator:nil];
        }
        return nil;
    }
}

+ (BOOL)isValidFormatName:(NSString *)formatName
{
    if ([self regularExpressionForFormatName:formatName] != nil) {
        return YES;
    }
    if ([formatName isEqualToString:kSchemaFormatIPv4] || [formatName isEqualToString:kSchemaFormatIPv6]) {
        return YES;
    }

    return NO;
}

- (NSArray *)subschemas
{
    return nil;
}

- (BOOL)validateInstance:(id)instance inContext:(VVJSONSchemaValidationContext *)context error:(NSError *__autoreleasing *)error
{
    // currently only strings are checked for format validity;
    // silently succeed if value of the instance is inapplicable
    if ([instance isKindOfClass:[NSString class]] == NO) {
        return YES;
    }
    
    BOOL success;
    NSRegularExpression *regexp = [self.class regularExpressionForFormatName:self.formatName];
    if (regexp != nil) {
        NSRange fullRange = NSMakeRange(0, [(NSString *)instance length]);
        success = [regexp numberOfMatchesInString:instance options:0 range:fullRange] != 0;
    } else if ([self.formatName isEqualToString:kSchemaFormatIPv4]) {
        success = [self.class validateIPv4Address:instance];
    } else if ([self.formatName isEqualToString:kSchemaFormatIPv6]) {
        success = [self.class validateIPv6Address:instance];
    } else {
        success = NO;
    }
    
    if (success == NO) {
        if (error != NULL) {
            *error = [NSError vv_JSONSchemaErrorWithCode:VVJSONSchemaErrorCodeValidationFailed failingObject:instance failingValidator:self];
        }
    }
    return success;
}

#pragma mark - Custom validation

+ (BOOL)validateIPv4Address:(NSString *)addressString
{
    const char *utf8 = [addressString UTF8String];
    struct in_addr dst;
    int result = inet_pton(AF_INET, utf8, &dst);
    
    return result == 1;
}

+ (BOOL)validateIPv6Address:(NSString *)addressString
{
    const char *utf8 = [addressString UTF8String];
    struct in_addr dst;
    int result = inet_pton(AF_INET6, utf8, &dst);
    
    return result == 1;
}

#pragma mark - Regular expressions

+ (NSRegularExpression *)regularExpressionForFormatName:(NSString *)formatName
{
    static NSDictionary *regularExpressions;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        dictionary[@"date-time"] = [self dateTimeRegularExpression];
        dictionary[@"email"] = [self emailRegularExpression];
        dictionary[@"hostname"] = [self hostnameRegularExpression];
        dictionary[@"uri"] = [self URIRegularExpression];
        
        regularExpressions = [dictionary copy];
    });
    
    return regularExpressions[formatName];
}

+ (NSRegularExpression *)dateTimeRegularExpression
{
    NSString *pattern = @"^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(?:.\\d+)?Z$";
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
    NSAssert(regexp != nil, @"Format regular expression must be invalid.");
    
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
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
    NSAssert(regexp != nil, @"Format regular expression must be invalid.");
    
    return regexp;
}

+ (NSRegularExpression *)hostnameRegularExpression
{
    NSString *pattern =
    @"^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])"
    @"(\\.([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9]))*$";
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:NULL];
    NSAssert(regexp != nil, @"Format regular expression must be invalid.");
    
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
    NSAssert(regexp != nil, @"Format regular expression must be invalid.");
    
    return regexp;
}

@end
