//
//  Streamlyne_iOS_SDKTests.m
//  Streamlyne-iOS-SDKTests
//
//  Created by Glavin Wiechert on 11/15/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SLSDK.h"

@interface Streamlyne_iOS_SDKTests : XCTestCase

@end

@implementation Streamlyne_iOS_SDKTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    SLAPIManager *manager = [SLAPIManager sharedManager];
    //[manager setBaseURL:[NSURL URLWithString:@"http://54.208.98.191:5000/api/"]];
    [manager setBaseURL:[NSURL URLWithString:@"http://localhost:5000/api/"]];
    // [[SLAPIManager sharedManager] authenticateWithUserEmail:@"Glavin" withPassword:@"test"];
    
    [manager setEmail:@"testing@streamlyne.co"];
    [manager setToken:@"sl-dev"];


}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    //XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    __block int pendingCallbacks = 0;
    
    void (^completionBlock)(BOOL) = ^(BOOL success){
        NSLog(@"Completion Block!");
        pendingCallbacks--; // Decrement
    };
    
    
    //[manager performRequestWithMethod:SLHTTPMethodGET withPath:@"user/" withParameters:nil withCallback:completionBlock];
    
    /*
    [SLUser readAllWithCallback:^(SLNodeArray *nodes){
        completionBlock(true);
    }];
    */
    
    SLUser *user1 = [SLUser createWithData:@{@"email":@"glavin.wiechert@gmail.com", @"password":@"test"} withRels:nil];
    NSLog(@"%@", user1);
    
    // Repeatedly process events in the run loop until we see the callback run.
    
    // This code will wait for up to 10 seconds for something to come through
    // on the main queue before it times out. If your tests need longer than
    // that, bump up the time limit. Giving it a timeout like this means your
    // tests won't hang indefinitely.
    
    // -[NSRunLoop runMode:beforeDate:] always processes exactly one event or
    // returns after timing out.
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:10];
    while ( (pendingCallbacks > 0) && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    if (pendingCallbacks > 0)
    {
        //STFail(@"I know this will fail, thanks");
    }
    
}

- (void) testOrganization
{
    
    __block int pendingCallbacks = 0;
    
    void (^completionBlock)(BOOL) = ^(BOOL success){
        NSLog(@"Completion Block: '%d'", pendingCallbacks);
        pendingCallbacks = pendingCallbacks - 1; // Decrement
    };
    
    SLRequestCallback requestCompletionBlock = ^(NSError *error, id operation, id responseObject) {
        NSLog(@"SLRequestCallback completionBlock!");
        NSLog(@"<%@>: %@", [responseObject class], responseObject);
        completionBlock(true);
    };
    
    /*
    // Create
    pendingCallbacks++;
    [[SLAPIManager sharedManager] performRequestWithMethod:SLHTTPMethodPOST withPath:@"organization" withParameters:@{@"data":@{@"name":[NSString stringWithFormat:@"test-organization-%@",[NSDate date]]}} withCallback:requestCompletionBlock];
    */
    
    // Create
    pendingCallbacks++;
    SLOrganization *org1 = [SLOrganization createWithData:@{@"name": [NSString stringWithFormat:@"test-organization-%@",[NSDate date]] } withRels:nil];
    [org1 saveWithCallback:completionBlock];
    
    // Read All
    pendingCallbacks++;
    [SLOrganization readAllWithCallback:^(SLNodeArray *nodes) {
        NSLog(@"Organizations: %@", nodes);
        
        completionBlock(true);
    }];
    
    /*
    // Read with Id
    pendingCallbacks++;
    [SLOrganization readById:1 withCallback:^(id node) {
        SLOrganization *org1 = (SLOrganization *)node;
        NSLog(@"Organization: %@", org1);

        completionBlock(true);
    }];
    
    // Delete
    pendingCallbacks++;
    [SLOrganization deleteWithId:1 withCallback:completionBlock];
    */
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:10];
    while ( (pendingCallbacks > 0) && [loopUntil timeIntervalSinceNow] > 0) {
        //NSLog(@"%d", pendingCallbacks);
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    if (pendingCallbacks > 0)
    {
        NSLog(@"Pending Callbacks: %d", pendingCallbacks);
        //STFail(@"I know this will fail, thanks");
    }
    
}

- (void) testUser
{
    
    __block int pendingCallbacks = 0;
    
    SLSuccessCallback completionBlock = ^(BOOL success){
        NSLog(@"Completion Block: '%d'", pendingCallbacks);
        pendingCallbacks = pendingCallbacks - 1; // Decrement
    };
    
    
    // SLValue *val = [[SLValue alloc] initWithType:[NSString class] withValue:@"Glavin" withPredicates:@[]];

    //NSLog(@"Creating SLUser Node");
    int r = arc4random() % 100;
    NSDictionary *data = @{
        @"email": [NSString stringWithFormat:@"test-%u@streamlyne.co", r],
        @"password": @"test",
        @"job_title": @"developer",
        @"name_first": @"Testy",
        @"name_last": @"Tester"
        };
    
    SLUser *user1 = [SLUser createWithData:data withRels:(SLRelationshipArray *)@[]];
    pendingCallbacks++;
    [SLOrganization readAllWithCallback:^(SLNodeArray *orgs) {
        SLOrganization *org1 = (SLOrganization *) orgs[0];
        NSLog(@"%lu number of Organizations", (unsigned long)[orgs count]);

        //NSLog(@"Organization: %@", org1);
        /*
        SLRelationship *rel = [[SLRelationship alloc] initWithName:@"member" withStartNode:user1 withEndNode:org1];
        //[user1 addRelationship:rel];
        //NSLog(@"User: %@", user1);
        NSLog(@"Dir User: %u", [rel directionWithNode:user1]);
        NSLog(@"Dir Org: %u", [rel directionWithNode:org1]);
        pendingCallbacks++;
        [user1 saveWithCallback:completionBlock];
        */
        
        pendingCallbacks++;
        [SLUser registerUser:user1 withOrganization:org1 withCallback:^(BOOL success) {
            
            // Authenticate / Login
            pendingCallbacks++;
            [[SLAPIManager sharedManager] authenticateWithUser:user1 withCallback:completionBlock];
            
            // Read All
            pendingCallbacks++;
            [SLUser readAllWithCallback:^(SLNodeArray *users){
                //NSLog(@"Users: %@", users);
                NSLog(@"%lu number of Users", (unsigned long)[users count]);
                completionBlock(true);
            }];
            
            /*
            // Update
            pendingCallbacks++;
            [user1 saveWithCallback:completionBlock];
            */
            
            completionBlock(true);
        }];
        
        completionBlock(true);
    }];
    
    // Authenticate
    /*
     pendingCallbacks++;
    [[SLAPIManager sharedManager] performRequestWithMethod:SLHTTPMethodPOST withPath:@"authenticate" withParameters:@{@"email":@"test-46@gmail.com", @"password":@"test"} withCallback:^(NSError *error, id operation, id responseObject) {
            NSLog(@"Authentication completionBlock!");
            NSLog(@"<%@>: %@", [responseObject class], responseObject);
            completionBlock(true);
    }];
     */
    
    
    //NSLog(@"%@", [user type]);
    //[SLNode deleteWithNode:user];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:10];
    while ( (pendingCallbacks > 0) && [loopUntil timeIntervalSinceNow] > 0) {
        //NSLog(@"%d", pendingCallbacks);
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    if (pendingCallbacks > 0)
    {
        NSLog(@"Pending Callbacks: %d", pendingCallbacks);
        //STFail(@"I know this will fail, thanks");
    }
    
    
}

- (void) testRelationship
{
    /*
    //NSLog(@"Creating Value");
    SLValue *val = [[SLValue alloc] initWithType:[NSString class] withValue:@"totally" withPredicates:@[]];
    
    
    //NSLog(@"Creating Node");
    SLNode *node1 = [SLNode createWithData:@{@"test":val} withRels:(SLRelationshipArray *)@[@"123"]];
    //NSLog(@"%@", node1);
    SLNode *node2 = [SLNode createWithData:@{@"test":val} withRels:(SLRelationshipArray *)@[@"123"]];
    
    //NSLog(@"Creating Relationship");
    SLRelationship *rel1 = [[SLRelationship alloc] initWithName:@"creator" withStartNode:node1 withEndNode:node2];
    SLRelationshipDirection dir = [rel1 directionWithNode:node1];
    if (dir == SLRelationshipIncoming) {
        NSLog(@"Incoming!");
    } else if (dir == SLRelationshipIncoming) {
        NSLog(@"Outgoing!");
    }

    [node1 addRelationship:rel1];
    [((SLRelationship *)(node1.relationships[0])) directionWithNode:node1];
    */
}


- (void) testGroup
{
    
    __block int pendingCallbacks = 0;
    //
    SLSuccessCallback completionBlock = ^(BOOL success){
        NSLog(@"Completion Block: '%d'", pendingCallbacks);
        pendingCallbacks = pendingCallbacks - 1; // Decrement
    };
    
    
    // Read All Group
    NSLog(@"Read All Group");
    pendingCallbacks++;
    [SLGroup readAllWithCallback:^(SLNodeArray * nodes){
        NSLog(@"# of Group: %lu", (unsigned long)[nodes count]);
        for (NSUInteger i = 0, len = [nodes count]; i < len; i++)
        {
            SLGroup *group = (SLGroup *) nodes[i];
            NSLog(@"Group: %@", group);
        }
        completionBlock(true);
    }];
    
    // Create
    pendingCallbacks++;
    SLGroup *group = [SLGroup createWithData:@{
                                                           @"name": @"Sample Group",
                                                           @"description": @"This is a sample group"
                                                           } withRels:(SLRelationshipArray *)@[]];
    [group saveWithCallback:completionBlock];
    
    //
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:10];
    while ( (pendingCallbacks > 0) && [loopUntil timeIntervalSinceNow] > 0)
    {
        //NSLog(@"%d", pendingCallbacks);
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    if (pendingCallbacks > 0)
    {
        NSLog(@"Pending Callbacks: %d", pendingCallbacks);
        //STFail(@"I know this will fail, thanks");
    }
    
}



- (void) testAsset
{
    
    __block int pendingCallbacks = 0;
    //
    SLSuccessCallback completionBlock = ^(BOOL success){
        NSLog(@"Completion Block: '%d'", pendingCallbacks);
        pendingCallbacks = pendingCallbacks - 1; // Decrement
    };
    
    
    // Read All Work Orders
    NSLog(@"Read All Assets");
    pendingCallbacks++;
    [SLAsset readAllWithCallback:^(SLNodeArray * nodes){
        NSLog(@"# of Asset: %lu", (unsigned long)[nodes count]);
        for (NSUInteger i = 0, len = [nodes count]; i < len; i++)
        {
            SLAsset *asset = (SLAsset *) nodes[i];
            NSLog(@"Asset: %@", asset);
        }
        completionBlock(true);
    }];
    
    // Create
    pendingCallbacks++;
    [SLUser readAllWithCallback:^(SLNodeArray *nodes) {
        SLUser *user1 = nodes[0];
        
        NSDictionary *newAssetData = @{
                                           @"number_asset": @"ACSEM6001",
                                           @"number_serial": @"96-900-8414-1"
                                           ,@"description": @"ANALYZER, M609 Sulphur Stack"
                                           ,@"mfg": @"BOVAR"
                                           ,@"location": @"NEV600"
                                           ,@"cost_center": @"210PNV0064"
                                           };
        SLAsset *asset = [SLAsset createWithData:newAssetData withRels:(SLRelationshipArray *)@[]];
        
        SLRelationship *rel = [[SLRelationship alloc] initWithName:@"created" withStartNode:user1 withEndNode:asset];
        
        pendingCallbacks++;
        [asset saveWithCallback:completionBlock];
        
        /*
         pendingCallbacks++;
         [SLOrganization readAllWithCallback:^(SLNodeArray * nodes) {
         SLOrganization *org1 = (SLOrganization *) nodes[0];
         SLRelationship *rel2 = [[SLRelationship alloc] initWithName:@"member" withStartNode:user1 withEndNode:org1];
         
         pendingCallbacks++;
         [user1 saveWithCallback:completionBlock];
         
         completionBlock(true);
         }];
         */
        
        completionBlock(true);
    }];
    
    //
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:10];
    while ( (pendingCallbacks > 0) && [loopUntil timeIntervalSinceNow] > 0) {
        //NSLog(@"%d", pendingCallbacks);
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    if (pendingCallbacks > 0)
    {
        NSLog(@"Pending Callbacks: %d", pendingCallbacks);
        //STFail(@"I know this will fail, thanks");
    }
    
}


- (void) testWorkOrder
{
    
    __block int pendingCallbacks = 0;
    //
    SLSuccessCallback completionBlock = ^(BOOL success){
        NSLog(@"Completion Block: '%d'", pendingCallbacks);
        pendingCallbacks = pendingCallbacks - 1; // Decrement
    };
    
    
    // Read All Work Orders
    NSLog(@"Read All Work Orders");
    pendingCallbacks++;
    [SLWorkOrder readAllWithCallback:^(SLNodeArray * nodes){
        NSLog(@"# of Work Orders: %lu", (unsigned long)[nodes count]);
        for (NSUInteger i = 0, len = [nodes count]; i < len; i++)
        {
            SLWorkOrder *workOrder = (SLWorkOrder *) nodes[i];
            NSLog(@"Work Order: %@", workOrder);
        }
        completionBlock(true);
    }];
    
    // Create
    pendingCallbacks++;
    [SLUser readAllWithCallback:^(SLNodeArray *nodes) {
        SLUser *user1 = nodes[0];
        
        NSDictionary *newWorkOrderData = @{
                                           @"name": @"Sample Work Order",
                                           @"description": @"This is a sample work order!"
                                           ,@"status": @"some status"
                                           ,@"notes_completion": @"After I created it made this note."
                                           //,@"date_due": [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterFullStyle]
                                           //,@"date_completed": [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterFullStyle]
                                           };
        SLWorkOrder *workOrder = [SLWorkOrder createWithData:newWorkOrderData withRels:(SLRelationshipArray *)@[]];

        SLRelationship *rel = [[SLRelationship alloc] initWithName:@"created" withStartNode:user1 withEndNode:workOrder];
        
        pendingCallbacks++;
        [workOrder saveWithCallback:completionBlock];
        
        /*
        pendingCallbacks++;
        [SLOrganization readAllWithCallback:^(SLNodeArray * nodes) {
            SLOrganization *org1 = (SLOrganization *) nodes[0];
            SLRelationship *rel2 = [[SLRelationship alloc] initWithName:@"member" withStartNode:user1 withEndNode:org1];
            
            pendingCallbacks++;
            [user1 saveWithCallback:completionBlock];
            
            completionBlock(true);
        }];
         */
        
        completionBlock(true);
    }];
     
    //
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:10];
    while ( (pendingCallbacks > 0) && [loopUntil timeIntervalSinceNow] > 0) {
        //NSLog(@"%d", pendingCallbacks);
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    if (pendingCallbacks > 0)
    {
        NSLog(@"Pending Callbacks: %d", pendingCallbacks);
        //STFail(@"I know this will fail, thanks");
    }
    
}


@end
