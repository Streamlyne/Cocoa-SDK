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
    // XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSLog(@"Creating Node");
    SLNode *node1 = [SLNode createWithData:@{@"test":@"ing"} withRels:(SLRelationshipArray *)@[@"123"]];
    NSLog(@"%@", node1);
    
    NSLog(@"Creating Relationship");
    
    
    
    NSLog(@"Deleting nodes");
    SLSuccessCallback completionCallback = ^(BOOL successful) {
        NSLog(@"Completed! %hhd", successful);
    };
    [node1 removeWithCallback:completionCallback];

}

@end
