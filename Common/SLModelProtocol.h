//
//  SLNodeProtocol.h
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/23/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLObject.h"

@protocol SLModelProtocol <NSObject>

@required
@property (strong, nonatomic) SLNid nid;


/**
 Return the model type name. This is used in the requests to the `SLAdapter`.
 
 This should be defined by the subclass implementation of `SLModel`.
 */
@required
+ (NSString *) type;


/**
 Returns an object initialized with the specific `SLNid` nid.
 
 Used for initializing nodes given a known nid.
 If the node has already been initialized, that same node in memory will be returned.
 
 @param nid
 @return    Initialized object.
 */
@required
+ (instancetype) initWithId:(SLNid)nid;


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
- (NSDictionary *) serialize:(NSDictionary *)options;

/**
 Get all model Attributes by name.
 */
+ (NSDictionary *) attributesByName;

/**
 Get all model Attributes by name.
 */
+ (NSDictionary *) relationshipsByName;


@end
