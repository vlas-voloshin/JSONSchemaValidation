//
//  VVJSONSchemaEnumValidator.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 31/12/2014.
//  Copyright (c) 2014 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVJSONInstanceValidator.h"

@interface VVJSONSchemaEnumValidator : NSObject <VVJSONInstanceValidator>

@property (nonatomic, readonly, strong) NSSet *valueOptions;

@end
