//
//  SLNode.h
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid and Glavin Wiechert on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLSDK.h"

/** --------------------------------------------------------------------------------
 */
@interface SLNode : NSObject {
    /**
     SLNode is intended to be implemented and then subclassed.
     */
    
    /**
     The node type name
     
     This should be defined by the subclass implementation of SLNode.
     */
@protected
    NSString *element_type;
    
    /**
     String s -> SLValue s
     */
@protected
    NSDictionary *data;
    
    /**
     A list of relationships to this node.
     */
@protected
    NSArray *rels;
    
@public
    SLNid nid;
}


/**
 Boolean stating whether the SLNode has been persisted since the previous most
 call to update.
 */
@property (getter=isFinished, readonly)
BOOL *isSaved;


/**
 Returns the node with id corresponding to {nid}.
 */
+ (SLNode *) readById:(int)nid;


/**
 Returns all nodes of the type subclassed by SLNode.
 */
+ (NSArray *) readAll;


/**
 Creates a ndoe client side (not persisted). This node needs to be
 be saved to be persisted in any manner.
 */
+ (SLNode *) createWithData:(NSDictionary *)data withRels:(NSArray *)rels;


/**
 */
+ (SLNode *) createWithData:(NSDictionary *)data;


/**
 */
+ (SLNode *) createWithRels:(NSArray *)rels;


+ (SLNode *) create;


/**
 Deletes the node with the corresponding {nid}.
 */
+ (void) deleteWithId:(int)nid;


/**
 Deletes {node}. This is done by calling {deleteById} with the id of {node}.
 */
+ (void) deleteWithNode:(SLNode *)node;


/**
 Deletes a set of nodes, {nodes}. This is done by applying the function
 {deleteById} to all nodes contained in the set {nodes} using their node
 id's.
 */
+ (void) deleteWithNodeArray:(NSArray *)nodes;


/**
 Update a single attribute. Updating a node sets it's internal boolean,
 {isSaved}, false.
 */
- (void) update:(NSString *)attr value:(id)value;


/**
 Persists the node to the database.
 
 This done by iterating through {data} and compiling a list of node SLValues
 that haven't been saved. From the set of unsaved properties a update request to
 SLAPI may be formulated.
 */
- (BOOL) save;


/**
 Returns the value of the internal boolean {isSaved}.
 */
- (BOOL) isSaved;


/**
 Iterates through the keys contained in the internal {data} dictionary and checks
 each value, being a SLValue object, if it has been updated. If any value has been
 updated isSaved is set to false, otherwise it is true.
 
 This method is a safe guard to ensure that isSaved is being used properly internally.
 */
- (void) checkSaved;


/**
 Iterates through values, being an {SLValues}, contained in the internal
 {data} dictionary and calls the discardChange method if the SLValue has been
 updated.
 */
- (void) discardChanges;


/**
 If the value, being an {SLValue}, has changes made to it, it discards the
 changes.
 */
- (void) discardChangesTo:(NSString *)attr;

/**
 Delete's this instance from the database.
 */
- (void) remove;

@end
