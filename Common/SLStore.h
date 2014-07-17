//
//  SLStore.h
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-17.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLObject.h"
#import "SLModel.h"
#import <Promise.h>

@interface SLStore : SLObject

/**
 Push some raw data into the store.
 
 This method can be used both to push in brand new records, as well as to update existing records. You can push in more than one type of object at once. All objects should be in the format expected by the serializer.
 */
- (void) pushPayload:(NSDictionary *)payload withModel:(Class)modelClass;



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


@end
