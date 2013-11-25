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
    Boolean *required;
    
    /**
     Tracks wether `setSaved` has been called since the last
     successful call of `set`.
     */
@private
    BOOL saved;

    
}

//@property (setter = setName) NSString *name;

/**
 The direction
 */
- (id) initWithName:(NSString *)theName withStartNode:(id)startNode withEndNode:(id)endNode;

/**
 
 */
- (SLRelationshipDirection) directionWithNode:(id)theNode;


/**
 Returns the value of saved.
 */
- (BOOL) isSaved;


/**
 Set saved equal to true. This does not garuantee that the value
 has been persisted.
 */
- (void) setSaved;

@end

