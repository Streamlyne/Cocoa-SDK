//
//  SLNodeManager.h
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLNode.h"

typedef enum {
    User
} SLNodeType;

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


/**
 Returns an instance to the singleton SLNodeManager. This method instanstiates 
 the SLNodeManager if it has not already been instantiated.
 */
+ (id) shared;


/**
 Produces a generic node instance extracted from DB. {id} corresponds
 to the id's used by the bulbflow framework.
 */
- (SLNode *) create:(SLNodeType)type withData:(NSDictionary *)data withRels:(NSArray *)rels;


/**
 Reads the node corresponding to the bulbflow id, {id} and returns a node.
 */
- (SLNode *) read:(int)nid;


/**
 Returns a list of nodes contained within the database of the type, {type}.
 */
- (NSArray *) readAll:(SLNodeType)type;


/**
 Persists the given node to the database.
 */
- (SLNode *) update:(SLNode *) node;


/**
 Deletes the given node. This is done by calling {deleteWithId}.
 */
- (Boolean *) delete:(SLNode *) node;


/**
 Deletes the node corresponding to the bulbflow id
 */
- (Boolean *) deleteWithId:(int) node;


/**
 Returns a refference to unsavedNodes. This is to ensure all node updates 
 are persisted. 
 */
- (NSArray *) getUnsavedNodes;


/**
 True if there are any unsaved nodes. True if {unsavedNodes} has a size 
 greatere than 0.
 */
- (Boolean *) hasUnsavedNodes;


@end
