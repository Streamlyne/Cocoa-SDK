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
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    //XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    __block BOOL hasCalledBack = NO;
    
    void (^completionBlock)(BOOL) = ^(BOOL success){
        NSLog(@"Completion Block!");
        hasCalledBack = YES;
    };
    
    SLAPIManager *manager = [SLAPIManager sharedManager];
    //[manager setBaseURL:[NSURL URLWithString:@"http://54.208.98.191:5000/api/"]];
    [manager setBaseURL:[NSURL URLWithString:@"http://localhost:5000/api/"]];
    // [[SLAPIManager sharedManager] authenticateWithUserEmail:@"Glavin" withPassword:@"test"];
    
    [manager setEmail:@"testing@streamlyne.co"];
    [manager setToken:@"sl-dev"];
    
    //[manager performRequestWithMethod:SLHTTPMethodGET withPath:@"user/" withParameters:nil withCallback:completionBlock];
    
    [SLUser readAllWithCallback:^(SLNodeArray *nodes){
        completionBlock(true);
    }];
    
    // Repeatedly process events in the run loop until we see the callback run.
    
    // This code will wait for up to 10 seconds for something to come through
    // on the main queue before it times out. If your tests need longer than
    // that, bump up the time limit. Giving it a timeout like this means your
    // tests won't hang indefinitely.
    
    // -[NSRunLoop runMode:beforeDate:] always processes exactly one event or
    // returns after timing out.
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:10];
    while (hasCalledBack == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    if (!hasCalledBack)
    {
        // STFail(@"I know this will fail, thanks");
    }
    
}

- (void) testNode
{
    
    //NSLog(@"Creating Value");
    SLValue *val = [[SLValue alloc] initWithType:@"Awesome" withValue:@"totally" withPredicates:@[]];
    
    //NSLog(@"Creating Node");
    SLNode *node1 = [SLNode createWithData:@{@"test":val} withRels:(SLRelationshipArray *)@[@"123"]];
    //NSLog(@"%@", node1);
    
    /*
    NSLog(@"Deleting nodes");
    SLSuccessCallback completionCallback = ^(BOOL successful) {
        NSLog(@"Completed! %hhd", successful);
    };
    [node1 removeWithCallback:completionCallback];
    */
}

- (void) testCustomNodes
{
    SLValue *val = [[SLValue alloc] initWithType:@"Awesome" withValue:@"totally" withPredicates:@[]];

    //NSLog(@"Creating SLUser Node");
    SLUser *user = [SLUser createWithData:@{@"key":val} withRels:(SLRelationshipArray *)@[@"omg"]];
    //NSLog(@"%@", [user type]);
    [SLNode deleteWithNode:user];
    
}

- (void) testRelationship
{
    //NSLog(@"Creating Value");
    SLValue *val = [[SLValue alloc] initWithType:@"Awesome" withValue:@"totally" withPredicates:@[]];
    
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
    
}

@end
