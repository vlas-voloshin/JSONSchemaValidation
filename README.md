# VVJSONSchemaValidation

**JSON Schema draft 4 parsing and validation library written in Objective C.**

`VVJSONSchemaValidation` is a library that provides a set of classes for parsing [JSON Schema draft 4](http://json-schema.org/documentation.html) documents into native Objective C objects and subsequently using them to validate JSON documents.

The main feature of the library is an ability to "compile" the schema into a network of objects that describe that schema, so that it could be cached and reused for validation of multiple JSON documents in a performant manner, similar to the way `NSRegularExpression` and `NSDateFormatter` classes are used. One of the possible use cases of this library could be early validation of JSON response received from a web service, based on expectations described within the app in a form of JSON Schema.

`VVJSONSchemaValidation` supports all validation keywords of JSON Schema draft 4. It is also possible to extend the functionality of the library by defining custom keywords to be used with specific metaschema URIs. Note that JSON Schema draft 3 is not supported at the moment.

## Requirements

`VVJSONSchemaValidation` currently supports building against iOS 7 SDK or higher and OS X SDK 10.9 or higher, with ARC enabled.

## Installation

### CocoaPods

Coming soon!

### Source files

1. Download and copy the repository source files into your project, or add it as a submodule to your git repository.
2. Add the contents of `VVJSONSchemaValidation` directory into your project in Xcode.
3. Import library header: `#import "VVJSONSchema.h"`.

### Static library

1. Download and copy the repository source files into your project, or add it as a submodule to your git repository.
2. Drag&drop `VVJSONSchemaValidation.xcodeproj` into your project or workspace in Xcode.
3. Add `libVVJSONSchemaValidation-iOS.a` or `libVVJSONSchemaValidation-OSX.a` (depending on your target platform) to `Your Target` → Build Phases → Link Binary With Libraries.
4. Add project path to `Your Target` → Build Settings → Header Search Paths (e.g. `"$(SRCROOT)/MyAwesomeProject/Vendor/VVJSONSchemaValidation/"`).
5. Import library header: `#import <VVJSONSchemaValidation/VVJSONSchema.h>`.

## Usage

After importing `VVJSONSchema.h`, use `VVJSONSchema` class to construct schema objects from `NSData` instances:

``` objective-c
NSData *schemaData = [NSData dataWithContentsOfURL:mySchemaURL];
NSError *error = nil;
VVJSONSchema *schema = [VVJSONSchema schemaWithData:schemaData baseURI:nil error:&error];
```

or from parsed JSON instances:

``` objective-c
NSData *schemaData = [NSData dataWithContentsOfURL:mySchemaURL];
// note that this object might be not an NSDictionary if schema JSON is invalid
NSDictionary *schemaJSON = [NSJSONSerialization JSONObjectWithData:schemaData options:0 error:NULL];
NSError *error = nil;
VVJSONSchema *schema = [VVJSONSchema schemaWithDictionary:schemaJSON baseURI:nil error:&error];
```

If necessary, provide a `baseURI` parameter to specify the base scope resolution URI of the constructed schema. Default scope resolution URI is empty.

After constructing the schema object, use it to validate JSON instances. Again, these instances could be provided either as `NSData` objects:

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

In case of successful validation, the validation method returns `YES`. Otherwise, it returns `NO` and passed `NSError` object contains a description of encountered validation error.

## Performance

Note that constructing a `VVJSONSchema` object from a JSON representation incurs might incur some computational cost in case of complex schemas. For this reason, if a single schema is used for validation multiple times, make sure you cache and reuse the corresponding `VVJSONSchema` object.

On 2.3 GHz Intel Core i7 processor, `VVJSONSchema` shows the following performance when instantiating and validating against a medium-complexity schema (see [advanced-example.json](https://github.com/vlas-voloshin/JSONSchemaValidation/blob/master/VVJSONSchemaValidationTests/JSON/advanced-example.json)):

| Operation             | Time    |
|-----------------------|---------|
| First instantiation   | 8.97 ms |
| Average instantiation | 1.88 ms |
| First validation      | 1.04 ms |
| Average validation    | 0.26 ms |

## Extending

Using `+[VVJSONSchema registerValidatorClass:forMetaschemaURI:withError:]` method, custom JSON Schema keywords can be registered for the specified custom metaschema URI that must be present in the `$schema` property of the instantiated root schemas. Schema keywords are validated using objects conforming to `VVJSONSchemaValidator` protocol. Please refer to `VVJSONSchema` class documentation in the source code for more information.

## Tread safety

`VVJSONSchema` and all objects it is composed of are immutable after being constructed and thus thread-safe, so a single schema can be used to validate multiple JSON documents in parallel threads. It is also possible to construct multiple `VVJSONSchema` instances in separate threads, as long as no thread attempts to register additional schema keywords in the process.

## Caveats and known issues

- External schema references are not yet supported.
- Subschemas defined outside of keyword properties (like `definitions` and different validation keywords) are not yet supported.
- Regular expression patterns are validated using `NSRegularExpression`, which uses ICU implementation, not ECMA 262. Thus, some features like look-behind are not supported.
- It is currently possible to cause an infinite recursion loop by validating against a schema with keywords such as `dependencies`, `allOf`, `anyOf`, `oneOf` or `not` referencing the same subschema they are defined in, or creating such reference cycles with other schemas.

## License

`VVJSONSchemaValidation` is available under the MIT license. See the LICENSE file for more info.
