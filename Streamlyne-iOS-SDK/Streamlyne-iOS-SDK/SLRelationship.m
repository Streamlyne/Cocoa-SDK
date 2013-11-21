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
        self->startNode = startNode;
        self->endNode = endNode;
    }
    return self;
}

- (SLRelationshipDirection) directionWithNode:(SLNode *)theNode
{
    if (self->endNode == theNode)
    {
        return SLRelationshipIncoming;
    } else if (self->startNode == theNode)
    {
        return SLRelationshipOutgoing;
    } else
    {
        return false;
    }
}

@end
