//
//  VVJSONSchemaTestCase.h
//  VVJSONSchemaValidation
//
//  Created by Vlas Voloshin on 30/12/2014.
//  Copyright (c) 2015 Vlas Voloshin. All rights reserved.
//

#import <XCTest/XCTest.h>

@class VVJSONSchema;
@class VVJSONSchemaStorage;

@interface VVJSONSchemaTestCase : NSObject

@property (nonatomic, readonly, copy) NSString *testCaseDescription;
@property (nonatomic, readonly, copy) NSDictionary *schemaObject;
@property (nonatomic, readonly, copy) NSArray *tests;
@property (nonatomic, readonly, strong) VVJSONSchema *schema;

+ (instancetype)testCaseWithObject:(NSDictionary *)testCaseObject;
+ (NSArray *)testCasesWithContentsOfURL:(NSURL *)testCasesJSONURL;

- (instancetype)initWithDescription:(NSString *)description schemaObject:(NSDictionary *)schemaObject tests:(NSArray *)tests;

- (BOOL)instantiateSchemaWithReferenceStorage:(VVJSONSchemaStorage *)schemaStorage error:(NSError * __autoreleasing *)error;
- (BOOL)runTestsWithError:(NSError * __autoreleasing *)error;

@end

@interface VVJSONSchemaTest : NSObject

@property (nonatomic, readonly, strong) NSString *testDescription;
@property (nonatomic, readonly, strong) id testData;
@property (nonatomic, readonly, assign) BOOL isValid;

+ (instancetype)testWithObject:(NSDictionary *)testObject;

- (instancetype)initWithDescription:(NSString *)description data:(id)data valid:(BOOL)valid;

@end
