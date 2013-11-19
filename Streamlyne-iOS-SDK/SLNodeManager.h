//
//  SLNodeManager.h
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLNode.h"

/**
 The Streamlyne Node Manager class is used to produce and manage nodes.
 All nodes need to be persisted to the database and the SLNodeManager acts
 as a single location where all nodes may be persisted.
 
 */
@interface SLNodeManager : NSObject {
 
    /**
     A list of all nodes produced by this SLNodeManager.
     */
    @private
    NSArray *nodes;
    
    /**
     All unsaved nodes contained in the "nodes" array.
     */
    @private
    NSArray *unsavedNodes;
}


+ (id) shared;


/**
 Produces a generic node instance extracted from DB. {id} corresponds
 to the id's used by the bulbflow framework.
 */
- (SLNode *) produceNode: (int) id;


/**
 */
- (NSArray *) getUnsavedNodes;


/**
 True if there are any unsaved nodes. True if {unsavedNodes} has a size 
 greatere than 0.
 */
- (Boolean *) hasUnsavedNodes;


@end
