//
//  Streamlyne_iOS_SDKTests.m
//  Streamlyne-iOS-SDKTests
//
//  Created by Glavin Wiechert on 11/15/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "StreamlyneSDK.h"

@interface Streamlyne_iOS_SDKTests : XCTestCase

@end

@implementation Streamlyne_iOS_SDKTests

// Macro - Set the flag for block completion
#define StartBlock() __block BOOL waitingForBlock = YES
// Macro - Set the flag to stop the loop
#define EndBlock() waitingForBlock = NO
// Macro - Wait and loop until flag is set
#define WaitUntilBlockCompletes() WaitWhile(waitingForBlock)
// Macro - Wait for condition to be NO/false in blocks and asynchronous calls
// Each test should have its own instance of a BOOL condition because of non-thread safe operations
#define WaitWhile(condition) \
do { \
while(condition) { \
[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]]; \
} \
} while(0)

//
#define XCTAssertStringEqual(a, b, format) \
(XCTAssertTrue([a isEqualToString:b], format) );


//
- (void)setUp
{
    [super setUp];
    
    NSLog(@"setUp");
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    SLAPIManager *manager = [SLAPIManager sharedManager];
    //[manager setBaseURL:[NSURL URLWithString:@"http://54.208.98.191:5000/api/"]];
    //    [manager setBaseURL:[NSURL URLWithString:@"http://localhost:5000/api/"]];
    [manager setHost:@"localhost:5000"];
    
//    [[SLAPIManager sharedManager]
//        authenticateWithUserEmail:@"testing@streamlyne.co"
//        withPassword:@"testing"
//        withOrganization:@"test"];
    
    [MagicalRecord setDefaultModelFromClass:[self class]];
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
    
    NSLog(@"Manager: %@", manager);
}

- (void)tearDown
{
    NSLog(@"tearDown");
    
    [MagicalRecord cleanUp];
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testPasswordSaving
{
    NSString *password = @"thisIsATest";
    NSString *encoded = @"99ca2860a3204a9f4e50d6940a67f5ed279f45a9";
    NSLog(@"%@ == %@", encoded, [SLAPIManager sha1:password]);
    XCTAssertStringEqual(encoded, [SLAPIManager sha1:password], @"Password should have been correctly encoded.");
    
    NSLog(@"%@", [SLAPIManager sha1:@"password"]);
    
    SLAPIManager *manager = [SLAPIManager sharedManager];
    [manager setPassword:@"thisIsATest"];
    XCTAssertStringEqual(encoded, manager.userPassword, @"Password should have been encoded when saved.");
    
}

- (void) testHMAC
{
    NSString *message = @"ILove2Test!tTest!t";
    NSString *secret = @"Streamlyne";
    NSString *hmac = @"1c2c34e017a17a6ae42c0dbdf6a3586f6735de3b";
    
    NSString *result = [SLAPIManager hmac:message withSecret:secret];
    XCTAssertStringEqual(result, hmac, @"HMACs should be the same.");
}

- (void) testAuthentication
{
    
    StartBlock();
    SLAPIManager *manager = [SLAPIManager sharedManager];
    
    [manager authenticateWithUserEmail:@"test@test.co"
                          withPassword:@"password"
                      withOrganization:@"test"]
    .then(^() {
        XCTAssertTrue(true, @"PARTY. IT WORKED.");
    }).catch(^(NSError *error) {
        XCTFail(@"%@", error);
    })
    .finally(^() {
        EndBlock();
    });
    
    WaitUntilBlockCompletes();
    
}

- (void) testAssets
{
    
    StartBlock();
    
    [SLAsset readAll]
    .then(^(NSArray *assets) {
        NSLog(@"%@", assets);
        
    })
    .catch(^(NSError *error) {
        NSLog(@"%@", error);
        XCTFail(@"%@", error);
    })
    .finally(^() {
        EndBlock();
    });
    
    WaitUntilBlockCompletes();
    
}


@end
