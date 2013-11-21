//
//  SLRelationship.m
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLRelationship.h"


@implementation SLRelationship

- (id) initWithName:(NSString *)theName withStartNode:(SLNode *)startNode withEndNode:(SLNode *)endNode;
{
    self = [super init];
    if (self) {
        // Initialize variables
        self->name = theName;
        self->startNodeNid = startNode->nid;
        self->endNodeNid = endNode->nid;
    }
    return self;
}

- (SLRelationshipDirection) directionWithNode:(SLNode *)theNode
{
    if (self->endNodeNid == theNode->nid)
    {
        return SLRelationshipIncoming;
    } else if (self->startNodeNid == theNode->nid)
    {
        return SLRelationshipOutgoing;
    } else
    {
        return false;
    }
}

@end
