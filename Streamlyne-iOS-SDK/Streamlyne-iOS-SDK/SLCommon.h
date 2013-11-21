//
//  SLCommon.h
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/21/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#ifndef Streamlyne_iOS_SDK_SLCommon_h
#define Streamlyne_iOS_SDK_SLCommon_h

/**
 
 */
typedef NS_ENUM(NSUInteger, SLRelationshipDirection)
{
    SLRelationshipIncoming,
    SLRelationshipOutgoing
};

/*
 typedef enum {
 INCOMING,
 OUTGOING
 } Direction;
 */

/**
 
 */
typedef unsigned long int SLNid;

typedef NSMutableArray SLRelationshipArray;
typedef NSMutableArray SLNodeArray;

/**
 Typedef for Successful Callback
 */
typedef void(^SLSuccessCallback)(BOOL successful);

/**
 
 */
#define SLExceptionImplementationNotFound [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not yet implemented." userInfo:nil]

/**
 // Circular dependencies
 */
@class SLNode;
@class SLValue;
@class SLRelationship;
@class SLRelationshipArray;
@class SLNodeArray;

#endif
