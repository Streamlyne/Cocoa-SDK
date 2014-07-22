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
@property (nonatomic, strong) SLClient *client;
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


// Put setup code here. This method is called before the invocation of each test method in the class.
- (void)setUp
{
    [super setUp];
    
    NSLog(@"setUp");
    
    self.client = [SLClient connectWithHost:@"localhost:5000"];
    
    [MagicalRecord setDefaultModelFromClass:[self class]];
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
    //    NSLog(@"default context: %@", [NSManagedObjectContext MR_defaultContext]);
    //    NSLog(@"inManagedObjectContext: %@", [NSManagedObjectContext MR_defaultContext].persistentStoreCoordinator.managedObjectModel.entities);
    
    
}

// Put teardown code here. This method is called after the invocation of each test method in the class.
- (void)tearDown
{
    NSLog(@"tearDown");
    
    [MagicalRecord cleanUp];
    
    [super tearDown];
}

- (void) testPasswordSaving
{
    NSString *password = @"thisIsATest";
    NSString *encoded = @"99ca2860a3204a9f4e50d6940a67f5ed279f45a9";
    NSLog(@"%@ == %@", encoded, [SLAdapter sha1:password]);
    XCTAssertStringEqual(encoded, [SLAdapter sha1:password], @"Password should have been correctly encoded.");
    
    NSLog(@"%@", [SLAdapter sha1:@"password"]);
    
    SLAdapter *manager = [SLAdapter sharedAdapter];
    [manager setPassword:@"thisIsATest"];
    XCTAssertStringEqual(encoded, manager.userPassword, @"Password should have been encoded when saved.");
    
}

- (void) testHMAC
{
    NSString *message = @"ILove2Test!tTest!t";
    NSString *secret = @"Streamlyne";
    NSString *hmac = @"1c2c34e017a17a6ae42c0dbdf6a3586f6735de3b";
    
    NSString *result = [SLAdapter hmac:message withSecret:secret];
    XCTAssertStringEqual(result, hmac, @"HMACs should be the same.");
}

- (void) testAuthentication
{
    
    StartBlock();
    SLAdapter *manager = [SLAdapter sharedAdapter];
    
    [manager authenticateWithUserEmail:@"test@streamlyne.co"
                          withPassword:@"password"
                      withOrganization:@"test"]
    .then(^() {
        XCTAssertTrue(true, @"PARTY. IT WORKED.");
    })
    .catch(^(NSError *error) {
        XCTFail(@"%@", error);
    })
    .finally(^() {
        EndBlock();
    });
    
    WaitUntilBlockCompletes();
    
}



- (void) testLogin
{
    
    StartBlock();
    
    [self.client authenticateWithUserEmail:@"test@streamlyne.co"
                              withPassword:@"password"
                          withOrganization:@"test"]
    .then(^(SLClient *client, SLUser *me) {
        NSLog(@"%@", me);
        XCTAssertTrue(me != nil, @"PARTY. IT WORKED.");
        XCTAssert([me.email isEqualToString:@"test@streamlyne.co"], @"Email of user should be the same as the one used for logging in.");
    }).catch(^(NSError *error) {
        EndBlock();
        XCTFail(@"%@", error);
    })
    .finally(^() {
        EndBlock();
    });
    
    WaitUntilBlockCompletes();
    
}

- (void) testDeserializeSingleAssetPayload
{
    NSDictionary *payload =  @{
                               @"_id": @{
                                       @"$oid": @"538770ab2fb05c514e6cb340"
                                       },
//                               @"date_created": @{@"$date": [[NSDate now] timeIntervalSince1970]/1000},
//                               @"date_updated": @{@"$date": [NSNull null]},
                               @"description": @"This is an Asset in a Unit Test.",
                               @"name": @"PV1234"
                               };
    SLSerializer *serialier = [[SLSerializer alloc] init];
    SLStore *store = [SLStore sharedStore];
    
    NSLog(@"Payload: %@", payload);
    
    NSDictionary *extracted = [serialier extractSingle:[SLAsset class] withPayload:payload withStore:store];
    
    NSLog(@"Extracted: %@", extracted);
    
    // Normalize ID
    XCTAssertStringEqual(payload[@"_id"][@"$oid"], extracted[@"nid"], @"ID should have been normalized.");
    // Attribute name change
    XCTAssertStringEqual(payload[@"description"], extracted[@"desc"], @"Attribute key should have been changed.");
    // TODO: Date Transform
    
}

- (void) testPushAssets
{
    
    NSDictionary *pushData = @{
                               @"nid": @"538770ab2fb05c514e6cb340",
                               @"dateCreated": [NSDate new],
                               @"dateUpdated": [NSDate new],
                               @"desc": @"This is an Asset in a Unit Test.",
                               @"name": @"PV1234"
                               };
    SLAsset *a1 = (SLAsset *)[[SLStore sharedStore] push:[SLAsset class] withData:pushData];
    
    XCTAssertStringEqual(pushData[@"nid"], a1.nid, @"`nid`s should match.");
    XCTAssertStringEqual(pushData[@"desc"], a1.desc, @"`desc`s should match.");
    XCTAssertStringEqual(pushData[@"name"], a1.name, @"`name`s should match.");
    
}

- (void) testAssets
{
    
    StartBlock();
    
    [self.client authenticateWithUserEmail:@"test@streamlyne.co"
                              withPassword:@"password"
                          withOrganization:@"test"]
    .then(^(SLClient *client, SLUser *me) {
        
        [SLAsset findAll]
        .then(^(NSArray *assets) {
            NSLog(@"Assets: %@", assets);
        })
        .catch(^(NSError *error) {
            NSLog(@"%@", error);
            EndBlock();
            XCTFail(@"%@", error);
        })
        .finally(^() {
            NSLog(@"Finally!");
            EndBlock();
        });
        
    });
    
    WaitUntilBlockCompletes();
    
}


@end
