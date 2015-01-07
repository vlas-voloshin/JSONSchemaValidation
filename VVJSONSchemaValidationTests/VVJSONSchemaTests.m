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
    VVJSONSchemaStorage *_referenceStorage;
    NSArray *_testSuite;
}

@end

@implementation VVJSONSchemaTests

- (void)setUp
{
    [super setUp];

    // prepare URLs of test cases
    NSArray *urls = [[NSBundle bundleForClass:[self class]] URLsForResourcesWithExtension:@"json" subdirectory:nil];
    if (urls.count == 0) {
        XCTFail(@"No JSON test cases found.");
    }
    
    // load all test cases
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
    
    // load reference schemas
    _referenceStorage = [self.class remoteSchemasReferenceStorage];
    
    NSLog(@"Loaded %lu test cases.", (unsigned long)testSuite.count);
}

+ (VVJSONSchemaStorage *)remoteSchemasReferenceStorage
{
    static NSString * const kBaseRemoteSchemasURIString = @"http://localhost:1234/";

    VVMutableJSONSchemaStorage *storage = [VVMutableJSONSchemaStorage storage];
    NSURL *baseRemoteSchemasURI = [NSURL URLWithString:kBaseRemoteSchemasURIString];
    
    NSArray *urls = [[NSBundle bundleForClass:[self class]] URLsForResourcesWithExtension:@"json" subdirectory:@"remotes"];
    for (NSURL *url in urls) {
        NSString *documentName = url.lastPathComponent;
        NSURL *schemaURI = [NSURL URLWithString:documentName relativeToURL:baseRemoteSchemasURI];
        [self addSchemaFromURL:url withScopeURI:schemaURI intoStorage:storage];
    }
    
    NSArray *subfolderURLs = [[NSBundle bundleForClass:[self class]] URLsForResourcesWithExtension:@"json" subdirectory:@"remotes/folder"];
    for (NSURL *url in subfolderURLs) {
        NSString *documentName = url.lastPathComponent;
        NSURL *schemaURI = [NSURL URLWithString:[@"folder" stringByAppendingPathComponent:documentName] relativeToURL:baseRemoteSchemasURI];
        [self addSchemaFromURL:url withScopeURI:schemaURI intoStorage:storage];
    }
    
    return [storage copy];
}

+ (void)addSchemaFromURL:(NSURL *)url withScopeURI:(NSURL *)scopeURI intoStorage:(VVMutableJSONSchemaStorage *)storage
{
    NSData *schemaData = [NSData dataWithContentsOfURL:url];
    VVJSONSchema *schema = [VVJSONSchema schemaWithData:schemaData baseURI:scopeURI referenceStorage:nil error:NULL];
    if (schema == nil) {
        [NSException raise:NSInternalInconsistencyException format:@"Failed to instantiate reference schema from %@.", url];
    }
    
    BOOL success = [storage addSchema:schema];
    if (success == NO) {
        [NSException raise:NSInternalInconsistencyException format:@"Failed to add reference schema from %@ into the storage.", url];
    }
}

- (void)testSchemasInstantiationOnly
{
    [self measureBlock:^{
        NSError *error = nil;
        for (VVJSONSchemaTestCase *testCase in self->_testSuite) {
            BOOL success = [testCase instantiateSchemaWithReferenceStorage:self->_referenceStorage error:&error];
            XCTAssertTrue(success, @"Failed to instantiate schema for test case '%@': %@.", testCase.testCaseDescription, error);
        }
    }];
}

- (void)testSchemasValidation
{
    // have to instantiate the schemas first!
    for (VVJSONSchemaTestCase *testCase in _testSuite) {
        BOOL success = [testCase instantiateSchemaWithReferenceStorage:_referenceStorage error:NULL];
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
    BOOL success = [testCase instantiateSchemaWithReferenceStorage:nil error:NULL];
    if (success == NO) {
        XCTFail(@"Invalid test case.");
        return;
    }
    CFTimeInterval firstInstantiationTime = CACurrentMediaTime() - startTime;
    NSLog(@"First instantiation time: %.2f ms", (firstInstantiationTime * 1000.0));
    
    uint64_t nanoseconds = dispatch_benchmark(1000, ^{
        [testCase instantiateSchemaWithReferenceStorage:nil error:NULL];
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

- (void)testMultithreading
{
    dispatch_queue_t queue = dispatch_queue_create("com.argentumko.VVJSONSchemaTests.Parallelism", DISPATCH_QUEUE_CONCURRENT);

    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"advanced-example" withExtension:@"json"];
    VVJSONSchemaTestCase *testCase = [[VVJSONSchemaTestCase testCasesWithContentsOfURL:url] firstObject];
    NSDictionary *schemaObject = testCase.schemaObject;
    
    for (NSUInteger parallelism = 0; parallelism < 10; parallelism++) {
        dispatch_async(queue, ^{
            VVJSONSchema *schema = [VVJSONSchema schemaWithDictionary:schemaObject baseURI:nil referenceStorage:self->_referenceStorage error:NULL];
            XCTAssertNotNil(schema);
        });
    }
    dispatch_sync(queue, ^{});
    
    [testCase instantiateSchemaWithReferenceStorage:_referenceStorage error:NULL];
    for (NSUInteger parallelism = 0; parallelism < 10; parallelism++) {
        dispatch_async(queue, ^{
            BOOL success = [testCase runTestsWithError:NULL];
            XCTAssertTrue(success);
        });
    }
    dispatch_sync(queue, ^{});
}

@end
