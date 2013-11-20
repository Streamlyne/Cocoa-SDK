//
//  SLNode.h
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid and Glavin Wiechert on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    INCOMING,
    OUTGOING
} Direction;

typedef unsigned long int SLNid;

// Circular dependencies
@class SLNode;
@class SLValue;
@class SLRelationship;
