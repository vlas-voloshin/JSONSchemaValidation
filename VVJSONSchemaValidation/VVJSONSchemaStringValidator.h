//
//  VVJSONSchemaStringValidator.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 31/12/2014.
//  Copyright (c) 2014 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVJSONInstanceValidator.h"

@interface VVJSONSchemaStringValidator : NSObject <VVJSONInstanceValidator>

@property (nonatomic, readonly, assign) NSUInteger maximumLength;
@property (nonatomic, readonly, assign) NSUInteger minimumLength;
@property (nonatomic, readonly, strong) NSRegularExpression *regularExpression;

@end
