//
//  SLNode.m
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLNode.h"
#import "SLValue.h"
#import "SLRelationship.h"
#import "SLAPIManager.h"

@implementation SLNode

@synthesize saved = _saved;
@synthesize nid;

- (id) init
{
    self = [super init];
    if (self) {
        // Initialize variables
        self->_saved = false;
        self->nid = SLNidNodeNotCreated;
        self->data = [NSDictionary dictionary];
        self->rels = [SLRelationshipArray array];
        // Edit data schema
        NSMutableDictionary *tempData = [self->data mutableCopy];
        //SLValue *idVal = [[SLValue alloc]initWithType:[NSString class]];
        //[tempData setValue:idVal forKey:@"id"];
        self->data = tempData;
    }
    return self;
}

+ (NSString *) type
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in the subclass %@.", NSStringFromSelector(_cmd), [self class]]
                                 userInfo:nil];
}

+ (void) readById:(SLNid)nid withCallback:(void (^)(SLNode *))callback
{
    
    SLRequestCallback completionBlock = ^(NSError *error, id operation, id responseObject) {
        //NSLog(@"SLRequestCallback completionBlock!");
        //NSLog(@"<%@>: %@", [responseObject class], responseObject);
        
        // Process
        id<SLNodeProtocol> node = [[self class] createWithData:responseObject[@"data"] withRels:nil];
        NSLog(@"Node Id: %@", responseObject[@"id"]);
        [((SLNode *)node) setNid: (SLNid) responseObject[@"id"] ];

        // Return
        callback(node);
    };
    
    NSDictionary *jsonQuery = @{@"filter":@{@"fields":[NSNumber numberWithBool:TRUE], @"rels":[NSNumber numberWithBool:TRUE]}};
    NSString *thePath = [NSString stringWithFormat:@"%@/%@", [[self class] type],nid];
    [[SLAPIManager sharedManager] performRequestWithMethod:SLHTTPMethodGET withPath:thePath withParameters:jsonQuery withCallback:completionBlock];
    
}

+ (void) readAllWithCallback:(void (^)(SLNodeArray *))callback
{
    SLRequestCallback completionBlock = ^(NSError *error, id operation, id responseObject) {
        //NSLog(@"SLRequestCallback completionBlock!");
        //NSLog(@"<%@>: %@", [responseObject class], responseObject);
        SLNodeArray *nodes = [SLNodeArray array];
        NSArray *arr = ((NSDictionary *)responseObject)[@"nodes"];
        for (NSDictionary* curr in arr)
        {
            id<SLNodeProtocol> node = [[self class] createWithData:curr[@"data"] withRels:nil];
            NSLog(@"Node Id: %@", curr[@"id"]);
            [((SLNode *)node) setNid: (SLNid) curr[@"id"] ];
            [nodes addObject:node];
        }
        callback(nodes);
    };

    NSDictionary *jsonQuery = @{@"filter":@{@"fields":[NSNumber numberWithBool:TRUE], @"rels":[NSNumber numberWithBool:TRUE]}};
    [[SLAPIManager sharedManager] performRequestWithMethod:SLHTTPMethodGET withPath:[[self class] type] withParameters:jsonQuery withCallback:completionBlock];

}

+ (instancetype) createWithData:(NSDictionary *)theData withRels:(SLRelationshipArray *)theRels
{
    SLNode *node = [[[self class] alloc] init];
    // TODO: Fix this so it validates data and rels first
    // Data
    NSString *key = nil;
    for (key in theData)
    {
        NSLog(@"Update %@: %@", key, [theData objectForKey:key]);
        [node update:key value:[theData objectForKey:key]];
    }
    // Rels
    SLRelationship *currRel;
    for (currRel in theRels)
    {
        [node addRelationship:currRel];
    }
    return node;
}

+ (instancetype) createWithData:(NSDictionary *)data
{
    return [[self class] createWithData:data withRels:nil];
}

+ (instancetype) createWithRels:(SLRelationshipArray *)rels
{
    return [[self class] createWithData:nil withRels:rels];
}

+ (instancetype) create
{
    return [[self class] createWithData:nil withRels:nil];
}

+ (void)deleteWithId:(SLNid)nid
{
    [self deleteWithId:nid withCallback:nil];
}

+ (void) deleteWithId:(SLNid)nid withCallback:(SLSuccessCallback)callback
{
    
    SLRequestCallback completionBlock = ^(NSError *error, id operation, id responseObject) {
        NSLog(@"SLRequestCallback completionBlock!");
        NSLog(@"<%@>: %@", [responseObject class], responseObject);
        
        // TODO: Check if successful
        
        callback(true);
    };
    
    NSString *thePath = [NSString stringWithFormat:@"%@/%@", [[self class] type],nid];
    NSLog(@"theDeletePath: %@", thePath);
    [[SLAPIManager sharedManager] performRequestWithMethod:SLHTTPMethodDELETE withPath:thePath withParameters:nil withCallback:completionBlock];

}

+ (void) deleteWithNode:(SLNode *)node
{
    [[self class] deleteWithNode:node withCallback:nil];
}

+ (void) deleteWithNode:(SLNode *)node withCallback:(SLSuccessCallback)callback
{
    [[self class] deleteWithId:node->nid withCallback:^(BOOL success) {
        if (success)
        {
            node->nid = SLNidNodeNotCreated; // Remove
            callback(true);
        } else
        {
            callback(false);
        }
    }];
}

+ (void) deleteWithNodeArray:(SLNodeArray *)nodes
{
    [[self class] deleteWithNodeArray:nodes withProgressCallback:nil withCallback:nil];
}

+ (void) deleteWithNodeArray:(SLNodeArray *)nodes withCallback:(SLSuccessCallback)callback
{
    [[self class] deleteWithNodeArray:nodes withProgressCallback:nil withCallback:callback];
}

+ (void) deleteWithNodeArray:(SLNodeArray *)nodes withProgressCallback:(void (^)(NSUInteger idx))progress withCallback:(SLSuccessCallback)callback {
    
    __block BOOL successful = true;
    __block NSUInteger completed = 0;
    __block NSUInteger totalNodes = [nodes count];
    __block void (^ completionCallback)() = ^{
        // Check if all nodes have been processed (removed)
        if (completed >= totalNodes)
        {
            // All nodes processed, check for completion callback
            if (callback != nil)
            {
                callback(successful);
            }
        }
    };
    SLNode *node;
    for (node in nodes)
    {
        [node removeWithCallback:^(BOOL success)
        {
            if (!success) {
                successful = false;
            }
            if (progress != nil) {
                progress(completed);
            }
            completed++;
            completionCallback();
        }];
    }
}

- (NSString *) description
{
    
     return [NSString stringWithFormat:@"<%@ %p: %@>", [self class], self,
            [NSDictionary dictionaryWithObjectsAndKeys:
             NSNullIfNil([self nid]), @"id",
             NSNullIfNil([self type]), @"type",
             NSNullIfNil([self->data description]), @"data",
             NSNullIfNil([self->rels description]), @"relationships",
             nil
             ] ];
     
    //return [NSString stringWithFormat:@"<%@: { type: \"%@\", data: %@, relationships: %@ } >", [self class], [self type], [self->data description], [self->rels description]];
}

- (NSString *) type
{
    return [[self class] type];
}

- (SLRelationshipArray *) relationships
{
    return self->rels;
}

- (BOOL) addRelationship:(SLRelationship *)theRel
{
    // Validate relationship
    if ( (theRel->startNode == self) || (theRel->endNode == self) ) {
        
        // Check if already exists
        // This will eventually contain the index of the object.
        // Initialize it to NSNotFound so you can check the results after the block has run.
        __block NSInteger foundIndex = NSNotFound;
        
        [self->rels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[SLRelationship class]]) {
                foundIndex = idx;
                // stop the enumeration
                *stop = YES;
            }
        }];
        
        if (foundIndex != NSNotFound) {
            // You've found the first object of that class in the array
        } else {
            [self->rels addObject:theRel];
        }
        return true;
    } else {
        return false;
    }
}

- (SLValue *) get:(NSString *)attr
{
    return [self->data objectForKey:attr];
}


- (void) update:(NSString *)attr value:(id)value
{
    [((SLValue *)[data objectForKey:attr]) set:value];
}

- (void) save
{
    [self saveWithCallback:nil];
}

- (void) saveWithCallback:(SLSuccessCallback)callback
{
    // Create serialized delta
    NSMutableDictionary *notSavedData = [NSMutableDictionary dictionary];
    NSString *key;
    for (key in data)
    {
        SLValue *val = [data objectForKey:key];
        if (![val isSaved])
        {
            // Value is not already saved
            [notSavedData setObject:[val get] forKey:key];
        }
    }
    NSMutableArray *notSavedRels = [NSMutableArray array];
    SLRelationship* rel;
    for (rel in rels)
    {
        SLRelationshipDirection dir = [rel directionWithNode:self];
        
        if (dir == SLRelationshipIncoming) {
            SLNode *node = rel->startNode;
            [notSavedRels addObject:@{
                                      @"id":node->nid,
                                      @"dir":@"in",
                                      @"nodeType": [rel->startNode type],
                                      @"relsType": rel->name
                                      }];
        } else if (dir == SLRelationshipOutgoing) {
            SLNode *node = rel->endNode;
            [notSavedRels addObject:@{
                                      @"id":node->nid,
                                      @"dir":@"out",
                                      @"nodeType": [rel->endNode type],
                                      @"relsType": rel->name
                                      }];
        } else {
            // SLRelationshipNotFound
            NSLog(@"SLRelationshipNotFound");
            //[notSavedRels addObject:rel];
            @throw SLExceptionImplementationNotFound;
        }
    }
    
    NSDictionary *delta = @{@"data": notSavedData, @"rels": notSavedRels};
    NSLog(@"Save data: %@", delta);
    
    // POST the CREATE/UPDATE
    SLRequestCallback completionBlock = ^(NSError *error, id operation, id responseObject) {
        NSLog(@"SLRequestCallback completionBlock!");
        NSLog(@"<%@>: %@", [responseObject class], responseObject);
        
        // TODO: Check if successful, then mark the successful data and relationship fields as `saved`
        
        // Process
        //id node = [[self class] createWithData:responseObject[@"data"] withRels:nil];
        //((SLNode *)node)->nid = (SLNid) responseObject[@"id"];
        
        // Return
        callback(true);
    };
    //
    NSString *thePath;
    if (nid == SLNidNodeNotCreated)
    {
        // New
        thePath = [NSString stringWithFormat:@"%@", [[self class] type]];
    } else
    {
        // Update
        thePath = [NSString stringWithFormat:@"%@/%@", [[self class] type],nid];
    }
    NSLog(@"Save Path: %@", thePath);
    [[SLAPIManager sharedManager] performRequestWithMethod:SLHTTPMethodPOST withPath:thePath withParameters:delta withCallback:completionBlock];
    
    
}

- (BOOL) isSaved
{
    return _saved;
}

- (void) checkSaved
{
    SLValue *val;
    for (val in rels) {
        if ( ! [val isSaved] ) {
            // Not saved
            _saved = false;
            break; // Stop iterating, since it is already proven to not all be saved.
        }
    }
}

- (void) discardChanges
{
    SLValue *val;
    for (val in rels) {
        [val discardChanges];
    }
}

- (void) discardChangesTo:(NSString *)attr
{
    SLValue *val = [data objectForKey:attr];
    if (val) {
        [val discardChanges];
    }
}

- (void) remove
{
    [self removeWithCallback:nil];
}

- (void) removeWithCallback:(SLSuccessCallback)callback
{
    [[self class] deleteWithNode:self withCallback:callback];
}

@end
