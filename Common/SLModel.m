//
//  SLNode.m
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLModel.h"
#import "SLValue.h"
#import "SLRelationship.h"
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

+ (NSDictionary *) attributeMappings
{
    NSMutableDictionary *attrMap = [NSMutableDictionary dictionary];
    [attrMap setValue:@"dateCreated" forKey:@"date_created"];
    [attrMap setValue:@"dateUpdated" forKey:@"date_updated"];
    return [NSDictionary dictionaryWithDictionary: attrMap];
}

- (NSString *) attributeForKey:(NSString *)key
{
    NSDictionary *attributeMappings = [[self class] attributeMappings];
    NSString *attribute = nil;
    attribute = [attributeMappings objectForKey:key];
    if (attribute == nil) {
        return key;
    } else {
        return attribute;
    }
}

- (NSString *) keyForAttribute:(NSString *)attribute
{
    NSDictionary *attributeMappings = [[self class] attributeMappings];
    NSString *key = nil;
    for (NSString *k in attributeMappings)
    {
        if ([[attributeMappings objectForKey:k] isEqualToString:attribute]) {
            key = k; //
            break; // Stop looping
        }
    }
    if (key == nil) {
        return attribute;
    } else {
        return key;
    }
}

+ (NSArray *) pending
{
    NSArray *pendingNodes = [[self class] MR_findAllWithPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"NOT syncState == %@", @(SLSyncStateSynced)]]];
    return pendingNodes;
}

- (void) loadDataFromDictionary:(NSDictionary *)theData
{
    // For date conversion
    NSDateFormatter *iso8601Formatter = [[NSDateFormatter alloc] init];
    //[iso8601Formatter setDateStyle:NSDateFormatterLongStyle];
    //[iso8601Formatter setTimeStyle:NSDateFormatterShortStyle];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [iso8601Formatter setLocale:enUSPOSIXLocale];
    [iso8601Formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    // Load Data from NSDictionary
    NSLog(@"%@", theData);
    NSString *key = nil;
    for (key in theData)
    {
        id d = [theData objectForKey:key];
        if (d != [NSNull null]) {
            NSString *mKey = [self attributeForKey:key];
            NSDictionary *attributes = [[self entity] attributesByName];
            NSAttributeDescription *descriptionWithKey = [attributes objectForKey:mKey];
            // Parse
            if ([descriptionWithKey attributeType] == NSStringAttributeType) {
                d = d;//[NSString stringWithString:d];
            } else if ([descriptionWithKey attributeType] == NSInteger64AttributeType) {
                d = d;
            } else if ([descriptionWithKey attributeType] == NSDateAttributeType) {
                NSLog(@"date before: %@, %@", [d class], d);
                d = [iso8601Formatter dateFromString: d];
                NSLog(@"date after: %@", d);
            } else {
                NSLog(@"Unknown type.");
            }
            [self setValue:d forKey:mKey];
        }
        /*
         // NSLog(@"Update %@: %@", key, [theData objectForKey:key]);
         [self update:mKey value:[theData objectForKey:key]];
         // Mark data as saved.
         SLValue *val = [self.data objectForKey:key];
         [val setSaved]; // Mark as saved.
         */
    }
}

- (void) loadRelsFromArray:(NSArray *)theRels inContext:(NSManagedObjectContext *)context
{
    // Load Relationships from NSArray
    //NSLog(@"Rels: %@", theRels);
    for (NSDictionary *curr in theRels)
    {
        SLRelationship *rel;
        id otherNode = [[self class] initWithId:(SLNid) curr[@"id"] inContext:context];
        if ([curr[@"dir"] isEqual: @"in"])
        {
            rel = [[SLRelationship alloc] initWithName: curr[@"relsType"] withStartNode:otherNode withEndNode:self];
        } else //
        {
            rel = [[SLRelationship alloc] initWithName: curr[@"relsType"] withStartNode:self withEndNode:otherNode];
        }
        [rel setSaved];
        [self addRelationship:rel];
    }
}

+ (NSString *) type
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in the subclass %@.", NSStringFromSelector(_cmd), [self class]]
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

+ (PMKPromise *) readAllWithFilters:(NSDictionary *)filters withCallback:(void (^)(NSArray *))callback
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
            
            SLRequestCallback completionBlock = ^(NSError *error, id operation, id responseObject) {
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
                
            };
            
            [manager performRequestWithMethod:SLHTTPMethodGET withPath:[[self class] type] withParameters:filters]
            .then(completionBlock);
            
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
    SLRequestCallback completionBlock = ^(NSError *error, id operation, id responseObject) {
        NSLog(@"SLRequestCallback completionBlock!");
        NSLog(@"<%@>: %@", [responseObject class], responseObject);
        
        // TODO: Check if successful
        
        fulfiller(true);
    };
    
    NSString *thePath = [NSString stringWithFormat:@"%@/%@", [[self class] type],nid];
    NSLog(@"theDeletePath: %@", thePath);
    return [[[self class] sharedAPIManager] performRequestWithMethod:SLHTTPMethodDELETE withPath:thePath withParameters:nil];
}

+ (void) deleteWithNode:(SLModel *)node
{
    [[self class] deleteWithNode:node withCallback:nil];
}

+ (void) deleteWithNode:(SLModel *)node withCallback:(SLSuccessCallback)callback
{
    [[self class] deleteWithId:node.nid withCallback:^(BOOL success) {
        if (success)
        {
            node.nid = SLNidNodeNotCreated; // Remove
            callback(true);
        } else
        {
            callback(false);
        }
    }];
}

+ (void) deleteWithNodeArray:(NSArray *)nodes
{
    [[self class] deleteWithNodeArray:nodes withProgressCallback:nil withCallback:nil];
}

+ (void) deleteWithNodeArray:(NSArray *)nodes withCallback:(SLSuccessCallback)callback
{
    [[self class] deleteWithNodeArray:nodes withProgressCallback:nil withCallback:callback];
}

+ (void) deleteWithNodeArray:(NSArray *)nodes withProgressCallback:(void (^)(NSUInteger idx))progress withCallback:(SLSuccessCallback)callback {
    
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
    SLModel *node;
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

- (id) get:(NSString *)attr
{
    return [(SLValue *)[self.data objectForKey:attr] get];
}

- (void) update:(NSString *)attr value:(id)value
{
    [((SLValue *)[data objectForKey:attr]) set:value];
    _saved = NO;
}

- (void) save
{
    [self saveWithCallback:nil];
}

- (void) saveWithCallback:(SLSuccessCallback)callback
{
    NSLog(@"saveWithCallback DEPRECATED. Use pushWithAPIManager:withCallback: instead.");
    callback(false);
}

- (PMKPromise *) pushWithAPIManager:(SLAPIManager *)manager
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        
        
        //NSLog(@"pushWithAPIManager:withCallback:");
        
        NSLog(@"serializeData: %@", [self serializeData]);
        
        // Create serialized delta
        NSMutableDictionary *notSavedData = [NSMutableDictionary dictionary];
        /*
         NSString *key;
         for (key in data)
         {
         SLValue *val = [self.data objectForKey:key];
         // Check if already saved
         if (![val isSaved])
         {
         // Value is not already saved
         [notSavedData setObject:[val get] forKey:key];
         }
         }
         */
        notSavedData = [NSMutableDictionary dictionaryWithDictionary: [self serializeData]];
        
        //
        NSMutableArray *notSavedRels = [NSMutableArray array];
        SLRelationship* rel;
        for (rel in self.rels)
        {
            // Check if already saved
            if (![rel isSaved])
            {
                SLRelationshipDirection dir = [rel directionWithNode:self];
                NSLog(@"%@", rel);
                if (dir == SLRelationshipIncoming) {
                    SLModel *node = rel.startNode;
                    NSLog(@"%@", node);
                    if (node != nil && node.nid != nil) {
                        NSLog(@"%@, %@, %@, %@", node, node.nid, [rel.startNode type], rel.name);
                        [notSavedRels addObject:@{
                                                  @"id":node.nid,
                                                  @"dir":@"in",
                                                  @"nodeType": [rel.startNode type],
                                                  @"relsType": rel.name
                                                  }];
                    } else {
                        NSLog(@"Other node, %@, not yet pushed to server.", node);
                    }
                } else if (dir == SLRelationshipOutgoing) {
                    SLModel *node = rel.endNode;
                    if (node != nil && node.nid != nil) {
                        [notSavedRels addObject:@{
                                                  @"id":node.nid,
                                                  @"dir":@"out",
                                                  @"nodeType": [rel.endNode type],
                                                  @"relsType": rel.name
                                                  }];
                    } else {
                        NSLog(@"Other node, %@, not yet pushed to server.", node);
                    }
                } else {
                    // SLRelationshipNotFound
                    NSLog(@"SLRelationshipNotFound");
                    //[notSavedRels addObject:rel];
                    @throw SLExceptionImplementationNotFound;
                }
            }
            
        }
        
        NSLog(@"delta: %@, %@", notSavedData, notSavedRels);
        NSDictionary *delta = @{@"data": notSavedData, @"rels": notSavedRels};
        NSLog(@"Save data: %@", delta);
        
        // POST the CREATE/UPDATE
        SLRequestCallback completionBlock = ^(NSError *error, id operation, id responseObject) {
            NSLog(@"SLRequestCallback completionBlock!");
            NSLog(@"<%@>: %@", [responseObject class], responseObject);
            
            // TODO: Check if successful, then mark the successful data and relationship fields as `saved`
            if (error == nil)
            {
                NSDictionary *responseData = (NSDictionary *)responseObject;
                
                // Update the Node Id.
                [self setNid:responseData[@"id"]];
                [self setSyncState:@(SLSyncStateSynced)];
                
                // Mark all `SLValue`s as saved.
                NSString *key;
                for (key in self.data)
                {
                    SLValue *val = [self.data objectForKey:key];
                    [val setSaved]; // Mark as saved.
                }
                
                // Mark all `SLRelationship`s as saved.
                SLRelationship* rel;
                for (rel in self.rels)
                {
                    [rel setSaved];
                }
                // Mark Node as saved.
                _saved = YES;
                
                // Return
                fulfiller(nil);
                
            } else {
                rejecter(nil);
            }
        };
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
    SLRelationship* rel;
    for (rel in self.rels)
    {
        if ( ! [rel isSaved] ) {
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

- (void) didChangeValueForKey:(NSString *)key {
    NSLog(@"didChangeValueForKey %@", key);
    if (
        ( ![key isEqual: @"syncState"] ) &&
        [[self syncState] isEqual: @(SLSyncStateSynced)]
        ) {
        [self setSyncState:@(SLSyncStatePendingUpdate)];
    }
}

@end
