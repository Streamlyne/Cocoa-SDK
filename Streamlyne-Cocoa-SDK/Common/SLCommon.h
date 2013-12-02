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
    SLRelationshipNotFound,
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
// typedef unsigned long int SLNid;
typedef NSNumber *SLNid;
#define SLNidNodeNotCreated nil

typedef NSMutableArray SLRelationshipArray;
typedef NSMutableArray SLNodeArray;

/**
 Typedef for Successful Callback
 */
typedef void(^SLSuccessCallback)(BOOL successful);

/**
 Typedef for Request Callback
 */
typedef void(^SLRequestCallback)(NSError *error, id operation, id responseObject);

/**
 
 */
#define SLExceptionImplementationNotFound [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not yet implemented." userInfo:nil]

/**
 
 */
#define SLFiltersAllFalse @{ \
                          @"filter":@{ \
                                  @"fields": [NSNumber numberWithBool: FALSE], \
                                  @"rels": [NSNumber numberWithBool: FALSE] \
                                  } \
                          }
/**
 
 */
#define SLFiltersAllTrue @{ \
    @"filter":@{ \
        @"fields": [NSNumber numberWithBool: TRUE], \
        @"rels": [NSNumber numberWithBool: TRUE] \
    } \
}


/**
 Source: http://stackoverflow.com/a/12137979/2578205
 */
#define NSNullIfNil(v) (v ? v : [NSNull null])

/**
 // Circular dependencies
 */
@class SLAPIManager;
@class SLNode;
@class SLValue;
@class SLRelationship;
@class SLRelationshipArray;
@class SLNodeArray;

#endif
