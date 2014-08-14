//
//  SLStore.m
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-17.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLStore.h"
#import "SLObjectIdTransform.h"

@interface SLStore ()
@end

@implementation SLStore
@synthesize adapter, context;

static SLStore *sharedSingleton = nil;
+ (instancetype) sharedStore
{
    @synchronized([self class])
    {
        if (sharedSingleton == nil) {
            sharedSingleton = [[self alloc] init];
        }
        return sharedSingleton;
    }
}

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        // Adapter
        self.adapter = [SLAdapter sharedAdapter];
//        self.context = [NSManagedObjectContext MR_contextForCurrentThread];
        self.context = [NSManagedObjectContext MR_defaultContext];
    }
    return self;
}

- (SLModel *) createRecord:(Class<SLModelProtocol>)modelClass withProperties:(NSDictionary *)properties
{
    SLModel *record = [modelClass initInContext:self.context];
    [record setupData:properties];
    return record;
}

- (PMKPromise *) find:(Class)modelClass byId:(SLNid)nid
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        [self.adapter find:modelClass withId:nid withStore:self]
        .then(^(NSDictionary *adapterPayload) {
            // FIXME: Should used a shared Serializer, etc.
            SLSerializer *serializer = [[SLSerializer alloc] init];
            // Extract from Payload
            NSDictionary *extractedPayload = [serializer extractSingle:modelClass withPayload:adapterPayload withStore:self];
            SLModel *record = [self push:modelClass withData:extractedPayload];
            fulfiller(record);
        })
        .catch(rejecter);
    }];
}

- (PMKPromise *) findAll:(Class)modelClass
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        [self.adapter findAll:modelClass withStore:self]
        .then(^(NSDictionary *adapterPayload) {
            // FIXME: Should used a shared Serializer, etc.
            SLSerializer *serializer = [[SLSerializer alloc] init];
            // Extract from Payload
            NSArray *extractedPayload = [serializer extractArray:modelClass withPayload:adapterPayload withStore:self];
            NSArray *records = [self pushMany:modelClass withData:extractedPayload];
            fulfiller(records);
        })
        .catch(rejecter);
    }];
}

- (PMKPromise *) findMany:(Class)modelClass withIds:(NSArray *)ids
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        [self.adapter findMany:modelClass withIds:ids withStore:self]
        .then(^(NSDictionary *adapterPayload) {
            // FIXME: Should used a shared Serializer, etc.
            SLSerializer *serializer = [[SLSerializer alloc] init];
            // Extract from Payload
            NSArray *extractedPayload = [serializer extractArray:modelClass withPayload:adapterPayload withStore:self];
            NSArray *records = [self pushMany:modelClass withData:extractedPayload];
            fulfiller(records);
        })
        .catch(rejecter);
    }];
}

- (PMKPromise *) find:(Class)modelClass withQuery:(NSDictionary *)query;
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        [self.adapter findQuery:modelClass withQuery:query withStore:self]
        .then(^(NSDictionary *adapterPayload) {
            // FIXME: Should used a shared Serializer, etc.
            SLSerializer *serializer = [[SLSerializer alloc] init];
            // Extract from Payload
            NSArray *extractedPayload = [serializer extractArray:modelClass withPayload:adapterPayload withStore:self];
            NSArray *records = [self pushMany:modelClass withData:extractedPayload];
            fulfiller(records);
        })
        .catch(rejecter);
    }];
}

- (PMKPromise *)saveRecord:(SLModel *)record
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        
        // Check if already CREATED
        if (record.isInserted)
        {
            // Create record
            [self.adapter createRecord:record withStore:self]
            .then(fulfiller)
            .catch(rejecter);
        }
        // Check if should be deleted
        else if (record.isUpdated)
        {
            // Delete record
            [self.adapter deleteRecord:record withStore:self]
            .then(fulfiller)
            .catch(rejecter);
            
        } else {
            // UPDATE existing record
            [self.adapter updateRecord:record withStore:self]
            .then(fulfiller)
            .catch(rejecter);
        }
    }];
}

- (SLModel *) push:(Class)modelClass withData:(NSDictionary *)datum
{
    //
    SLNid nid = (NSString *) datum[@"nid"];
    SLModel *record;
    
    record = [self record:modelClass forId:nid withContext:self.context];
    
    datum = [self normalizeRelationships:modelClass withData:datum withStore:self];
    NSLog(@"post normalizeRelationships datum: %@", datum);
    
    //
    [record setupData:datum];
    NSLog(@"Pushed record: %@", record);
    
    return record;
}

- (SLModel *) record:(Class<SLModelProtocol>)modelClass forId:(SLNid)nid withContext:(NSManagedObjectContext *)localContext
{
    SLModel *record = [modelClass initWithId:nid inContext:localContext];
    return record;
}

- (NSArray *) pushMany:(Class)modelClass withData:(NSArray *)data
{
    NSLog(@"pushMany <%@>: %@", modelClass, data);
    NSMutableArray *records = [NSMutableArray array];
    for (NSDictionary *datum in data) {
        [records addObject:[self push:modelClass withData:datum]];
    }
    NSLog(@"pushed: %@", records);
    return [NSArray arrayWithArray:records];
}

- (NSDictionary *)normalizeRelationships:(Class)modelClass withData:(NSDictionary *)data withStore:(SLStore *)store
{
    
    NSLog(@"normalizeRelationships data: %@", data);
    NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:data];
    NSDictionary *relationships = [modelClass relationshipsByName];
    for (NSString *relationshipKey in relationships)
    {
        NSRelationshipDescription *relationship = relationships[relationshipKey];
        
        // TODO: Handle renaming keys for attributes
        NSLog(@"relationship: %@", relationship);
        NSLog(@"relationshipKey: %@", relationshipKey);
        NSString *payloadKey = [modelClass keyForAttribute:relationshipKey];
        NSLog(@"payloadKey: %@", payloadKey);
        id origVal = [data objectForKey:payloadKey];
        NSLog(@"OriginVal: %@", origVal);
        if (origVal == nil)
        {
            continue;
        }
        
        id val = origVal;
        Class<SLModelProtocol> relationshipModel = [self typeForRelationship:relationship];
        // Has Many
        if (relationship.isToMany)
        {
            NSArray *ids = (NSArray *)origVal;
            NSArray *records = [self deserializeRecordIds:ids withRelationship:relationship withStore:store];
            if (relationship.isOrdered)
            {
                val = [NSOrderedSet orderedSetWithArray:records];
            }
            else {
                val = [NSSet setWithArray:records];
            }
            // Load all of the records
            [self findMany:relationshipModel withIds:ids];
        }
        // Belongs To / Has One
        else
        {
            SLNid nid = (SLNid)origVal;
            val = [self deserializeRecordId:nid withRelationship:relationship withStore:store];
            // Load this record
            [self find:relationshipModel byId:nid];
        }
        [results setValue:val forKey:relationshipKey];
        
    }
    return [NSDictionary dictionaryWithDictionary:results];
    
}

- (SLModel *) deserializeRecordId:(SLNid)nid withRelationship:(NSRelationshipDescription *)relationship withStore:(SLStore *)store {
    
    Class<SLModelProtocol> modelClass = [self typeForRelationship:relationship];
    SLModel *record = [modelClass initWithId:nid];
    return record;
}

- (Class<SLModelProtocol>) typeForRelationship:(NSRelationshipDescription *)relationship {
    NSEntityDescription *entity = [relationship destinationEntity];
    Class<SLModelProtocol> destinationModelClass = NSClassFromString([entity managedObjectClassName]);
    return destinationModelClass;
}

- (Class<SLModelProtocol>) typeForRelationshipWithKey:(NSString *)key forModel:(Class<SLModelProtocol>)modelClass {
    NSDictionary *relationships = [modelClass relationshipsByName];
    NSRelationshipDescription *relationship = [relationships objectForKey:key];
    NSEntityDescription *entity = [relationship destinationEntity];
    Class<SLModelProtocol> destinationModelClass = NSClassFromString([entity managedObjectClassName]);
    return destinationModelClass;
}

- (NSArray *) deserializeRecordIds:(NSArray *)ids withRelationship:(NSRelationshipDescription *)relationship withStore:(SLStore *)store {
    NSMutableArray *arr = [NSMutableArray array];
    for (SLNid nid in ids)
    {
        id v = [self deserializeRecordId:nid withRelationship:relationship withStore:store];
        [arr addObject:v];
    }
    return [NSArray arrayWithArray:arr];
}

- (NSDictionary *) serialize:(SLModel *)record withOptions:(NSDictionary *) options
{
    return [self.adapter serialize:record withOptions:options];
}

@end
