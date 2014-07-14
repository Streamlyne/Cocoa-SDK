//
//  SLNode.h
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid and Glavin Wiechert on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLNodeProtocol.h"
#import "CoreData+MagicalRecord.h"
#import "SLObject.h"
#import "SLValue.h"

/**
 `SLNode` is intended to be implemented and then subclassed.
 
 ## Subclassing Notes
 `SLNode` is intended to be implemented and then subclassed.
 
 ### Methods to Override
 In a subclass, you must override all these methods.
 
 - `init`
 - `type`
 
 */
@interface SLNode : NSManagedObject <SLNodeProtocol> {
}
// Properties
/**
 String s -> SLValue s
 */
@property (strong, nonatomic) NSDictionary *data DEPRECATED_ATTRIBUTE;
/**
 A list of relationships to this node.
 
 @deprecated Use Core Data relationships now.
 */
@property (strong, nonatomic) NSMutableArray *rels DEPRECATED_ATTRIBUTE;
/**
 */
//@property (strong, nonatomic) SLNid nid;
@property (nonatomic, retain) SLNid nid;
@property (nonatomic, retain) NSNumber *syncState;
@property (nonatomic, retain) NSDate *dateCreated;
@property (nonatomic, retain) NSDate *dateUpdated;

/**
 Boolean stating whether the `SLNode` has been persisted since the previous most
 call to update.
 */
@property (getter=isSaved, readonly) BOOL saved;

/**
 Returns an object initialized.
 
 Use for initializing new nodes that do not have existing an `SLNid` nid.
 
 ## Manipulating the Schema
 Sample code to put in your init method.
 
    // Create a Mutable copy of the data
    NSMutableDictionary *tempData = [self.data mutableCopy];
    // Make changes, by adding `SLValue`s
    SLValue *idVal = [[SLValue alloc]initWithType:[NSString class]];
    [tempData setValue:idVal forKey:@"id"];
    // Change the base data schema to the new data schema.
    self.data = tempData;
 
 @deprecated Use `MR_createEntity`.
 */
- (instancetype) init DEPRECATED_ATTRIBUTE;
/**
 
 */
- (instancetype) initInContext:(NSManagedObjectContext *)context;

/**
 Returns an object initialized with the specific `SLNid` nid.
 
 Used for initializing nodes given a known nid. 
 If the node has already been initialized, that same node in memory will be returned.
 
 @param nid
 @return    Initialized object.
 
 @deprecated Use `MR_createEntity`.
 */
+ (instancetype) initWithId:(SLNid)nid DEPRECATED_ATTRIBUTE;
/**
 
 */
+ (instancetype) initWithId:(SLNid)nid inContext:(NSManagedObjectContext *)context;

/**
 Return the node type name. This is used in the requests to the `SLAPIManager`.
 
 This should be defined by the subclass implementation of `SLNode`.
 */
+ (NSString *) type;

/**
 
 
 Edit when subclassing.
 
 ```
 + (NSDictionary *) attributeMappings
 {
 NSMutableDictionary *attrMap = [NSMutableDictionary dictionaryWithDictionary:[[[self superclass] class] attributeMappings]];
 [attrMap setValue:@"name" forKey:@"name"];
 [attrMap setValue:@"location" forKey:@"location"];
 return [NSDictionary dictionaryWithDictionary: attrMap];
 }
 ```
 
 */
+ (NSDictionary *) attributeMappings;

/**
 
 */
- (NSString *) attributeForKey:(NSString *)key;

/**
 Key to Attribute mappings for the Node.
 */
- (NSString *) keyForAttribute:(NSString *)attribute;


/**
 Returns an NSArray of pending Nodes.
 */
+ (NSArray *) pending;

/**
 Returns the node with id corresponding to `SLNid`.
 @param nid         A valid `SLNid` for a node that will be retrieved from the database.
 @param callback    A callback for when the asycronous request has returned with the node.
 */
+ (void) readById:(SLNid)nid withCallback:(void (^)(SLNode *))callback;

/**
 Returns the node with id corresponding to `SLNid`.
 @param nid         A valid `SLNid` for a node that will be retrieved from the database.
 @param filters     `NSDictionary` representing the desired fields and relationships to be requested.
 @param callback    A callback for when the asycronous request has returned with the node.
 */
+ (void) readById:(SLNid)nid withFilters:(NSDictionary *)filters withCallback:(void (^)(SLNode *))callback;


/**
 Returns all nodes of the type subclassed by `SLNode`.
 
 Filter is set to not request any fields (`SLValue`) or relationships (`SLRelationship`).
 
 If you wish to request specific fields or relationships use `readAllWithFilters:withCallback:`.
 
 @param callback  The C-block style callback.
 @return void

 @deprecate Use `readAllWithAPIManager` instead.
 */
+ (void) readAllWithCallback:(void (^)(NSArray *))callback DEPRECATED_ATTRIBUTE;

/**
 Returns all nodes of the type subclassed by `SLNode`.
 
 @param callback    The C-block style callback.
 @param filters     `NSDictionary` representing the desired fields and relationships to be requested.
 @return void
 
 @deprecate Use `readAllWithAPIManager` instead.
 */
+ (void) readAllWithFilters:(NSDictionary *)filters withCallback:(void (^)(NSArray *))callback DEPRECATED_ATTRIBUTE;

/**
 Returns all nodes of the type subclassed by `SLNode`.
 
 @param manager     SLAPIManager instance.
 @param callback    The C-block style callback.
 @param filters     `NSDictionary` representing the desired fields and relationships to be requested.
 @return void
 */
+ (void) readAllWithAPIManager:(SLAPIManager *)manager withFilters:(NSDictionary *)filters withCallback:(void (^)(NSArray *))callback;


/**
 Creates a node client side (not persisted). 
 This node needs to be be saved to be persisted in any manner.
 */
+ (instancetype) createWithData:(NSDictionary *)theData withRels:(NSArray *)theRels;

/**
 Creates a node client side (not persisted). 
 This node needs to be be saved to be persisted in any manner.
 */
+ (instancetype) createWithData:(NSDictionary *)data;


/**
 Creates a node client side (not persisted). This node needs to be
 be saved to be persisted in any manner.
 */
+ (instancetype) createWithRels:(NSArray *)rels;

/**
 Creates a node client side (not persisted). This node needs to be
 be saved to be persisted in any manner.
 */
+ (instancetype) create;


/**
 Deletes the node with the corresponding `SLNid`.
 */
+ (void) deleteWithId:(SLNid)nid;

/**
 Deletes the node with the corresponding `SLNid`, with callback.
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
+ (void) deleteWithNodeArray:(NSArray *)nodes;

/**
 Deletes a set of nodes, {nodes}. This is done by applying the function
 {deleteWithId} to all nodes contained in the set {nodes} using their node
 id's.
 */
+ (void) deleteWithNodeArray:(NSArray *)nodes withCallback:(SLSuccessCallback)callback;

/**
 Deletes a set of nodes, {nodes}. This is done by applying the function
 {deleteWithId} to all nodes contained in the set {nodes} using their node
 id's.
 */
+ (void) deleteWithNodeArray:(NSArray *)nodes withProgressCallback:(void (^)(NSUInteger idx))progress withCallback:(SLSuccessCallback)callback;

/**
 Return the {type} of this node.
 */
- (NSString *) type;

/**
 Returns the {rels}, relationships, of this node.
 */
- (NSArray *) relationships;

/**
 Pushes a relationship into {rels}, verify if start or end node is this node.
 @return Returns `true` or `false` if the relationship was successfully added the the node.
 */
- (BOOL) addRelationship:(SLRelationship *)theRel;

/**
 Returns the current value of the `SLValue` of the node's data with the key `attr`.
 */
- (id) get:(NSString *)attr;

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

 @deprecated Use `pushWithAPIManager:withCallback` instead.
 */
- (void) save DEPRECATED_ATTRIBUTE;

/**
 Persists the node to the database, with callback on completion.
 
 This done by iterating through {data} and compiling a list of node SLValues
 that haven't been saved. From the set of unsaved properties a update request to
 SLAPI may be formulated.
 
 @deprecated Use `pushWithAPIManager:withCallback` instead.
 */
- (void) saveWithCallback:(SLSuccessCallback)callback DEPRECATED_ATTRIBUTE;

/**
 Persists the node to the database, with callback on completion.
 
 This done by iterating through {data} and compiling a list of node SLValues
 that haven't been saved. From the set of unsaved properties a update request to
 SLAPI may be formulated.
 */
- (void) pushWithAPIManager:(SLAPIManager *)manager withCallback:(SLSuccessCallback)callback;

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

/**
 
 */
- (NSDictionary *) serialize;

@end
