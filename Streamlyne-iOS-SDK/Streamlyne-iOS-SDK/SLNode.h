//
//  SLNode.h
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid and Glavin Wiechert on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLObject.h"

/** --------------------------------------------------------------------------------
 */
@interface SLNode : SLObject {
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
    SLRelationshipArray *rels;
    
@public
    SLNid nid;
}


/**
 Boolean stating whether the SLNode has been persisted since the previous most
 call to update.
 */
@property (getter=isSaved, readonly) BOOL saved;

/**
 Returns the node with id corresponding to {nid}.
 */
+ (void) readById:(SLNid)nid withCallback:(void (^)(SLNode *))callback;


/**
 Returns all nodes of the type subclassed by SLNode.
 */
+ (void) readAllWithCallback:(void (^)(SLNodeArray *))callback;


/**
 Creates a node client side (not persisted). This node needs to be
 be saved to be persisted in any manner.
 */
+ (instancetype) createWithData:(NSDictionary *)data withRels:(SLRelationshipArray *)rels;


/**
 Creates a node client side (not persisted). This node needs to be
 be saved to be persisted in any manner.
 */
+ (instancetype) createWithData:(NSDictionary *)data;


/**
 Creates a node client side (not persisted). This node needs to be
 be saved to be persisted in any manner.
 */
+ (instancetype) createWithRels:(SLRelationshipArray *)rels;

/**
 Creates a node client side (not persisted). This node needs to be
 be saved to be persisted in any manner.
 */
+ (instancetype) create;


/**
 Deletes the node with the corresponding {nid}.
 */
+ (void) deleteWithId:(SLNid)nid;

/**
 Deletes the node with the corresponding {nid}, with callback.
 */
+ (void) deleteWithId:(SLNid)nid withCallback:(SLSuccessCallback)callback;


/**
 Deletes {node}. This is done by calling {deleteWithId} with the id of {node}.
 */
+ (void) deleteWithNode:(SLNode *)node;

/**
 Deletes {node}. This is done by calling {deleteWithId} with the id of {node}.
 */
+ (void) deleteWithNode:(SLNode *)node withCallback:(SLSuccessCallback)callback;


/**
 Deletes a set of nodes, {nodes}. This is done by applying the function
 {deleteWithId} to all nodes contained in the set {nodes} using their node
 id's.
 */
+ (void) deleteWithNodeArray:(SLNodeArray *)nodes;

/**
 Deletes a set of nodes, {nodes}. This is done by applying the function
 {deleteWithId} to all nodes contained in the set {nodes} using their node
 id's.
 */
+ (void) deleteWithNodeArray:(SLNodeArray *)nodes withCallback:(SLSuccessCallback)callback;

/**
 Deletes a set of nodes, {nodes}. This is done by applying the function
 {deleteWithId} to all nodes contained in the set {nodes} using their node
 id's.
 */
+ (void) deleteWithNodeArray:(SLNodeArray *)nodes withProgressCallback:(void (^)(NSUInteger idx))progress withCallback:(SLSuccessCallback)callback;


/**
 Return the {type} of this node.
 */
- (NSString *) type;

/**
 Returns the {rels}, relationships, of this node.
 */
- (SLRelationshipArray *) relationships;

/**
 Pushes a relationship into {rels}, verify if start or end node is this node.
 */
- (BOOL) addRelationship:(SLRelationship *)theRel;


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
- (void) save;

/**
 Persists the node to the database, with callback on completion.
 
 This done by iterating through {data} and compiling a list of node SLValues
 that haven't been saved. From the set of unsaved properties a update request to
 SLAPI may be formulated.
 */
- (void) saveWithCallback:(void (^)(BOOL successful))callback;


/**
 Returns the value of the internal boolean {isSaved}.
 */
- (BOOL) isSaved;


/**
 Iterates through the keys contained in the internal {data} dictionary and checks
 each value, being a SLValue object, if it has been updated. If any value has not been
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


/**
 Delete's this instance from the database, with callback on completion.
 */
- (void) removeWithCallback:(SLSuccessCallback)callback;


@end
