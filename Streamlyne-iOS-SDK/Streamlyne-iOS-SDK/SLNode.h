//
//  SLNode.h
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLValue.h"
#import "SLRelationship.h"

@interface SLNode : NSObject {
    
    /*
     The SLAPI route. ex ) '/organization'
     */
    @protected
    NSString *route;
    
    /*
     A reference to the node manage used to instantiate this SLNode.
     This is kept so that SLNode may call setSaved and setUnsaved passing it's
     id.
     */
    @protected
    id nodeManager;
    
    /**
     String s -> SLValue s
     */
    @protected
    NSDictionary *data;
    
    @protected
    NSDictionary *backupData;
    
    /**
     A list of relationships to this node.
     */
    @protected
    NSArray *rels;
}

+ (SLNode *) readById:(int)nid;

+ (SLNode *) readAll;

+ (SLNode *) createWithData:(NSDictionary *)data withRels:(NSArray *)rels;

+ (void) deleteById:(int)nid;

+ (void) deleteNode:(SLNode *)node;

+ (void) deleteNodeSet:(NSArray *)nodes;

/**
 Update a single attribute.
 */
- (void) update:(NSString *)attr value:(id)value;


/**
 Persists the node to the database.
 
 This done by iterating through {data} and compiling a list of node SLValues
 that haven't been saved. From the set of unsaved properties a update request to
 SLAPI may be formulated.
 */
- (Boolean *) save;

- (Boolean *) isSaved;

- (void) checkSaved;


- (void) discardChanges;

- (void) discardChangesTo:(NSString *)attr;

/**
 Delete's this instance from the database.
 */
- (void) remove;

@end
