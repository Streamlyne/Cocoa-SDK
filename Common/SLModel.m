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
    NSLog(@"SLModel init");
    NSManagedObjectContext *localContext = [SLStore sharedStore].context;
    self = [self initInContext:localContext];
    
    return self;
}

- (instancetype) initInContext:(NSManagedObjectContext *)context
{
    NSLog(@"SLModel init %@", [self class]);
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


+ (instancetype) initInContext:(NSManagedObjectContext *)context
{
    return [[self alloc] initInContext:context];
}

+ (instancetype) initWithId:(SLNid)nid {
    NSLog(@"SLModel initWithId: %@", nid);
    NSManagedObjectContext *localContext = [SLStore sharedStore].context;
    return [self initWithId:nid inContext:localContext];
}

+ (instancetype) initWithId:(SLNid)nid inContext:(NSManagedObjectContext *)context
{
    NSLog(@"SLModel initWithId: %@ inContext: %@", nid, context);
    
    @synchronized([self class])
    {
        __block SLModel *node;
        NSLog(@"initWithId, before find node");
        node = [[self class] MR_findFirstByAttribute:@"nid" withValue:nid inContext:context];
        NSLog(@"initWithId: %@, node: %@", nid, node);
        if (node == nil) {
            NSLog(@"Record does not exist! %@", nid);
            node = [[[self class] alloc] initInContext:context];
            node.nid = nid;
        }
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


+ (NSEntityDescription *) entity
{
    NSManagedObjectContext *localContext = [SLStore sharedStore].context;
    return [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:localContext];
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

+ (instancetype) createRecord
{
    return [self createRecord:@{}];
}

+ (instancetype) createRecord:(NSDictionary *)properties
{
    return [[SLStore sharedStore] createRecord:[self class] withProperties:properties];
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
#pragma mark - Should first flag as deleted in Core Data, then persist the deletion on save and delete from Core Data after successfuly deletion on server.
    return [[SLStore sharedStore] deleteRecord:self];
}

- (PMKPromise *) reloadRecord
{
    return [[self class] findById:self.nid];
}

- (NSDictionary *) serialize:(NSDictionary *)options
{
    return [self.store serialize:self withOptions:options];
}

- (PMKPromise *) save
{
    return [[SLStore sharedStore] saveRecord:self];
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

- (SLModel *) pushWithData:(NSDictionary *)datum
{
    return [[SLStore sharedStore] push:[self class] withData:datum];
}

+ (void) eachAttribute:(void(^)(NSString *key, NSAttributeDescription *attribute))callback
{
    NSDictionary *attributes = [self attributesByName];
    for (NSString *key in attributes)
    {
        NSAttributeDescription *attribute = [attributes objectForKey:key];
        callback(key, attribute);
    }
}

+ (void) eachRelationship:(void(^)(NSString *key, NSRelationshipDescription *relationship))callback
{
    
    NSDictionary *relationships = [self relationshipsByName];
    for (NSString *key in relationships)
    {
        NSRelationshipDescription *relationship = [relationships objectForKey:key];
        callback(key, relationship);
    }
}

@end
