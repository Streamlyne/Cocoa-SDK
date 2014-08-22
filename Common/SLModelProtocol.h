//
//  SLNodeProtocol.h
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/23/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MagicalRecord/MagicalRecord.h>
#import "SLObject.h"
#import <CoreData/CoreData.h>
#import <PromiseKit.h>

@protocol SLModelProtocol <NSObject>

@required
@property (strong, nonatomic) SLNid nid;


/**
 Return the model type name. This is used in the requests to the `SLAdapter`.
 
 This should be defined by the subclass implementation of `SLModel`.
 */
@required
+ (NSString *) type;

//
///**
// Returns an object initialized with the specific `SLNid` nid.
// 
// Used for initializing nodes given a known nid.
// If the node has already been initialized, that same node in memory will be returned.
// 
// @param nid
// @return    Initialized object.
// */
//@required
//+ (instancetype) initWithId:(SLNid)nid DEPRECATED_ATTRIBUTE;
//
//@required
//+ (instancetype) initWithId:(SLNid)nid inContext:(NSManagedObjectContext *)context;
//
//@required
//+ (instancetype) initInContext:(NSManagedObjectContext *)context;
//

/**
 Create a new record in the current store. The properties passed to this method are set on the newly created record.
 */
@required
+ (instancetype) createRecord;
@required
+ (instancetype) createRecord:(NSDictionary *)properties;

@required
+ (instancetype) MR_createInContext:(NSManagedObjectContext *)context;
+ (instancetype) MR_findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context;

/**
 Get the record for the given ID.
 @return Promise that will be a `SLModel` if successful.
 */
+ (PMKPromise *) recordForId:(SLNid)nid;

/**
 Attribute to Key mappings for the Model.
 
 Edit when subclassing, if neccessary.
 */
@required
+ (NSString *) keyForAttribute:(NSString *)attribute;

/**
 Relationship to Key mappings for the Model.
 
 Edit when subclassing, if neccessary.
 */
@required
+ (NSString *) keyForRelationship:(NSString *)relationship;


/**
 Create a JSON representation of the record, using the serialization strategy of the store's adapter.
 
 serialize takes an optional hash as a parameter, currently supported options are:
 
 includeId: true if the record's ID should be included in the JSON representation.
 */
@required
- (NSDictionary *) serialize:(NSDictionary *)options;

/**
 Get all model Attributes by name.
 */
@required
+ (NSDictionary *) attributesByName;

/**
 Get all model Attributes by name.
 */
@required
+ (NSDictionary *) relationshipsByName;

/**
 Iterate over all of the attributes with a callback.
 */
@required
+ (void) eachAttribute:(void(^)(NSString *key, NSAttributeDescription *attribute))callback;

/**
 Iterate over all of the relationships with a callback.
 */
@required
+ (void) eachRelationship:(void(^)(NSString *key, NSRelationshipDescription *relationship))callback;


@end
