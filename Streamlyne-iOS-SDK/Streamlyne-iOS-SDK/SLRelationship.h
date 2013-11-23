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
@public
    NSString *name;
    
    /**
     A dictionary of {SLValue}s
     */
@private
    NSDictionary *data;
    
@public
    id<SLNodeProtocol> startNode;
    
@public
    id<SLNodeProtocol> endNode;
    
@protected
    Boolean *isSaved;

@protected
    Boolean *required;
    
}

//@property (setter = setName) NSString *name;

/**
 The direction
 */
- (id) initWithName:(NSString *)theName withStartNode:(id)startNode withEndNode:(id)endNode;

- (SLRelationshipDirection) directionWithNode:(id)theNode;

@end

