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
- (instancetype) setupData:(NSDictionary *)data;

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
 Return the {type} of this node.
 */
- (NSString *) type;

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
- (PMKPromise *) save;

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
 Create a new record in the current store. The properties passed to this method are set on the newly created record.
 */
+ (instancetype) createRecord:(NSDictionary *)properties;

/**
 This method returns a record for a given type and id combination.
 */
+ (PMKPromise *) findById:(SLNid)nid;

/**
 This method delegates a query to the adapter. This is the one place where adapter-level semantics are exposed to the application.
 
 Exposing queries this way seems preferable to creating an abstract query language for all server-side queries, and then require all adapters to implement them.
 
 This method returns a promise, which is resolved with a RecordArray once the server returns.
 */
+ (PMKPromise *) findQuery:(NSDictionary *)query;

/**
 This method returns an array of all records adapter can find. It triggers the adapter's findAll method to give it an opportunity to populate the array with records of that type.
 */
+ (PMKPromise *) findAll;

/**
 
 */
+ (PMKPromise *) findMany:(NSArray *)ids;

/**
 Update existing records in the store. Unlike push, update will merge the new data properties with the existing properties. This makes it safe to use with a subset of record attributes. This method expects normalized data.
 
 update is useful if you app broadcasts partial updates to records.
 */
- (PMKPromise *) updateRecord:(NSDictionary *)properties;

/**
 If the model `isDirty` this function will discard any unsaved changes
 */
- (instancetype) rollback;

/**
 A record can be deleted.
 */
- (PMKPromise *) deleteRecord;

/**
 Create a JSON representation of the record, using the serialization strategy of the store's adapter.
 
 serialize takes an optional hash as a parameter, currently supported options are:
 
 includeId: true if the record's ID should be included in the JSON representation.
 */
- (NSDictionary *) serialize:(NSDictionary *)options;


@end
