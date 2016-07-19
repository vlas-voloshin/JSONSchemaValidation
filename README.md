# VVJSONSchemaValidation

**JSON Schema draft 4 parsing and validation library written in Objective-C.**

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![CocoaPods](https://img.shields.io/cocoapods/v/VVJSONSchemaValidation.svg?maxAge=604800)]() [![CocoaPods](https://img.shields.io/cocoapods/p/VVJSONSchemaValidation.svg?maxAge=2592000)]() [![CocoaPods](https://img.shields.io/cocoapods/l/VVJSONSchemaValidation.svg?maxAge=2592000)]()

`VVJSONSchemaValidation` is a library that provides a set of classes for parsing [JSON Schema draft 4](http://json-schema.org/documentation.html) documents into native Objective-C objects and subsequently using them to validate JSON documents.

The main feature of the library is an ability to "compile" the schema into a network of objects that describe that schema, so that it could be cached and reused for validation of multiple JSON documents in a performant manner, similar to the way `NSRegularExpression` and `NSDateFormatter` classes are used. One of the possible use cases of this library could be early validation of JSON response received from a web service, based on expectations described within the app in a form of JSON Schema.

`VVJSONSchemaValidation` supports all validation keywords of JSON Schema draft 4. It is also possible to extend the functionality of the library by defining custom keywords to be used with specific metaschema URIs and custom formats for the `format` validation keyword. Note that JSON Schema draft 3 is not supported at the moment. There are also a few important limitations, including usage of external schema references, listed under [Caveats and limitations](#caveats-and-limitations).

## Requirements

`VVJSONSchemaValidation` currently supports building against iOS 7 SDK or higher and OS X SDK 10.9 or higher with Xcode 7 and ARC enabled. Library can be linked to Objective-C and Swift targets.

## Installation

### CocoaPods

1. Add this line to your `Podfile`:

	```
	pod 'VVJSONSchemaValidation'
	```
	
2. Import library header in your source files:
	* Objective-C: `#import <VVJSONSchemaValidation/VVJSONSchema.h>`
	* Swift: `import VVJSONSchemaValidation`

### Framework (iOS 8.0+ and OS X)

1. Download and copy the repository source files into your project, or add it as a submodule to your git repository.
2. Drag&drop `VVJSONSchemaValidation.xcodeproj` into your project or workspace in Xcode.
3. Add `VVJSONSchemaValidation.framework` from `VVJSONSchemaValidation-iOS` or `VVJSONSchemaValidation-OSX` target (depending on your target architecture) to `Your Target` → Build Phases → Link Binary With Libraries.
4. Import library header in your source files:
	* Objective-C: `#import <VVJSONSchemaValidation/VVJSONSchemaValidation.h>`
	* Swift: `import VVJSONSchemaValidation`

### Static library (iOS)

1. Download and copy the repository source files into your project, or add it as a submodule to your git repository.
2. Drag&drop `VVJSONSchemaValidation.xcodeproj` into your project or workspace in Xcode.
3. Add `libVVJSONSchemaValidation.a` to `Your Target` → Build Phases → Link Binary With Libraries.
4. Add project path to `Your Target` → Build Settings → Header Search Paths (e.g. `"$(SRCROOT)/MyAwesomeProject/Vendor/VVJSONSchemaValidation/"`).
5. Add `-ObjC` flag to `Your Target` → Build Settings → Other Linker Flags to ensure that categories defined in the static library are loaded.
6. Import library header in your source files:
	* Objective-C: `#import <VVJSONSchemaValidation/VVJSONSchema.h>`
	* Swift: `import VVJSONSchemaValidation`

### Source files

1. Download and copy the repository source files into your project, or add it as a submodule to your git repository.
2. Add the contents of `VVJSONSchemaValidation` directory into your project in Xcode.
3. Import library header: `#import "VVJSONSchema.h"`.

## Usage

After importing the library header/module, use `VVJSONSchema` class to construct schema objects from `NSData` instances:

``` objective-c
NSData *schemaData = [NSData dataWithContentsOfURL:mySchemaURL];
NSError *error = nil;
VVJSONSchema *schema = [VVJSONSchema schemaWithData:schemaData baseURI:nil referenceStorage:nil error:&error];
```

or from parsed JSON instances:

``` objective-c
NSData *schemaData = [NSData dataWithContentsOfURL:mySchemaURL];
// note that this object might be not an NSDictionary if schema JSON is invalid
NSDictionary *schemaJSON = [NSJSONSerialization JSONObjectWithData:schemaData options:0 error:NULL];
NSError *error = nil;
VVJSONSchema *schema = [VVJSONSchema schemaWithDictionary:schemaJSON baseURI:nil referenceStorage:nil error:&error];
```

Optional `baseURI` parameter specifies the base scope resolution URI of the constructed schema. Default scope resolution URI is empty.
Optional `referenceStorage` parameter specifies a `VVJSONSchemaStorage` object that should contain "remote" schemas referenced in the instantiated schema. See [Schema storage and external references](#schema-storage-and-external-references) for more details.

After constructing a schema object, you can use it to validate JSON instances. Again, these instances could be provided either as `NSData` objects:

``` objective-c
NSData *jsonData = [NSData dataWithContentsOfURL:myJSONURL];
NSError *validationError = nil;
BOOL success = [schema validateObjectWithData:jsonData error:&validationError];
```

or parsed JSON instances:

``` objective-c
NSData *jsonData = [NSData dataWithContentsOfURL:myJSONURL];
id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL];
NSError *validationError = nil;
BOOL success = [schema validateObject:json error:&validationError];
```

In case of successful validation, the validation method returns `YES`. Otherwise, it returns `NO` and passed `NSError` object contains a description of encountered validation error. The error object will contain the following keys in its `userInfo` dictionary:

* `VVJSONSchemaErrorFailingObjectKey` (`object`) – contains a JSON representation of the object which failed validation.
* `VVJSONSchemaErrorFailingValidatorKey` (`validator`) – references the failed validator object. Its description contains its class and validation parameters.
* `VVJSONSchemaErrorFailingObjectPathKey` (`path`) – contains the full path to the failed object in a form of JSON Pointer. An empty path means that the root-level object failed validation.

### Schema storage and external references

Resolving external schema references from network locations is deliberately not supported by `VVJSONSchema`. However, these external references can be provided using `VVJSONSchemaStorage` class. For example, if Schema A references Schema B at `http://awesome.org/myHandySchema.json`, the latter can be downloaded in advance and provided during instantiation of Schema A:

``` objective-c
// obviously, in a real application, data from a website must not be loaded synchronously like this
NSURL *schemaBURL = [NSURL URLWithString:@"http://awesome.org/myHandySchema.json"];
NSData *schemaBData = [NSData dataWithContentsOfURL:schemaBURL];
VVJSONSchema *schemaB = [VVJSONSchema schemaWithData:schemaBData baseURI:schemaBURL referenceStorage:nil error:NULL];
VVJSONSchemaStorage *referenceStorage = [VVJSONSchemaStorage storageWithSchema:schemaB];

// ... retrieve schemaAData ...

VVJSONSchema *schemaA = [VVJSONSchema schemaWithData:schemaAData baseURI:nil referenceStorage:referenceStorage error:NULL];
```

`VVJSONSchemaStorage` objects can also be used in general to store schemas and retrieve them by their scope URI. Please refer to the documentation of that class in the source code for more information.

## Performance

Note that constructing a `VVJSONSchema` object from a JSON representation incurs some computational cost in case of complex schemas. For this reason, if a single schema is expected to be used for validation multiple times, make sure you cache and reuse the corresponding `VVJSONSchema` object.

On iPhone 5s, `VVJSONSchema` shows the following performance when instantiating and validating against a medium-complexity schema (see [advanced-example.json](VVJSONSchemaValidationTests/JSON/advanced-example.json)):

| Operation                  | Minimum | Average | Maximum |
|----------------------------|---------|---------|---------|
| Instantiation + validation | 4 ms    | 15 ms   | 24 ms   |
| Instantiation only         | 3 ms    | 12 ms   | 20 ms   |
| Validation only            | 1.2 ms  | 3.5 ms  | 5.8 ms  |

Project uses a major part of [JSON Schema Test Suite](https://github.com/json-schema/JSON-Schema-Test-Suite) to test its functionality. Running this suite on 2.3 GHz Intel Core i7 processor shows the following performance:

| Operation                   | Time    |
|-----------------------------|---------|
| Single suite instantiation  | 16.2 ms |
| Average suite instantiation | 10.9 ms |
| First suite validation      | 3.69 ms |
| Average suite validation    | 3.44 ms |

## Extending

Using `+[VVJSONSchema registerValidatorClass:forMetaschemaURI:withError:]` method, custom JSON Schema keywords can be registered for the specified custom metaschema URI that must be present in the `$schema` property of the instantiated root schemas. Schema keywords are validated using objects conforming to `VVJSONSchemaValidator` protocol. Please refer to `VVJSONSchema` class documentation in the source code for more information.

Using `+[VVJSONSchemaFormatValidator registerFormat:withRegularExpression:error:]` and `+[VVJSONSchemaFormatValidator registerFormat:withBlock:error:]` methods, custom format names can be registered to be used in the built-in `format` keyword validator class to validate custom formats without the need to modify library code. Please refer to `VVJSONSchemaFormatValidator` class documentation in the source code for more information.

## Thread safety

`VVJSONSchema` and all objects it is composed of are immutable after being constructed and thus thread-safe, so a single schema can be used to validate multiple JSON documents in parallel threads. It is also possible to construct multiple `VVJSONSchema` instances in separate threads, as long as no thread attempts to register additional schema keywords in the process.

## Caveats and limitations

- Regular expression patterns are validated using `NSRegularExpression`, which uses ICU implementation, not ECMA 262. Thus, some features like look-behind are not supported.
- Loading schema references from external locations is not supported. See [Schema storage and external references](#schema-storage-and-external-references) for more details.
- Schema keywords defined inside a schema reference (object with "$ref" property) are ignored as per [JSON Reference specification draft](https://tools.ietf.org/html/draft-pbryan-zyp-json-ref-03).

## License

`VVJSONSchemaValidation` is available under the MIT license. See the LICENSE file for more info.
