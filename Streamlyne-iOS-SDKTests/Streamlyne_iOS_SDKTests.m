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
#define EndBlock() waitingForBlock = NO; \
WaitUntilBlockCompletes();
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

// Login Credentials
//#define SLLoginEmail @"test@test.co"
//#define SLLoginPassword @"test"
//#define SLLoginOrganization @"test"

#define SLLoginEmail @"glavin@streamlyne.co"
#define SLLoginPassword @"glavin"
#define SLLoginOrganization @"nevis"


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
    
    NSLog(@"SLLoginPassword: %@", [SLAdapter sha1:SLLoginPassword]);
    
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
    
    [manager authenticateWithUserEmail:SLLoginEmail
                          withPassword:SLLoginPassword
                      withOrganization:SLLoginOrganization]
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


- (void) testDeserializeSingleUserPayload
{
    NSTimeInterval ti = [[NSDate new] timeIntervalSince1970]/1000;
    NSNumber *tin = [NSNumber numberWithDouble:ti];
    
    NSDictionary *payload =  @{
                               @"_id": @{
                                       @"$oid": @"538770ab2fb05c514e6cb340"
                                       },
                               @"date_created": @{@"$date": tin},
                               @"date_updated": @{@"$date": tin},
                               @"email": SLLoginEmail,
                               @"first_name": @"Testie",
                               @"last_name": @"Testerson",
                               @"job_title": @"Tester at Streamlyne Technologies"
                               };
    SLSerializer *serialier = [[SLSerializer alloc] init];
    SLStore *store = [SLStore sharedStore];
    
    NSLog(@"Payload: %@", payload);
    
    NSDictionary *extracted = [serialier extractSingle:[SLUser class] withPayload:payload withStore:store];
    
    NSLog(@"Extracted: %@", extracted);
    
    // Normalize ID
    XCTAssertStringEqual(payload[@"_id"][@"$oid"], extracted[@"nid"], @"ID should have been normalized.");
    // Attribute name change
    XCTAssertStringEqual(payload[@"first_name"], extracted[@"firstName"], @"Attribute key should have been changed.");
    XCTAssertStringEqual(payload[@"last_name"], extracted[@"lastName"], @"Attribute key should have been changed.");
    XCTAssertStringEqual(payload[@"job_title"], extracted[@"jobTitle"], @"Attribute key should have been changed.");
    // Matching values, no normalization changes
    XCTAssertStringEqual(payload[@"email"], extracted[@"email"], @"Attribute values should match.");
    
}


- (void) testLogin
{
    
    StartBlock();
    
    [self.client authenticateWithUserEmail:SLLoginEmail
                              withPassword:SLLoginPassword
                          withOrganization:SLLoginOrganization]
    .then(^(SLClient *client, SLUser *me) {
        NSLog(@"Me User: %@", me);
        XCTAssertTrue(me != nil, @"PARTY. IT WORKED.");
        XCTAssert([me.email isEqualToString:SLLoginEmail], @"Email of user should be the same as the one used for logging in.");
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
    NSTimeInterval ti = [[NSDate new] timeIntervalSince1970]/1000;
    NSNumber *tin = [NSNumber numberWithDouble:ti];
    
    NSDictionary *payload =  @{
                               @"_id": @{
                                       @"$oid": @"538770ab2fb05c514e6cb340"
                                       },
                               @"date_created": @{@"$date": tin},
                               @"date_updated": @{@"$date": tin},
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

- (void) testPushAsset
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

- (void) testFindAllAssets
{
    
    StartBlock();
    
    [self.client authenticateWithUserEmail:SLLoginEmail
                              withPassword:SLLoginPassword
                          withOrganization:SLLoginOrganization]
    .then(^(SLClient *client, SLUser *me) {
        
        [SLAsset findAll]
        .then(^(NSArray *assets) {
            NSLog(@"Assets: %@", assets);
            EndBlock();
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
        
    })
    .catch(^(NSError *error) {
        EndBlock();
        XCTFail(@"%@", error);
    });
    
    WaitUntilBlockCompletes();
    
}


- (void) testFindAllAttributes
{
    
    StartBlock();
    
    [self.client authenticateWithUserEmail:SLLoginEmail
                              withPassword:SLLoginPassword
                          withOrganization:SLLoginOrganization]
    .then(^(SLClient *client, SLUser *me) {
        
        [SLAttribute findAll]
        .then(^(NSArray *attributes) {
            NSLog(@"Attributes: %@", attributes);
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
        
    })
    .catch(^(NSError *error) {
        XCTFail(@"%@", error);
        EndBlock();
    });
    
    WaitUntilBlockCompletes();
    
}


- (void) testFindAllAttributeCollections
{
    
    StartBlock();
    
    [self.client authenticateWithUserEmail:SLLoginEmail
                              withPassword:SLLoginPassword
                          withOrganization:SLLoginOrganization]
    .then(^(SLClient *client, SLUser *me) {
        
        [SLAttributeCollection findAll]
        .then(^(NSArray *attributeCollections) {
            NSLog(@"attributeCollections: %@", attributeCollections);
            
            //StartBlock();
            
            [SLAttributeCollection findAll]
            .then(^(NSArray *attributeCollections2)
                  {
                      NSLog(@"attributeCollections2: %@", attributeCollections2);
                      
                      for (SLAttributeCollection *attributeCollection in attributeCollections)
                      {
                          NSLog(@"Attributes: %@", attributeCollection.attributes);
                      }
                      
                      for (SLAttributeCollection *attributeCollection in attributeCollections2)
                      {
                          NSLog(@"Attributes2: %@", attributeCollection.attributes);
                      }
                      EndBlock();
                      
                  })
            .catch(^(NSError *error)
                   {
                       NSLog(@"%@", error);
                       EndBlock();
                   })
            .finally(^()
                     {
                         NSLog(@"Finally!");
                         EndBlock();
                     });
            
        })
        .catch(^(NSError *error) {
            NSLog(@"%@", error);
            EndBlock();
            
            XCTFail(@"%@", error);
        })
        .finally(^() {
            NSLog(@"Finally!");
            //EndBlock();
        });
        
    })
    .catch(^(NSError *error) {
        XCTFail(@"%@", error);
        EndBlock();
    });
    
    WaitUntilBlockCompletes();
    
}


- (void) testPushAssetWithRelationships
{
    
    NSDictionary *payload = @{
                              @"_id": [SLObjectIdTransform serialize:@"538770ab2fb05c514e6cb340"],
                              @"attributes": @[
                                      [SLObjectIdTransform serialize:@"abc"],
                                      [SLObjectIdTransform serialize:@"def"]
                                      ]
                              };
    
    SLSerializer *serializer = [[SLSerializer alloc] init];
    NSDictionary *pushData = [serializer extractSingle:[SLAsset class] withPayload:payload withStore:[SLStore sharedStore]];
    //    NSLog(@"pushData: %@", pushData);
    SLAsset *a1 = (SLAsset *)[[SLStore sharedStore] push:[SLAsset class] withData:pushData];
    //    NSLog(@"a1: %@", a1);
    XCTAssertStringEqual(pushData[@"nid"], a1.nid, @"`nid`s should match.");
    SLAttribute *attr = [SLAttribute initWithId:@"abc"];
    NSLog(@"Attr: %@", attr);
    NSSet *attrs = a1.attributes;
    NSLog(@"Attrs: %@", attrs);
    XCTAssert([attrs containsObject:attr], @"Asset's `attributes` relationship should contain this attribute.");
}

- (void) testFindMany
{
    StartBlock();
    
    [self.client authenticateWithUserEmail:SLLoginEmail
                              withPassword:SLLoginPassword
                          withOrganization:SLLoginOrganization]
    .then(^(SLClient *client, SLUser *me) {
        
        NSLog(@"Me: %@", me);
        
        NSArray *ids = @[
//                         @"53a72de02fb05c0788545ea9",
//                         @"53a72de02fb05c0788545ead"
                         @"53a72ddf2fb05c0788545e8c",
                         @"53a72de32fb05c0788545f51",
                         @"53a72de22fb05c0788545f2e"
                         ];
        [SLAttribute findMany:ids]
        .then(^(NSArray *attributes) {
            EndBlock();
            NSLog(@"Attributes: %@", attributes);
            
        })
        .catch(^(NSError *error) {
            EndBlock();
            NSLog(@"Error: %@", error);
            XCTFail(@"%@", error);
        });
        
    })
    .catch(^(NSError *error) {
        EndBlock();
        XCTFail(@"%@", error);
    });
    
    WaitUntilBlockCompletes();
    
}


- (void) testFindQuery
{
    StartBlock();
    
    [self.client authenticateWithUserEmail:SLLoginEmail
                              withPassword:SLLoginPassword
                          withOrganization:SLLoginOrganization]
    .then(^(SLClient *client, SLUser *me) {
        
        NSLog(@"Me: %@", me);
        
        NSDictionary *query = @{@"criteria":
                                    @{
                                        @"name": @"LI6312B"
                                        }
                                };
        [SLAttribute findQuery:query]
        .then(^(NSArray *attributes) {
            EndBlock();
            NSLog(@"Attributes: %@", attributes);
            
        })
        .catch(^(NSError *error) {
            EndBlock();
            NSLog(@"Error: %@", error);
            XCTFail(@"%@", error);
        });
        
    })
    .catch(^(NSError *error) {
        EndBlock();
        XCTFail(@"%@", error);
    });
    
    WaitUntilBlockCompletes();
    
}


@end
