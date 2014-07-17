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
#import "SLSerializer.h"
#import <PromiseKit.h>

/**
 `SLNode` is intended to be implemented and then subclassed.
 
 ## Subclassing Notes
 `SLNode` is intended to be implemented and then subclassed.
 
 ### Methods to Override
 In a subclass, you must override all these methods.
 
 - `init`
 - `type`
 
 */
@interface SLModel : NSManagedObject <SLModelProtocol> {
}
// Properties
/**
 */
@property (nonatomic, retain) SLNid nid;
/**
 
 */
@property (nonatomic, retain) NSNumber *syncState;
/**
 
 */
@property (nonatomic, retain) NSDate *dateCreated;
/**
 
 */
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
 
 @deprecated Use `setupData`.
 */
+ (instancetype) initWithId:(SLNid)nid DEPRECATED_ATTRIBUTE;

/**
 @deprecated Use `setupData`.
 */
+ (instancetype) initWithId:(SLNid)nid inContext:(NSManagedObjectContext *)context;

/**
 Setup record with existing data.
 Used when pushing records from the server into the store.
 
 @private
 */
+ (instancetype) setupData:(NSDictionary *)data;

/**
 Return the node type name. This is used in the requests to the `SLAPIManager`.
 
 This should be defined by the subclass implementation of `SLNode`.
 */
+ (NSString *) type;

/**
 Attribute to Key mappings for the Model.
 
 Edit when subclassing, if neccessary.
 */
- (NSString *) keyForAttribute:(NSString *)attribute;

/**
 Relationship to Key mappings for the Model.
 
 Edit when subclassing, if neccessary.
 */
- (NSString *) keyForRelationship:(NSString *)relationship;

/**
 Returns an NSArray of pending Nodes.
 */
+ (NSArray *) pending;

/**
 Returns the node with id corresponding to `SLNid`.
 @param nid         A valid `SLNid` for a node that will be retrieved from the database.
 @param callback    A callback for when the asycronous request has returned with the node.
 */
+ (PMKPromise *) readById:(SLNid)nid;

/**
 Returns the node with id corresponding to `SLNid`.
 @param nid         A valid `SLNid` for a node that will be retrieved from the database.
 @param filters     `NSDictionary` representing the desired fields and relationships to be requested.
 @param callback    A callback for when the asycronous request has returned with the node.
 */
+ (PMKPromise *) readById:(SLNid)nid withFilters:(NSDictionary *)filters;


/**
 Returns all nodes of the type subclassed by `SLNode`.
 
 Filter is set to not request any fields (`SLValue`) or relationships (`SLRelationship`).
 
 If you wish to request specific fields or relationships use `readAllWithFilters:withCallback:`.
 
 @param callback  The C-block style callback.
 @return void
 
 @deprecate Use `readAllWithAPIManager` instead.
 */
+ (PMKPromise *) readAll;

/**
 Returns all nodes of the type subclassed by `SLNode`.
 
 @param callback    The C-block style callback.
 @param filters     `NSDictionary` representing the desired fields and relationships to be requested.
 @return void
 
 @deprecate Use `readAllWithAPIManager` instead.
 */
+ (PMKPromise *) readAllWithFilters:(NSDictionary *)filters;

/**
 Returns all nodes of the type subclassed by `SLNode`.
 
 @param manager     SLAPIManager instance.
 @param callback    The C-block style callback.
 @param filters     `NSDictionary` representing the desired fields and relationships to be requested.
 @return void
 */
+ (PMKPromise *) readAllWithAPIManager:(SLAPIManager *)manager withFilters:(NSDictionary *)filters;


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
+ (PMKPromise *) deleteWithId:(SLNid)nid;


/**
 Deletes {node}. This is done by calling {deleteWithId} with the id of {node}.
 */
+ (PMKPromise *) deleteWithNode:(SLModel *)node;


/**
 Deletes a set of nodes, {nodes}. This is done by applying the function
 {deleteWithId} to all nodes contained in the set {nodes} using their node
 id's.
 */
+ (PMKPromise *) deleteWithNodeArray:(NSArray *)nodes;

/**
 Deletes a set of nodes, {nodes}. This is done by applying the function
 {deleteWithId} to all nodes contained in the set {nodes} using their node
 id's.
 */
+ (PMKPromise *) deleteWithNodeArray:(NSArray *)nodes withProgressCallback:(void (^)(NSUInteger idx, id item)) progress ;
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
 Save the record and persist any changes to the record to an extenal source via the adapter.
 */
- (void) save;

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
- (PMKPromise *) pushWithAPIManager:(SLAPIManager *)manager;

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
- (PMKPromise *) remove;

/**
 Create a new record in the current store. The properties passed to this method are set on the newly created record.
 */
- (instancetype) createRecord:(NSDictionary *)properties;

/**
 This method returns a record for a given type and id combination.
 */
- (PMKPromise *) findById:(SLNid)nid;

/**
 This method delegates a query to the adapter. This is the one place where adapter-level semantics are exposed to the application.
 
 Exposing queries this way seems preferable to creating an abstract query language for all server-side queries, and then require all adapters to implement them.
 
 This method returns a promise, which is resolved with a RecordArray once the server returns.
 */
- (PMKPromise *) findQuery:(NSDictionary *)query;

/**
 This method returns an array of all records adapter can find. It triggers the adapter's findAll method to give it an opportunity to populate the array with records of that type.
 */
- (PMKPromise *) findAll;

/**
 
 */
- (PMKPromise *) findMany:(NSArray *)ids;

/**
 Update existing records in the store. Unlike push, update will merge the new data properties with the existing properties. This makes it safe to use with a subset of record attributes. This method expects normalized data.
 
 update is useful if you app broadcasts partial updates to records.
 */
- (instancetype) updateRecord:(NSDictionary *)properties;

/**
 If the model `isDirty` this function will discard any unsaved changes
 */
- (instancetype) rollback;

/**
 For symmetry, a record can be deleted via the store.
 */
- (instancetype) deleteRecord;

/**
 Create a JSON representation of the record, using the serialization strategy of the store's adapter.
 
 serialize takes an optional hash as a parameter, currently supported options are:
 
 includeId: true if the record's ID should be included in the JSON representation.
 */
- (NSDictionary *) serialize:(NSDictionary *)options;


@end
