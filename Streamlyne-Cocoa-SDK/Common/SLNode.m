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
@dynamic nid;
@synthesize data, rels, dataMapping;

+ (SLAPIManager *) sharedAPIManager
{
    @synchronized([self class]) {
        return [SLAPIManager sharedManager];
    }
}

- (id) init
{
    NSLog(@"init %@", [self class]);
    
    //self = [super init];
    self = [[self class] MR_createEntity];
    if (self) {
        // Initialize variables
        _saved = false;
        self.nid = SLNidNodeNotCreated;
        self.data = [NSDictionary dictionary];
        self.dataMapping = [NSDictionary dictionary];
        self.rels = [SLRelationshipArray array];
        
        // Edit data schema
        NSMutableDictionary *tempData = [self.data mutableCopy];
        //SLValue *idVal = [[SLValue alloc]initWithType:[NSString class]];
        //[tempData setValue:idVal forKey:@"id"];
        self.data = tempData;
        
        // Edit data mapping
        NSMutableDictionary *tempDataMapping = [self.dataMapping mutableCopy];
        [tempDataMapping setObject:@{ @"class": @"NSNumber", @"key": @"nid" } forKey:@"nid"];
        self.dataMapping = tempDataMapping;

    }

    return self;
}

+ (instancetype) initWithId:(SLNid)nid
{
    @synchronized([self class])
    {
        SLNode *node = [[self class] MR_findFirstByAttribute:@"nid" withValue:nid];
        NSLog(@"initWithId: %@, node: %@", nid, node);
        if (node == nil) {
            node = [[[self class] alloc] init];
            node.nid = nid;
        }
        return node;
    }
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
        //
        NSDictionary *m = (NSDictionary *)[self.dataMapping objectForKey:key];
        NSString *mKey = (NSString *)[m objectForKey:@"key"];
        NSString *c = (NSString *)[m objectForKey:@"class"];
        if (mKey == nil) {
            mKey = key;
        }
        id d = [theData objectForKey:key];
        if (d != [NSNull null]) {
            // Parse
            NSLog(@"%@: %@", mKey, c);
            if ([c  isEqualToString: @"NSString"]) {
                d = d;//[NSString stringWithString:d];
            } else if ([c isEqualToString: @"NSNumber"]) {
                d = d;
            } else if ([c isEqualToString: @"NSDate"]) {
                NSLog(@"date before: %@, %@", [d class], d);
                d = [iso8601Formatter dateFromString: d];
                NSLog(@"date after: %@", d);
            } else {
                NSLog(@"Unknown type.");
            }
            NSLog(@"%@", d);
            [self setValue:d forKey:mKey];
        }
        
        // NSLog(@"Update %@: %@", key, [theData objectForKey:key]);
        [self update:key value:[theData objectForKey:key]];
        // Mark data as saved.
        SLValue *val = [self.data objectForKey:key];
        [val setSaved]; // Mark as saved.
        
    }
}

- (void) loadRelsFromArray:(NSArray *)theRels
{
    // Load Relationships from NSArray
    //NSLog(@"Rels: %@", theRels);
    for (NSDictionary *curr in theRels)
    {
        SLRelationship *rel;
        id otherNode = [[self class] initWithId:(SLNid) curr[@"id"]];
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

+ (void) readById:(SLNid)nid withCallback:(void (^)(SLNode *))callback
{
    NSDictionary *filters = @{
                              @"filter":@{
                                      @"fields": [NSNumber numberWithBool: FALSE],
                                      @"rels": [NSNumber numberWithBool: FALSE]
                                      }
                              };
    [self readById:nid withFilters:filters withCallback:callback];
}

+ (void) readById:(SLNid)nid withFilters:(NSDictionary *)filters withCallback:(void (^)(SLNode *))callback
{
    SLRequestCallback completionBlock = ^(NSError *error, id operation, id responseObject) {
        //NSLog(@"SLRequestCallback completionBlock!");
        //NSLog(@"<%@>: %@", [responseObject class], responseObject);
        
        // Process & Read Node
        id<SLNodeProtocol> node = [[self class] initWithId:(SLNid) responseObject[@"id"]];
        [((SLNode *)node) loadDataFromDictionary: responseObject[@"data"]];
        [((SLNode *)node) loadRelsFromArray: responseObject[@"rels"]];
        
        // Return
        callback(node);
    };
    
    NSString *thePath = [NSString stringWithFormat:@"%@/%@", [[self class] type],nid];
    [[[self class] sharedAPIManager] performRequestWithMethod:SLHTTPMethodGET withPath:thePath withParameters:filters withCallback:completionBlock];
    
}

+ (void) readAllWithCallback:(void (^)(SLNodeArray *))callback
{
    NSDictionary *filters = @{
                              @"filter":@{
                                      @"fields": [NSNumber numberWithBool: FALSE],
                                      @"rels": [NSNumber numberWithBool: FALSE]
                                      }
                              };
    [self readAllWithFilters:filters withCallback:callback];
}

+ (void) readAllWithFilters:(NSDictionary *)filters withCallback:(void (^)(SLNodeArray *))callback
{
    SLRequestCallback completionBlock = ^(NSError *error, id operation, id responseObject) {
        //NSLog(@"SLRequestCallback completionBlock!");
        //NSLog(@"<%@>: %@", [responseObject class], responseObject);
        SLNodeArray *nodes = [SLNodeArray array];
        NSArray *arr = ((NSDictionary *)responseObject)[@"nodes"];
        for (NSDictionary* curr in arr)
        {
            
            id<SLNodeProtocol> node = [[self class] initWithId:(SLNid) curr[@"id"]];
            [((SLNode *)node) loadDataFromDictionary: curr[@"data"]];
            [((SLNode *)node) loadRelsFromArray: curr[@"rels"]];
            
            [nodes addObject: node];
            
        }
        callback(nodes);
    };
    
    [[[self class] sharedAPIManager] performRequestWithMethod:SLHTTPMethodGET withPath:[[self class] type] withParameters:filters withCallback:completionBlock];
    
}

+ (instancetype) createWithData:(NSDictionary *)theData withRels:(SLRelationshipArray *)theRels
{
    NSLog(@"this is a test");
    
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
    [[[self class] sharedAPIManager] performRequestWithMethod:SLHTTPMethodDELETE withPath:thePath withParameters:nil withCallback:completionBlock];
    
}

+ (void) deleteWithNode:(SLNode *)node
{
    [[self class] deleteWithNode:node withCallback:nil];
}

+ (void) deleteWithNode:(SLNode *)node withCallback:(SLSuccessCallback)callback
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

- (SLRelationshipArray *) relationships
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

- (void) pushWithAPIManager:(SLAPIManager *)manager withCallback:(SLSuccessCallback)callback
{
    //NSLog(@"pushWithAPIManager:withCallback:");
    
    // Create serialized delta
    NSMutableDictionary *notSavedData = [NSMutableDictionary dictionary];
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
                SLNode *node = rel.startNode;
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
                SLNode *node = rel.endNode;
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
            callback(true);
            
        } else {
            callback(false);
        }
    };
    //
    NSString *thePath;
    if (self.nid == SLNidNodeNotCreated)
    {
        // New
        thePath = [NSString stringWithFormat:@"%@", [[self class] type]];
    } else
    {
        // Update
        thePath = [NSString stringWithFormat:@"%@/%@", [[self class] type],self.nid];
    }
    NSLog(@"Save Path: %@", thePath);
    
    [manager performRequestWithMethod:SLHTTPMethodPOST withPath:thePath withParameters:delta withCallback:completionBlock];
    
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

@end
