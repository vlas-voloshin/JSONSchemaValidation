//
//  NSNumber+VVNumberTypesTests.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 30/12/2014.
//  Copyright (c) 2014 Vlas Voloshin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "NSNumber+VVNumberTypes.h"

@interface NSNumber_VVNumberTypesTests : XCTestCase

@end

@implementation NSNumber_VVNumberTypesTests

- (void)testBooleanTypes
{
    XCTAssertTrue([@(YES) vv_isBoolean]);
    XCTAssertTrue([@(NO) vv_isBoolean]);
    XCTAssertFalse([@(1) vv_isBoolean]);
    XCTAssertFalse([@(0) vv_isBoolean]);
    XCTAssertFalse([@(100) vv_isBoolean]);
    XCTAssertFalse([@(-100) vv_isBoolean]);
    XCTAssertFalse([@(0.0) vv_isBoolean]);
    XCTAssertFalse([@(1.0) vv_isBoolean]);
    XCTAssertFalse([@(1.3) vv_isBoolean]);
    XCTAssertFalse([@(-1.3) vv_isBoolean]);
    XCTAssertFalse([@(5e32) vv_isBoolean]);
}

- (void)testIntegerTypes
{
    XCTAssertFalse([@(YES) vv_isInteger]);
    XCTAssertFalse([@(NO) vv_isInteger]);
    XCTAssertTrue([@(1) vv_isInteger]);
    XCTAssertTrue([@(0) vv_isInteger]);
    XCTAssertTrue([@(100) vv_isInteger]);
    XCTAssertTrue([@(-100) vv_isInteger]);
    XCTAssertFalse([@(0.0) vv_isInteger]);
    XCTAssertFalse([@(1.0) vv_isInteger]);
    XCTAssertFalse([@(1.3) vv_isInteger]);
    XCTAssertFalse([@(-1.3) vv_isInteger]);
    XCTAssertFalse([@(5e32) vv_isInteger]);
}

- (void)testFloatTypes
{
    XCTAssertFalse([@(YES) vv_isFloat]);
    XCTAssertFalse([@(NO) vv_isFloat]);
    XCTAssertFalse([@(1) vv_isFloat]);
    XCTAssertFalse([@(0) vv_isFloat]);
    XCTAssertFalse([@(100) vv_isFloat]);
    XCTAssertFalse([@(-100) vv_isFloat]);
    XCTAssertTrue([@(0.0) vv_isFloat]);
    XCTAssertTrue([@(1.0) vv_isFloat]);
    XCTAssertTrue([@(1.3) vv_isFloat]);
    XCTAssertTrue([@(-1.3) vv_isFloat]);
    XCTAssertTrue([@(5e32) vv_isFloat]);
}

@end
