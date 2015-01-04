//
//  VVJSONSchemaTests.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 30/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <QuartzCore/QuartzCore.h>
#import "VVJSONSchema.h"
#import "VVJSONSchemaTestCase.h"

extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));

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
            BOOL success = [testCase runTestsWithError:&error];
            XCTAssertTrue(success, @"Test case '%@' failed: '%@'.", testCase.testCaseDescription, error);
        }
    }];
}

- (void)testPerformance
{
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"advanced-example" withExtension:@"json"];
    VVJSONSchemaTestCase *testCase = [[VVJSONSchemaTestCase testCasesWithContentsOfURL:url] firstObject];

    CFTimeInterval startTime = CACurrentMediaTime();
    BOOL success = [testCase instantiateSchemaWithError:NULL];
    if (success == NO) {
        XCTFail(@"Invalid test case.");
        return;
    }
    CFTimeInterval firstInstantiationTime = CACurrentMediaTime() - startTime;
    NSLog(@"First instantiation time: %.2f ms", (firstInstantiationTime * 1000.0));
    
    uint64_t nanoseconds = dispatch_benchmark(1000, ^{
        [testCase instantiateSchemaWithError:NULL];
    });
    NSLog(@"Average instantiation time: %.2f ms", (nanoseconds * 1e-6));
    
    startTime = CACurrentMediaTime();
    success = [testCase runTestsWithError:NULL];
    if (success == NO) {
        XCTFail(@"Invalid test case.");
        return;
    }
    CFTimeInterval firstValidationTime = CACurrentMediaTime() - startTime;
    NSLog(@"First validation time: %.2f ms", (firstValidationTime * 1000.0));

    nanoseconds = dispatch_benchmark(1000, ^{
        [testCase runTestsWithError:NULL];
    });
    NSLog(@"Average validation time: %.2f ms", (nanoseconds * 1e-6));
}

// TODO: full-scale test case
// TODO: multi-threaded test case (single schema in multiple threads and multiple schemas in multiple threads)

@end
