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

- (id) init
{
    self = [super init];
    if (self) {
        // Initialize variables
        _saved = false;
        data = [NSDictionary dictionary];
        rels = [SLRelationshipArray array];
        //element_type = @"SLNode";
    }
    return self;
}

+ (NSString *) type
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

+ (void) readById:(SLNid)nid withCallback:(void (^)(SLNode *))callback
{
    @throw SLExceptionImplementationNotFound;
    // TODO: Implement AFNetworking
}

+ (void) readAllWithCallback:(void (^)(SLNodeArray *))callback
{
    void (^completionBlock)(BOOL) = ^(BOOL success){
        NSLog(@"Completion Block!");
    };

    NSDictionary *jsonQuery = @{@"filter":@{@"fields":[NSNumber numberWithBool:TRUE], @"rels":[NSNumber numberWithBool:TRUE]}};
    [[SLAPIManager sharedManager] performRequestWithMethod:SLHTTPMethodGET withPath:[[self class] type] withParameters:jsonQuery withCallback:completionBlock];

}

+ (instancetype) createWithData:(NSDictionary *)data withRels:(SLRelationshipArray *)rels
{
    return [[[self class] alloc] init];
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
    @throw SLExceptionImplementationNotFound;
    // TODO: Implement AFNetworking
}

+ (void) deleteWithNode:(SLNode *)node
{
    [[self class] deleteWithNode:node withCallback:nil];
}

+ (void) deleteWithNode:(SLNode *)node withCallback:(SLSuccessCallback)callback
{
    [[self class] deleteWithId:node->nid withCallback:callback];
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
        [self->rels addObject:theRel];
        return true;
    } else {
        return false;
    }
}


- (void) update:(NSString *)attr value:(id)value
{
    [(SLValue *)[data objectForKey:attr] set:value];
}

- (void) save
{
    [self saveWithCallback:nil];
}

- (void) saveWithCallback:(SLSuccessCallback)callback
{
    NSMutableDictionary *notSaved = [NSMutableDictionary dictionary];
    SLValue *val;
    for (NSString *key in data)
    {
        val = [data objectForKey:key];
        if (![val isSaved])
        {
            // Value is not already saved
            [notSaved setObject:val forKey:key];
        }
    }
    // TODO: Implement AFNetworking
    @throw SLExceptionImplementationNotFound;
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
