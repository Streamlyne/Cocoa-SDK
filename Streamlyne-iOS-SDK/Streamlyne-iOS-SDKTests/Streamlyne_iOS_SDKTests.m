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
    [[SLAPIManager sharedManager] authenticateWithUserEmail:@"Glavin" withPassword:@"test"];

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
