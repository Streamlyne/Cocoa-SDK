//
//  SLNode.m
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLModel.h"
#import "SLAPIManager.h"

@implementation SLModel

@dynamic nid;
@dynamic dateCreated;
@dynamic dateUpdated;

@synthesize saved = _saved;
@synthesize data, rels;

+ (SLAPIManager *) sharedAPIManager DEPRECATED_ATTRIBUTE
{
    @synchronized([self class]) {
        return [SLAPIManager sharedManager];
    }
}

- (instancetype) init {
    self = [self initInContext:[NSManagedObjectContext MR_defaultContext]];
    return self;
}

- (instancetype) initInContext:(NSManagedObjectContext *)context
{
    NSLog(@"init %@", [self class]);
    
    //self = [super init];
    //self = [[self class] MR_createEntity];
    self = [[self class] MR_createInContext:context];
    if (self) {
        // Initialize variables
        _saved = false;
        self.nid = SLNidNodeNotCreated;
        self.data = [NSDictionary dictionary];
        self.rels = [NSMutableArray array];
        
        // Edit data schema
        NSMutableDictionary *tempData = [self.data mutableCopy];
        //SLValue *idVal = [[SLValue alloc]initWithType:[NSString class]];
        //[tempData setValue:idVal forKey:@"id"];
        self.data = tempData;
        
        /*
         // Edit data mapping
         NSMutableDictionary *tempDataMapping = [self.dataMapping mutableCopy];
         [tempDataMapping setObject:@{ @"class": @"NSNumber", @"key": @"nid" } forKey:@"nid"];
         self.dataMapping = tempDataMapping;
         */
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

- (NSString *) keyForAttribute:(NSString *)attribute
{
    if ([attribute isEqualToString:@"dateCreated"])
    {
        return @"date_created";
    }
    else if ([attribute isEqualToString:@"dateUpdated"])
    {
        return @"date_created";
    }
    return attribute;
}

- (NSString *) keyForRelationship:(NSString *)relationship {
    return relationship;
}

+ (NSArray *) pending
{
    NSArray *pendingNodes = [[self class] MR_findAllWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"NOT syncState == %@", @(SLSyncStateSynced)]]];
    return pendingNodes;
}


+ (NSString *) type
{
    // return NSStringFromClass([instance class]);
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
        
        SLAPIManager *manager = [[self class] sharedAPIManager];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *context) {
            
            SLRequestCallback completionBlock = ^(NSError *error, id operation, id responseObject) {
                //NSLog(@"SLRequestCallback completionBlock!");
                //NSLog(@"<%@>: %@", [responseObject class], responseObject);
                
                // Process & Read Node
                SLModel *node = [[self class] initWithId:(SLNid) responseObject[@"id"] inContext:context];
                node.syncState = @(SLSyncStateSynced);
                [((SLModel *)node) loadDataFromDictionary: responseObject[@"data"]];
                [((SLModel *)node) loadRelsFromArray: responseObject[@"rels"] inContext:context];
                
                // Return
                // callback(node); // Returning in completion block now.
                [context MR_saveToPersistentStoreAndWait];
            };
            
            NSString *thePath = [NSString stringWithFormat:@"%@/%@", [[self class] type],nid];
            [manager performRequestWithMethod:SLHTTPMethodGET withPath:thePath withParameters:filters]
            .then(completionBlock);
            
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
    SLAPIManager *manager = [[self class] sharedAPIManager];
    NSLog(@"Manager: %@", manager);
    return [self readAllWithAPIManager:manager withFilters:filters];
}

+ (PMKPromise *) readAllWithAPIManager:(SLAPIManager *)manager withFilters:(NSDictionary *)filters
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
                    SLModel *node = [[self class] initWithId:(SLNid) curr[@"id"] inContext:context];
                    node.syncState = @(SLSyncStateSynced);
                    [((SLModel *)node) loadDataFromDictionary: curr[@"data"]];
                    [((SLModel *)node) loadRelsFromArray: curr[@"rels"] inContext:context];
                    
                    [nodes addObject: node];
                    NSLog(@"Node: %@",node);
                    
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
    NSLog(@"this is a test");
    
    SLModel *node = [[[self class] alloc] init];
    node.syncState = @(SLSyncStatePendingCreation);
    
    // TODO: Fix this so it validates data and rels first
    // Data
    [node loadDataFromDictionary:theData];
    /*
     NSString *key = nil;
     for (key in theData)
     {
     NSLog(@"Update %@: %@", key, [theData objectForKey:key]);
     [node update:key value:[theData objectForKey:key]];
     [node setValue:[theData objectForKey:key] forKey:key];
     }
     */
    // FIXME: This is deprecated. Switch to Core Data
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
        [[[self class] sharedAPIManager] performRequestWithMethod:SLHTTPMethodDELETE withPath:thePath withParameters:nil].then(completionBlock);
        
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

- (NSArray *) relationships
{
    return self.rels;
}

- (BOOL) addRelationship:(SLRelationship *)theRel
{
    // Validate relationship
    if ( (theRel.startNode == self) || (theRel.endNode == self) ) {
        
        // Check if already exists
        // This will eventually contain the index of the object.
        // Initialize it to NSNotFound so you can check the results after the block has run.
        __block NSInteger foundIndex = NSNotFound;
        
        [self.rels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[SLRelationship class]]) {
                foundIndex = idx;
                // stop the enumeration
                *stop = YES;
            }
        }];
        
        if (foundIndex != NSNotFound) {
            // You've found the first object of that class in the array
        } else {
            [self.rels addObject:theRel];
        }
        return true;
    } else {
        return false;
    }
}

- (void) save
{
    [self saveWithCallback:nil];
}

- (PMKPromise *) pushWithAPIManager:(SLAPIManager *)manager
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
            thePath = [NSString stringWithFormat:@"%@/%@", [[self class] type],self.nid];
        }
        NSLog(@"Save Path: %@", thePath);
        NSLog(@"Manager: %@", manager);
        [manager performRequestWithMethod:SLHTTPMethodPOST withPath:thePath withParameters:delta].then(completionBlock);
        
    }];
}

- (NSDictionary *) serializeData {
    NSMutableDictionary *theData = [NSMutableDictionary dictionary];
    NSEntityDescription *entityDescription = [self entity];
    NSDictionary *attributes = [entityDescription attributesByName];
    //NSLog(@"%@", attributes);
    for (NSAttributeDescription *attribute in attributes) {
        //NSLog(@"attribute: %@ = %@", attribute, [self valueForKey:(NSString *)attribute]);
        if ( ![attribute isEqual:@"syncState"] ) {
            [theData setValue:[self valueForKey:(NSString *)attribute] forKey:[self keyForAttribute:(NSString *)attribute]];
        }
    }
    return [NSDictionary dictionaryWithDictionary:theData];
}


- (PMKPromise *) remove
{
    return [[self class] deleteWithNode:self];
}

- (void) didChangeValueForKey:(NSString *)key {
    NSLog(@"didChangeValueForKey %@", key);
    if (
        ( ![key isEqual: @"syncState"] ) &&
        [[self syncState] isEqual: @(SLSyncStateSynced)]
        ) {
        [self setSyncState:@(SLSyncStatePendingUpdate)];
    }
}

- (NSDictionary *) serialize
{
    
}

@end
