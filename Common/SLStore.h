//
//  SLStore.h
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-17.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLObject.h"
#import "SLModel.h"
#import "SLAdapter.h"
#import <Promise.h>

@interface SLStore : SLObject

/**
 Return a singleton Store.
 */
+ (instancetype) sharedStore;

/**
 
 */
@property (nonatomic, retain) SLAdapter *adapter;


/**
 
 */
@property (strong, nonatomic) NSManagedObjectContext *context;
/**
 Push some raw data into the store.
 
 This method can be used both to push in brand new records, as well as to update existing records. You can push in more than one type of object at once. All objects should be in the format expected by the serializer.
 */
- (void) pushPayload:(NSDictionary *)payload withModel:(Class)modelClass;

/**
 Create a new record in the current store. The properties passed to this method are set on the newly created record.
 */
- (instancetype) createRecord:(Class)modelClass withProperties:(NSDictionary *)properties;

/**
 This method returns a record for a given type and id combination.
 */
- (PMKPromise *) find:(Class)modelClass byId:(SLNid)nid;

/**
 This method delegates a query to the adapter. This is the one place where adapter-level semantics are exposed to the application.
 
 Exposing queries this way seems preferable to creating an abstract query language for all server-side queries, and then require all adapters to implement them.
 
 This method returns a promise, which is resolved with a RecordArray once the server returns.
 */
- (PMKPromise *) find:(Class)modelClass withQuery:(NSDictionary *)query;

/**
 This method returns an array of all records adapter can find. It triggers the adapter's findAll method to give it an opportunity to populate the array with records of that type.
 */
- (PMKPromise *) findAll:(Class)modelClass;

/**
 
 */
- (PMKPromise *) findMany:(Class)modelClass withIds:(NSArray *)ids;

/**
 Update existing records in the store. Unlike push, update will merge the new data properties with the existing properties. This makes it safe to use with a subset of record attributes. This method expects normalized data.
 
 update is useful if you app broadcasts partial updates to records.
 */
- (PMKPromise *) update:(Class)modelClass withData:(NSDictionary *)data;

/**
 If the model `isDirty` this function will discard any unsaved changes
 */
- (SLModel *) rollback:(SLModel *)record;

/**
 For symmetry, a record can be deleted via the store.
 */
- (PMKPromise *) deleteRecord:(SLModel *)record;

/**
 Returns a JSON representation of the record using a custom
 type-specific serializer, if one exists.
 
 The available options are:
 
 * `includeId`: `true` if the record's ID should be included in
 the JSON representation
 
 @method serialize
 @private
 @param {DS.Model} record the record to serialize
 @param {Object} options an options hash
 */
- (NSDictionary *) serialize:(SLModel *)record withOptions:(NSDictionary *) options;

/**
 Push some data for a given type into the store.
 
 This method expects normalized data:
 
 The ID is a key named id (an ID is mandatory)
 The names of attributes are the ones you used in your model's DS.attrs.
 Your relationships must be:
 represented as IDs or Arrays of IDs
 represented as model instances
 represented as URLs, under the links key

 */
- (SLModel *) push:(Class)modelClass withData:(NSDictionary *)datum;

/**
 If you have an Array of normalized data to push, you can call pushMany with the Array, and it will call push repeatedly for you.
 */
- (NSArray *) pushMany:(Class)modelClass withData:(NSArray *)data;

@end
