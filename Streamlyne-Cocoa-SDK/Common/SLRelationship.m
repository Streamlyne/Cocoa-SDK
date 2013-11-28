//
//  SLRelationship.m
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLRelationship.h"

@interface SLRelationship () {
    
}
/**
 Tracks wether `setSaved` has been called since the last
 successful call of `set`.
 */
@property (nonatomic) BOOL saved;
/**
 A dictionary of {SLValue}s
 */
@property (strong, nonatomic) NSDictionary *data;

@end


@implementation SLRelationship
@synthesize name, startNode, endNode, required, data, saved;

- (id) initWithName:(NSString *)theName withStartNode:(id)startNode withEndNode:(id)endNode;
{
    self = [super init];
    if (self) {
        // Initialize variables
        self.saved = NO;
        self.name = theName;
        self.startNode = startNode;
        self.endNode = endNode;
        // Add relation to these nodes
        [startNode addRelationship:self];
        [endNode addRelationship:self];
    }
    return self;
}


- (NSString *) description
{
    return [NSString stringWithFormat:@"<%@ %p: { name = %@, startNode = <%@: %p>, endNode = <%@: %p> }>", [self class], self, self.name, [self.startNode class], self.startNode, [self.endNode class], self.endNode];

    /*
    return [NSString stringWithFormat:@"<%@ %p: %@>", [self class], self,
            [NSDictionary dictionaryWithObjectsAndKeys:
             NSNullIfNil(self.name), @"name",
             (self.startNode.nid||[NSNull null]), @"startNode",
             (self.endNode.nid||[NSNull null]), @"endNode",
             nil
             ] ];
    */
    
    //return [NSString stringWithFormat:@"<%@: { type: \"%@\", data: %@, relationships: %@ } >", [self class], [self type], [self.data description], [self.rels description]];
}

- (SLRelationshipDirection) directionWithNode:(id)theNode
{
    //NSLog(@"Node: %@, start: %@, end:%@", theNode, self.startNode, self.endNode);
    
    if (self.endNode == theNode)
    {
        NSLog(@"SLRelationshipIncoming");
        return SLRelationshipIncoming;
    } else if (self.startNode == theNode)
    {
        NSLog(@"SLRelationshipOutgoing");
        return SLRelationshipOutgoing;
    } else
    {
        NSLog(@"SLRelationshipNotFound");
        return SLRelationshipNotFound;
    }
}

- (BOOL) isSaved
{
    return saved;
}

- (void) setSaved
{
    saved = YES;
}


@end
