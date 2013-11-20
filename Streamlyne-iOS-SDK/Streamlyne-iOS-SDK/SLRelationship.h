//
//  SLRelationship.h
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid and Glavin Wiechert on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLSDK.h"


/** --------------------------------------------------------------------------------
 */
@interface SLRelationship : NSObject {
    
    /**
     Name of the relationship type.
     */
@private
    NSString *name;
    
    /**
     A dictionary of {SLValue}s
     */
@private
    NSDictionary *data;
    
@public
    SLNid startNodeNid;
    
@public
    SLNid endNodeNid;
    
@protected
    Boolean *isSaved;
}

/**
 The direction
 */
- (id) initWithStartNode:(SLNode *)startNode withEndNode:(SLNode *)endNode;

- (Direction *) directionWithNode:(SLNode *)theNode;

@end

