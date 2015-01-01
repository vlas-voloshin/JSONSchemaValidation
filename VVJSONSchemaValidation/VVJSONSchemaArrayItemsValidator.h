//
//  VVJSONSchemaArrayItemsValidator.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 1/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVJSONSchemaValidator.h"

@class VVJSONSchema;

@interface VVJSONSchemaArrayItemsValidator : NSObject <VVJSONSchemaValidator>

@property (nonatomic, readonly, strong) VVJSONSchema *itemsSchema;
@property (nonatomic, readonly, copy) NSArray *itemSchemas;

@property (nonatomic, readonly, strong) VVJSONSchema *additionalItemsSchema;
@property (nonatomic, readonly, assign) BOOL additionalItemsAllowed;

@end
