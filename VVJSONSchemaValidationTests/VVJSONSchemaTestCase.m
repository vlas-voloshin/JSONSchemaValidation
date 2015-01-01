//
//  VVJSONSchemaTestCase.m
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 30/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import "VVJSONSchemaTestCase.h"
#import "VVJSONSchema.h"

@interface VVJSONSchemaTestCase ()

@property (nonatomic, readonly, copy) NSDictionary *schemaObject;
@property (nonatomic, readonly, copy) NSArray *tests;
@property (nonatomic, strong) VVJSONSchema *schema;

@end

@implementation VVJSONSchemaTestCase

+ (instancetype)testCaseWithObject:(NSDictionary *)testCaseObject
{
    NSString *description = testCaseObject[@"description"];
    NSDictionary *schemaObject = testCaseObject[@"schema"];
    NSArray *testsData = testCaseObject[@"tests"];
    
    NSMutableArray *tests = [NSMutableArray arrayWithCapacity:testsData.count];
    for (NSDictionary *testData in testsData) {
        [tests addObject:[VVJSONSchemaTest testWithObject:testData]];
    }
    
    return [[self alloc] initWithDescription:description schemaObject:schemaObject tests:tests];
}

+ (NSArray *)testCasesWithContentsOfURL:(NSURL *)testCasesJSONURL
{
    NSData *data = [NSData dataWithContentsOfURL:testCasesJSONURL];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    if (json == nil) {
        return nil;
    }
    
    if ([json isKindOfClass:[NSDictionary class]]) {
        json = @[ json ];
    }
    
    NSMutableArray *testCases = [NSMutableArray arrayWithCapacity:[json count]];
    for (NSDictionary *testCaseData in json) {
        [testCases addObject:[self testCaseWithObject:testCaseData]];
    }
    
    return [testCases copy];
}

- (instancetype)initWithDescription:(NSString *)description schemaObject:(NSDictionary *)schemaObject tests:(NSArray *)tests
{
    self = [super init];
    if (self) {
        _testCaseDescription = [description copy];
        _schemaObject = [schemaObject copy];
        _tests = [tests copy];
    }
    
    return self;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"{ '%@', %lu tests }", self.testCaseDescription, (unsigned long)self.tests.count];
}

- (BOOL)instantiateSchemaWithError:(NSError *__autoreleasing *)error
{
    self.schema = [VVJSONSchema schemaWithDictionary:self.schemaObject baseURI:nil error:error];
    return (self.schema != nil);
}

- (BOOL)runTestsWithError:(NSError *__autoreleasing *)error
{
    VVJSONSchema *schema = self.schema;
    NSAssert(schema != nil, @"Instantiate the schema prior to running tests.");
    
    for (VVJSONSchemaTest *test in self.tests) {
        NSError *internalError = nil;
        BOOL valid = [schema validateObject:test.testData withError:&internalError];
        
        if (valid == NO && test.isValid == YES) {
            if (error != NULL) {
                *error = internalError;
            }
            NSLog(@"Test '%@' failed.", test);
            return NO;
        } else if (valid == YES && test.isValid == NO) {
            if (error != NULL) {
                *error = [NSError errorWithDomain:@"com.argentumko.JSONSchemaValidationTests" code:-1 userInfo:@{ NSLocalizedDescriptionKey : @"Invalid test has passed schema validation." }];
            }
            NSLog(@"Test '%@' failed.", test);
            return NO;
        }
    }
    
    return YES;
}

@end

@implementation VVJSONSchemaTest

+ (instancetype)testWithObject:(NSDictionary *)testObject
{
    NSString *description = testObject[@"description"];
    id testData = testObject[@"data"];
    BOOL valid = [testObject[@"valid"] boolValue];
    
    return [[self alloc] initWithDescription:description data:testData valid:valid];
}

- (instancetype)initWithDescription:(NSString *)description data:(id)data valid:(BOOL)valid
{
    self = [super init];
    if (self) {
        _testDescription = description;
        _testData = data;
        _isValid = valid;
    }
    
    return self;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@"{ '%@', isValid: %@ }", self.testDescription, self.isValid ? @"YES" : @"NO"];
}

@end
