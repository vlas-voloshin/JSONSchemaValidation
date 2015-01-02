//
//  NSString+VVJSONPointer.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 2/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import "NSString+VVJSONPointer.h"

@implementation NSString (VVJSONPointer)

- (NSString *)vv_stringByEncodingAsJSONPointer
{
    NSString *string = self;
    
    string = [string stringByReplacingOccurrencesOfString:@"~" withString:@"~0"];
    string = [string stringByReplacingOccurrencesOfString:@"/" withString:@"~1"];
    
    return string;
}

- (NSString *)vv_stringByDecodingAsJSONPointer
{
    NSString *string = self;
    
    string = [string stringByReplacingOccurrencesOfString:@"~1" withString:@"/"];
    string = [string stringByReplacingOccurrencesOfString:@"~0" withString:@"~"];
    
    return string;
}

@end
