//
//  SLNode.m
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLModel.h"
#import "SLAdapter.h"
#import "NSString+SLStringHelpers.h"

@interface SLModel()
@property (nonatomic, retain) SLStore *store;
@end

@implementation SLModel

@dynamic nid;
@dynamic dateCreated;
@dynamic dateUpdated;

@synthesize saved = _saved;

+ (SLAdapter *) sharedAPIManager
{
    @synchronized([self class]) {
        return [SLAdapter sharedAdapter];
    }
}

- (instancetype) init {
    self = [self initInContext:[NSManagedObjectContext MR_defaultContext]];
    
    return self;
}

- (instancetype) initInContext:(NSManagedObjectContext *)context
{
    NSLog(@"init %@", [self class]);
    //    NSLog(@"inManagedObjectContext: %@", context.persistentStoreCoordinator.managedObjectModel.entities);
    
    //self = [super init];
    //self = [[self class] MR_createEntity];
    self = [[self class] MR_createInContext:context];
    if (self) {
        // Initialize variables
        _saved = false;
        self.nid = SLNidNodeNotCreated;
    }
    
    return self;
}

+ (instancetype) initWithId:(SLNid)nid {
    return [self initWithId:nid inContext:[NSManagedObjectContext MR_defaultContext]];
}

+ (instancetype) initWithId:(SLNid)nid inContext:(NSManagedObjectContext *)context
{
    @synchronized([self class])
    {
        __block SLModel *node;
        //[context performBlockAndWait:^(void){
        NSLog(@"initWithId, before find node");
        node = [[self class] MR_findFirstByAttribute:@"nid" withValue:nid inContext:context];
        NSLog(@"initWithId: %@, node: %@", nid, node);
        if (node == nil) {
            node = [[[self class] alloc] initInContext:context];
            node.nid = nid;
        }
        //}];
        return node;
    }
}

+ (NSString *) keyForAttribute:(NSString *)attribute
{
    attribute = [attribute underscore];
    return attribute;
}

+ (NSString *) keyForRelationship:(NSString *)relationship {
    return relationship;
}

+ (NSArray *) pending
{
    NSArray *pendingNodes = [[self class] MR_findAllWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"NOT syncState == %@", @(SLSyncStateSynced)]]];
    return pendingNodes;
}


/*
 - (NSString *) description
 {
 //return [NSString stringWithFormat:@"<%@>", [self class]];
 
 return [NSString stringWithFormat:@"<%@ %p: %@>", [self class], self,
 [NSDictionary dictionaryWithObjectsAndKeys:
 NSNullIfNil([self nid]), @"id",
 NSNullIfNil([self type]), @"type",
 NSNullIfNil([self.data description]), @"data",
 NSNullIfNil([self.rels description]), @"relationships",
 nil
 ] ];
 
 //return [NSString stringWithFormat:@"<%@: { type: \"%@\", data: %@, relationships: %@ } >", [self class], [self type], [self.data description], [self.rels description]];
 }
 */

- (NSString *) type
{
    return [[self class] type];
}

+ (NSString *) type
{
    //    NSString *className = NSStringFromClass([self class]);
    //    NSString *name = [className lowercaseString];
    //    // TODO: Pluralize
    //    // TODO: Dasherize
    //    return name;
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override method '%@' in the subclass '%@'.", NSStringFromSelector(_cmd), [self class]]
                                 userInfo:nil];
}


+ (PMKPromise *) readById:(SLNid)nid
{
    NSDictionary *filters = @{
                              @"filter":@{
                                      @"fields": [NSNumber numberWithBool: TRUE],
                                      @"rels": [NSNumber numberWithBool: TRUE]
                                      }
                              };
    return [self readById:nid withFilters:filters];
}

+ (PMKPromise *) readById:(SLNid)nid withFilters:(NSDictionary *)filters
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        
        SLAdapter *manager = [[self class] sharedAPIManager];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *context) {
            
            SLRequestCallback completionBlock = ^(NSError *error, id operation, id responseObject) {
                //NSLog(@"SLRequestCallback completionBlock!");
                //NSLog(@"<%@>: %@", [responseObject class], responseObject);
                
                // Process & Read Node
                SLModel *record = [[self class] initWithId:(SLNid) responseObject[@"id"] inContext:context];
                record.syncState = @(SLSyncStateSynced);
                [record setupData:responseObject];
                // Return
                [context MR_saveToPersistentStoreAndWait];
                //
                fulfiller(record);
            };
            
            NSString *thePath = [NSString stringWithFormat:@"%@/%@", [[self class] type],nid];
            [manager performRequestWithMethod:SLHTTPMethodGET withPath:thePath withParameters:filters]
            .then(completionBlock)
            .catch(rejecter);
            
        } completion:^(BOOL success, NSError *error) {
            // Return
            fulfiller( [[self class] MR_findFirstByAttribute:@"nid" withValue:nid] );
        }];
        
    }];
}

+ (PMKPromise *) readAll
{
    NSDictionary *filters = @{
                              @"filter":@{
                                      @"fields": [NSNumber numberWithBool: TRUE],
                                      @"rels": [NSNumber numberWithBool: TRUE]
                                      }
                              };
    return [self readAllWithFilters:filters];
}

+ (PMKPromise *) readAllWithFilters:(NSDictionary *)filters
{
    SLAdapter *manager = [[self class] sharedAPIManager];
    NSLog(@"Manager: %@", manager);
    return [self readAllWithAPIManager:manager withFilters:filters];
}

+ (PMKPromise *) readAllWithAPIManager:(SLAdapter *)manager withFilters:(NSDictionary *)filters
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        
        __block NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            
            NSLog(@"Inside saving block");
            
            [manager performRequestWithMethod:SLHTTPMethodGET withPath:[[self class] type] withParameters:filters]
            .then(^(id responseObject, id operation) {
                NSLog(@"SLRequestCallback completionBlock.");
                NSLog(@"<%@>: %@", [responseObject class], responseObject);
                NSMutableArray *nodes = [NSMutableArray array];
                NSArray *arr = ((NSDictionary *)responseObject)[@"nodes"];
                for (NSDictionary* curr in arr)
                {
                    NSLog(@"curr: %@", curr);
                    SLModel *record = [[self class] initWithId:(SLNid) curr[@"id"] inContext:context];
                    record.syncState = @(SLSyncStateSynced);
                    [record setupData:curr];
                    [nodes addObject: record];
                    NSLog(@"Node: %@",record);
                    
                }
                // callback(nodes); // returning in the completion block
                [context MR_saveToPersistentStoreAndWait];
                [localContext save:nil];
                
                //
                NSLog(@"Done!!!");
                NSLog(@"%@ %@", context, localContext);
                
                // Return all nodes!
                fulfiller( [[self class] MR_findAll] );
                
            })
            .catch(rejecter);
            
        }];
        
        
    }];
}

+ (instancetype) createWithData:(NSDictionary *)theData withRels:(NSArray *)theRels
{
    SLModel *record = [[[self class] alloc] init];
    record.syncState = @(SLSyncStatePendingCreation);
    // Data
    [record setupData:theData];
    return record;
}

+ (instancetype) createWithData:(NSDictionary *)data
{
    return [[self class] createWithData:data withRels:nil];
}

+ (instancetype) createWithRels:(NSArray *)rels
{
    return [[self class] createWithData:nil withRels:rels];
}

+ (instancetype) create
{
    return [[self class] createWithData:nil withRels:nil];
}

+ (PMKPromise *) deleteWithId:(SLNid)nid
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        SLRequestCallback completionBlock = ^(NSError *error, id operation, id responseObject) {
            NSLog(@"SLRequestCallback completionBlock!");
            NSLog(@"<%@>: %@", [responseObject class], responseObject);
            
            // TODO: Check if successful
            if (error != nil) {
                fulfiller(PMKManifold(responseObject, operation));
            } else {
                rejecter(error);
            }
        };
        NSString *thePath = [NSString stringWithFormat:@"%@/%@", [[self class] type],nid];
        NSLog(@"theDeletePath: %@", thePath);
        [[[self class] sharedAPIManager] performRequestWithMethod:SLHTTPMethodDELETE
                                                         withPath:thePath withParameters:nil].then(completionBlock);
    }];
}

+ (PMKPromise *) deleteWithNode:(SLModel *)node
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        
        [[self class] deleteWithId:node.nid].then(^() {
            node.nid = SLNidNodeNotCreated; // Remove
            fulfiller(node);
        }).catch(rejecter);
    }];
}

+ (PMKPromise *) deleteWithNodeArray:(NSArray *)nodes
{
    return [[self class] deleteWithNodeArray:nodes withProgressCallback:nil];
}

+ (PMKPromise *) deleteWithNodeArray:(NSArray *)nodes withProgressCallback:(void (^)(NSUInteger idx, id item)) progress {
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        
        __block NSUInteger completed = 0;
        __block NSUInteger totalNodes = [nodes count];
        __block void (^ completionCallback)() = ^{
            // Check if all nodes have been processed (removed)
            if (completed >= totalNodes)
            {
                // All nodes processed, check for completion callback
                fulfiller(nodes);
            }
        };
        SLModel *node;
        for (node in nodes)
        {
            [node remove]
            .then(^()
                  {
                      if (progress != nil) {
                          progress(completed, node);
                      }
                      completed++;
                      completionCallback();
                  }).catch(^(NSError *error) {
                      rejecter(error);
                  });
        }
        
    }];
}

- (PMKPromise *) pushWithAPIManager:(SLAdapter *)manager
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        //
        NSString *thePath;
        if (self.nid == SLNidNodeNotCreated)
        {
            // New (CREATE)
            NSLog(@"CREATE %@", self);
            thePath = [NSString stringWithFormat:@"%@", [[self class] type]];
        } else
        {
            // Update (UPDATE)
            NSLog(@"UPDATE %@", self);
            thePath = [NSString stringWithFormat:@"%@/%@", [[self class] type], self.nid];
        }
        NSLog(@"Save Path: %@", thePath);
        NSLog(@"Manager: %@", manager);
        [manager performRequestWithMethod:SLHTTPMethodPOST withPath:thePath withParameters:nil]
        .then(fulfiller).catch(rejecter);
        
    }];
}

+ (NSEntityDescription *) entity
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    return [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
}

+ (NSDictionary *) attributesByName
{
    NSEntityDescription *entityDescription = self.entity;
    NSDictionary *attributes = [entityDescription attributesByName];
    return attributes;
}

- (NSDictionary *) attributesByName
{
    NSEntityDescription *entityDescription = self.entity;
    NSDictionary *attributes = [entityDescription attributesByName];
    return attributes;
}

+ (NSDictionary *) relationshipsByName
{
    NSEntityDescription *entityDescription = self.entity;
    NSDictionary *relationships = [entityDescription relationshipsByName];
    return relationships;
}

- (NSDictionary *) serializeData {
    NSMutableDictionary *theData = [NSMutableDictionary dictionary];
    NSDictionary *attributes = [self attributesByName];
    //NSLog(@"%@", attributes);
    for (NSString *attributeKey in attributes) {
        //NSLog(@"attribute: %@ = %@", attribute, [self valueForKey:(NSString *)attribute]);
        if ( ![attributeKey isEqual:@"syncState"] ) {
            [theData setValue:[self valueForKey:(NSString *)attributeKey] forKey:[[self class] keyForAttribute:(NSString *)attributeKey]];
        }
    }
    return [NSDictionary dictionaryWithDictionary:theData];
}


- (PMKPromise *) remove
{
    return [[self class] deleteWithNode:self];
}

//- (void) didChangeValueForKey:(NSString *)key {
//    NSLog(@"didChangeValueForKey %@", key);
//    if (
//        ( ![key isEqual: @"syncState"] ) &&
//        [[self syncState] isEqual: @(SLSyncStateSynced)]
//        ) {
//        [self setSyncState:@(SLSyncStatePendingUpdate)];
//    }
//}
//

+ (instancetype) createRecord:(NSDictionary *)properties
{
    return [[[self class] alloc] init];
}

+ (PMKPromise *) findById:(SLNid)nid
{
    return [[SLStore sharedStore] find:[self class] byId:nid];
}

+ (PMKPromise *) findQuery:(NSDictionary *)query
{
    return [[SLStore sharedStore] find:[self class] withQuery:query];
}

+ (PMKPromise *) findAll
{
    return [[SLStore sharedStore] findAll:[self class]];
}

+ (PMKPromise *) findMany:(NSArray *)ids
{
    return [[SLStore sharedStore] findMany:[self class] withIds:ids];
}

+ (PMKPromise *) updateRecord:(NSDictionary *)properties
{
    return [[SLStore sharedStore] update:[self class] withData:properties];
}

- (instancetype) rollback
{
    return [[SLStore sharedStore] rollback:self];
}

- (PMKPromise *) deleteRecord
{
    return [[SLStore sharedStore] deleteRecord:self];
}

- (NSDictionary *) serialize:(NSDictionary *)options
{
    return [self.store serialize:self withOptions:options];
}

- (instancetype) setupData:(NSDictionary *)data
{
    // Attributes
    NSDictionary *attributes = [self attributesByName];
    for (NSString *key in attributes)
    {
        //        NSAttributeDescription *attr = [attributes objectForKey:key];
        //        NSLog(@"%@: %@", key, attr);
        //        NSAttributeType t = [attr attributeType];
        //NSLog(@"Attr Type %lu", (unsigned long)t);
        // Get Value
        id val = [data objectForKey:key];
        // Set value
        [self setValue:val forKey:key];
    }
    // TODO: Relationships
    NSDictionary *relationships = [[self class] relationshipsByName];
    for (NSString *key in relationships)
    {
        //        NSRelationshipDescription *rel = [relationships objectForKey:key];
        id val = [data objectForKey:key];
        [self setValue:val forKeyPath:key];
    }
    return self;
}

@end
