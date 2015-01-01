//
//  VVJSONSchemaArrayValidator.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 1/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVJSONSchemaValidator.h"

@interface VVJSONSchemaArrayValidator : NSObject <VVJSONSchemaValidator>

@property (nonatomic, readonly, assign) NSUInteger maximumItems;
@property (nonatomic, readonly, assign) NSUInteger minimumItems;
@property (nonatomic, readonly, assign) BOOL uniqueItems;

@end
