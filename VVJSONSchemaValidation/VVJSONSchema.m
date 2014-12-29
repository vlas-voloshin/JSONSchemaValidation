//
//  VVJSONSchema.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 28/12/2014.
//  Copyright (c) 2014 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchema.h"

@implementation VVJSONSchema

- (instancetype)initWithScopeURI:(NSURL *)uri title:(NSString *)title description:(NSString *)description validators:(NSSet *)validators
{
    NSParameterAssert(uri);
    
    self = [super init];
    if (self) {
        _uri = uri;
        _title = [title copy];
        _schemaDescription = [description copy];
        _validators = [validators copy];
    }
    
    return self;
}



@end
