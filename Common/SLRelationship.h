//
//  SLRelationship.h
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid and Glavin Wiechert on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLObject.h"
#import "SLModel.h"

/** --------------------------------------------------------------------------------
 */
@interface SLRelationship : NSObject {
    
}

/**
 Name of the relationship type.
 */
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) id<SLModelProtocol> startNode;
@property (strong, nonatomic) id<SLModelProtocol> endNode;
@property (nonatomic) BOOL required;


//@property (setter = setName) NSString *name;

/**
 The direction
 */
- (id) initWithName:(NSString *)theName withStartNode:(id)startNode withEndNode:(id)endNode;

/**
 
 */
- (SLRelationshipDirection) directionWithNode:(id)theNode;


/**
 Returns the value of saved.
 */
- (BOOL) isSaved;


/**
 Set saved equal to true. This does not garuantee that the value
 has been persisted.
 */
- (void) setSaved;

@end

