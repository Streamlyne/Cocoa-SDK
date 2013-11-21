//
//  SLRelationship.h
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid and Glavin Wiechert on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLObject.h"
#import "SLNode.h"

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
- (id) initWithName:(NSString *)theName withStartNode:(SLNode *)startNode withEndNode:(SLNode *)endNode;

- (SLRelationshipDirection) directionWithNode:(SLNode *)theNode;

@end

