//
//  XPCKitTests.m
//  XPCKitTests
//
//  Created by Adam Fedor on 5/9/16.
//  Copyright © 2016 Mustacheware. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XPCKit.h"

@interface XPCKitTests : XCTestCase

@end

@implementation XPCKitTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void) runEqualityOfXPCRoundtripForObject:(id)object
{
  XCTAssertNotNil(object, @"Source object is nil");
  
  xpc_object_t xpcObject = [object newXPCObject];
  XCTAssertNotNil(xpcObject, @"XPC Object is nil");
  
  id outObject = [NSObject objectWithXPCObject:xpcObject];
  XCTAssertNotNil(outObject, @"XPC-converted object is nil");
  
  if([object isKindOfClass:[NSDate class]]){
    NSTimeInterval delta = fabs([object timeIntervalSinceDate:outObject]);
    BOOL smallEnough = (delta < 0.000001);
    XCTAssertTrue(smallEnough, @"Date %@ was not equal to result %@", object, outObject);
  }else{
    XCTAssertEqualObjects(object, outObject, @"Object %@ was not equal to result %@", object, outObject);
  }  
}

#pragma mark Objects
- (void)testString
{
  [self runEqualityOfXPCRoundtripForObject:@""];
  [self runEqualityOfXPCRoundtripForObject:@"Hello world!"];
}

- (void)testNumbers
{
  [self runEqualityOfXPCRoundtripForObject:[NSNumber numberWithInt:0]];
  [self runEqualityOfXPCRoundtripForObject:[NSNumber numberWithInt:1]];
  [self runEqualityOfXPCRoundtripForObject:[NSNumber numberWithInt:-1]];
  [self runEqualityOfXPCRoundtripForObject:[NSNumber numberWithDouble:42.1]];
  [self runEqualityOfXPCRoundtripForObject:[NSNumber numberWithLong:42]];
  [self runEqualityOfXPCRoundtripForObject:[NSNumber numberWithUnsignedLong:42]];
  [self runEqualityOfXPCRoundtripForObject:(id)kCFBooleanTrue];
  [self runEqualityOfXPCRoundtripForObject:(id)kCFBooleanFalse];
  [self runEqualityOfXPCRoundtripForObject:[NSNumber numberWithBool:YES]];
  [self runEqualityOfXPCRoundtripForObject:[NSNumber numberWithBool:NO]];
}

- (void)testArrays
{
  [self runEqualityOfXPCRoundtripForObject:[NSArray array]];
  [self runEqualityOfXPCRoundtripForObject:[NSArray arrayWithObject:@"foo"]];
  [self runEqualityOfXPCRoundtripForObject:[NSArray arrayWithObjects:@"foo", @"bar", @"baz", nil]];
}

- (void)testDictionaries
{
  [self runEqualityOfXPCRoundtripForObject:[NSDictionary dictionary]];
  [self runEqualityOfXPCRoundtripForObject:[NSDictionary dictionaryWithObject:@"bar" forKey:@"foo"]];
  [self runEqualityOfXPCRoundtripForObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                             @"bar", @"foo",
                                             @"42", @"baz",
                                             [NSNumber numberWithInt:42], @"theAnswerToEverything",
                                             nil]];
}

-(void)testDates
{
  [self runEqualityOfXPCRoundtripForObject:[NSDate date]];
  [self runEqualityOfXPCRoundtripForObject:[NSDate dateWithTimeIntervalSince1970:20.]];
  [self runEqualityOfXPCRoundtripForObject:[NSDate dateWithTimeIntervalSince1970:2000000.]];
  [self runEqualityOfXPCRoundtripForObject:[NSDate dateWithTimeIntervalSince1970:2000000000.]];
  [self runEqualityOfXPCRoundtripForObject:[NSDate dateWithTimeIntervalSinceNow:10.]];
  [self runEqualityOfXPCRoundtripForObject:[NSDate dateWithTimeIntervalSinceNow:-10.]];
  [self runEqualityOfXPCRoundtripForObject:[NSDate dateWithTimeIntervalSinceNow:10000.]];
  [self runEqualityOfXPCRoundtripForObject:[NSDate dateWithTimeIntervalSinceNow:-10000.]];
}

- (void)testUUID
{
  // UUIDs are unique, so test a few at random
  XCTAssertFalse([[XPCUUID uuid] isEqual:[XPCUUID uuid]], @"Two identical UUIDs");
  XCTAssertFalse([[XPCUUID uuid] isEqual:[XPCUUID uuid]], @"Two identical UUIDs");
  XCTAssertFalse([[XPCUUID uuid] isEqual:[XPCUUID uuid]], @"Two identical UUIDs");
  
  [self runEqualityOfXPCRoundtripForObject:[XPCUUID uuid]];
  [self runEqualityOfXPCRoundtripForObject:[XPCUUID uuid]];
  [self runEqualityOfXPCRoundtripForObject:[XPCUUID uuid]];
}

- (void)testData
{
  const char *pointer = "Bytes on a string";
  NSData *inData = [NSData dataWithBytes:(const void *)pointer length:sizeof(char)*strlen(pointer)];
  
  NSLog(@"NSData is %@", inData);
  [self runEqualityOfXPCRoundtripForObject:inData];
}

- (void)testXPCMessage
{
  // Create archivable test object
  NSSet *inTestSet = [NSSet setWithObjects:@"Hallo", @"Ballo", @"Drallo", nil];
  
  // Store/retrieve archivable test object in/from message:
  XPCMessage *message = [XPCMessage message];
  [message setObject:inTestSet forKey:@"greetings"];
  NSSet *outTestSet = (NSSet *) [message objectForKey:@"greetings"];
  
  XCTAssertEqualObjects(inTestSet, outTestSet,@"Input object %@ is not equal to output object %@", inTestSet, outTestSet);
}

@end
