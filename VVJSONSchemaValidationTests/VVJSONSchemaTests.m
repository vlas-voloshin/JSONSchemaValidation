//
//  VVJSONSchemaTests.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 30/12/2014.
//  Copyright (c) 2014 Vlas Voloshin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VVJSONSchema.h"
#import "VVJSONSchemaTestCase.h"

@interface VVJSONSchemaTests : XCTestCase
{
    NSArray *_testSuite;
}

@end

@implementation VVJSONSchemaTests

- (void)setUp
{
    [super setUp];

    NSArray *urls = [[NSBundle bundleForClass:[self class]] URLsForResourcesWithExtension:@"json" subdirectory:nil];
    if (urls.count == 0) {
        XCTFail(@"No JSON test cases found.");
    }
    
    NSMutableArray *testSuite = [NSMutableArray array];
    for (NSURL *url in urls) {
        NSArray *testCases = [VVJSONSchemaTestCase testCasesWithContentsOfURL:url];
        if (testCases != nil) {
            [testSuite addObjectsFromArray:testCases];
        } else {
            XCTFail(@"Failed to parse test cases from %@.", url);
        }
    }
    
    _testSuite = [testSuite copy];
    
    NSLog(@"Loaded %lu test cases.", (unsigned long)testSuite.count);
}

- (void)testSchemasInstantiationOnly
{
    [self measureBlock:^{
        NSError *error = nil;
        for (VVJSONSchemaTestCase *testCase in self->_testSuite) {
            BOOL success = [testCase instantiateSchemaWithError:&error];
            XCTAssertTrue(success, @"Failed to instantiate schema for test case '%@': %@.", testCase.testCaseDescription, error);
        }
    }];
}

- (void)testSchemasValidation
{
    // have to instantiate the schemas first!
    for (VVJSONSchemaTestCase *testCase in _testSuite) {
        BOOL success = [testCase instantiateSchemaWithError:NULL];
        if (success == NO) {
            XCTFail(@"Failed to instantiate schema for test case '%@'.", testCase.testCaseDescription);
            return;
        }
    }
    
    [self measureBlock:^{
        NSError *error = nil;
        for (VVJSONSchemaTestCase *testCase in self->_testSuite) {
            NSLog(@"Testing %@...", testCase);
            BOOL success = [testCase runTestsWithError:&error];
            XCTAssertTrue(success, @"Test case '%@' failed: '%@'.", testCase.testCaseDescription, error);
        }
    }];
}

@end
