//
//  SLNode.h
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import <Foundation/Foundation.h>


/** --------------------------------------------------------------------------------
 */
@interface SLValue : NSObject {
    
    /**
     Stores the type of the encapsulated value.
     ex ) NSString, int, Boolean
     */
@private
    id type;
    
    /**
     Stores the current value of the SLValue. The value should be
     type unspecific.
     */
@private
    id value;
    
    /**
     */
@private
    id savedValue;
    
    /**
     A list of unary functions that values must "pass" to set.
     */
@private
    NSArray *predicates;
    
    /**
     Tracks wether {setSaved} has been called since the last
     successful call of {set}.
     */
@private
    Boolean *saved;
}

/**
 Sets the value of this {SLValue}.
 
 Given the value runtime check that {theValue} is of type
 {type}. If this is true iterate through all stored predicates
 passing {theValue} as the arguement.
 
 If all predicates return true, set {value} equal to {theValue}
 and set {saved} equal to false.
 */
- (Boolean *) set:(id) theValue;

/**
 Returns the current {value}.
 */
- (id) get;

/**
 Returns the value of saved.
 */
- (Boolean *) isSaved;

/**
 Set saved equal to true. This does not garuantee that the value
 has been persisted.
 */
- (void) setSaved;

/**
 Adds {predicate} to {predicates}. {predicate} should be an
 ObjC block.
 */
- (void) addPredicate: (id) predicate;

@end


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
    
    /**
     Boolean stating whether the SLNode has been persisted since the previous most 
     call to update.
     */
    @protected
    Boolean *isSaved;
}


/**
 Returns the node with id corresponding to {nid}.
 */
+ (SLNode *) readById:(int)nid;


/**
 Returns all nodes of the type subclassed by SLNode.
 */
+ (SLNode *) readAll;


/**
 Creates a ndoe client side (not persisted). This node needs to be 
 be saved to be persisted in any manner.
 */
+ (SLNode *) createWithData:(NSDictionary *)data withRels:(NSArray *)rels;


/**
 Deletes the node with the corresponding {nid}.
 */
+ (void) deleteById:(int)nid;


/**
 Deletes {node}. This is done by calling {deleteById} with the id of {node}.
 */
+ (void) deleteNode:(SLNode *)node;


/**
 Deletes a set of nodes, {nodes}. This is done by applying the function 
 {deleteById} to all nodes contained in the set {nodes} using their node
 id's.
 */
+ (void) deleteNodeSet:(NSArray *)nodes;


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
- (Boolean *) save;


/**
 Returns the value of the internal boolean {isSaved}.
 */
- (Boolean *) isSaved;


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
    
    @protected
    SLNode *node;
    
    @protected
    Boolean *isSaved;
}



@end
