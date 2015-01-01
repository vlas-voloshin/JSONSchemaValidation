//
//  VVJSONSchemaStringValidator.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 31/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVJSONSchemaValidator.h"

@interface VVJSONSchemaStringValidator : NSObject <VVJSONSchemaValidator>

@property (nonatomic, readonly, assign) NSUInteger maximumLength;
@property (nonatomic, readonly, assign) NSUInteger minimumLength;
@property (nonatomic, readonly, strong) NSRegularExpression *regularExpression;

@end
