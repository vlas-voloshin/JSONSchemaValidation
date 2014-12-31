//
//  NSObject+VVJSONComparisonTests.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 1/01/2015.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSObject+VVJSONComparison.h"
#import "NSNumber+VVJSONNumberTypes.h"
#import "NSArray+VVJSONComparison.h"
#import "NSDictionary+VVJSONComparison.h"

@interface NSObject_VVJSONComparisonTests : XCTestCase

@end

@implementation NSObject_VVJSONComparisonTests

- (void)testObjectsComparison
{
    XCTAssertFalse([@[ @"test" ] vv_isJSONTypeStrictEqual:@YES]);
    XCTAssertFalse([@{ @"key" : @"object" } vv_isJSONTypeStrictEqual:@YES]);
    XCTAssertFalse([@"test" vv_isJSONTypeStrictEqual:@YES]);
    XCTAssertFalse([@[ @"test" ] vv_isJSONTypeStrictEqual:@1]);
    XCTAssertFalse([@{ @"key" : @"object" } vv_isJSONTypeStrictEqual:@1]);
    XCTAssertFalse([@"test" vv_isJSONTypeStrictEqual:@1]);
    
    XCTAssertTrue([@[ @"test" ] vv_isJSONTypeStrictEqual:@[ @"test" ]]);
    XCTAssertTrue([@{ @"key" : @"object" } vv_isJSONTypeStrictEqual:@{ @"key" : @"object" }]);
    XCTAssertTrue([@"test" vv_isJSONTypeStrictEqual:@"test"]);
    XCTAssertTrue([@1 vv_isJSONTypeStrictEqual:@1]);
    
    XCTAssertFalse([@[ @1 ] vv_isJSONTypeStrictEqual:@[ @1.0 ]]);
    XCTAssertTrue([@[ @1 ] vv_isJSONTypeStrictEqual:@[ @1 ]]);
    XCTAssertFalse([@{ @"key" : @1 } vv_isJSONTypeStrictEqual:@{ @"key" : @1.0 }]);
    XCTAssertTrue([@{ @"key" : @1.0 } vv_isJSONTypeStrictEqual:@{ @"key" : @1.0 }]);
    
    id object1 = @[ @{ @"key" : @1.0 }, @2.0 ];
    id object2 = @[ @{ @"key" : @YES }, @2.0 ];
    XCTAssertFalse([object1 vv_isJSONTypeStrictEqual:object2]);
    object1 = @[ @{ @"key" : @1.0 }, @NO ];
    object2 = @[ @{ @"key" : @1.0 }, @NO ];
    XCTAssertTrue([object1 vv_isJSONTypeStrictEqual:object2]);
    object1 = @{ @"key" : @[ @1.0, @0 ] };
    object2 = @{ @"key" : @[ @1, @NO ] };
    XCTAssertFalse([object1 vv_isJSONTypeStrictEqual:object2]);
    object1 = @{ @"key" : @[ @1.0, @1, @YES ] };
    object2 = @{ @"key" : @[ @1, @YES, @1.0 ] };
    XCTAssertFalse([object1 vv_isJSONTypeStrictEqual:object2]);
    object1 = @{ @"key" : @[ @1.0, @0, @YES ] };
    object2 = @{ @"key" : @[ @1.0, @0, @YES ] };
    XCTAssertTrue([object1 vv_isJSONTypeStrictEqual:object2]);
}

- (void)testNumbersComparison
{
    XCTAssertFalse([@(YES) vv_isStrictEqualToNumber:@(NO)]);
    XCTAssertTrue([@(YES) vv_isStrictEqualToNumber:@(YES)]);
    XCTAssertFalse([@(10) vv_isStrictEqualToNumber:@(20)]);
    XCTAssertTrue([@(30) vv_isStrictEqualToNumber:@(30)]);
    XCTAssertFalse([@(10.0) vv_isStrictEqualToNumber:@(10.1)]);
    XCTAssertTrue([@(20.0) vv_isStrictEqualToNumber:@(20.0)]);
    
    XCTAssertFalse([@(YES) vv_isStrictEqualToNumber:@(1)]);
    XCTAssertFalse([@(NO) vv_isStrictEqualToNumber:@(0)]);
    XCTAssertFalse([@(YES) vv_isStrictEqualToNumber:@(1.0)]);
    XCTAssertFalse([@(NO) vv_isStrictEqualToNumber:@(0.0)]);
    XCTAssertFalse([@(1) vv_isStrictEqualToNumber:@(1.0)]);
    XCTAssertFalse([@(0) vv_isStrictEqualToNumber:@(0.0)]);
}

@end
