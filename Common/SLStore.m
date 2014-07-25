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
@synthesize adapter;

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
    }
    return self;
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

- (SLModel *) push:(Class)modelClass withData:(NSDictionary *)datum
{
    //
    SLNid nid = (NSString *) datum[@"id"];
    SLModel *record = [self record:modelClass forId:nid];
    
    // TODO: Normalize Relationships from IDs into Records
    datum = [self normalizeRelationships:modelClass withData:datum withStore:self];
    
    //
    [record setupData:datum];
    
    return record;
}

- (SLModel *) record:(Class<SLModelProtocol>)modelClass forId:(SLNid)nid
{
    SLModel *record = [modelClass initWithId:nid];
    return record;
}

- (NSArray *) pushMany:(Class)modelClass withData:(NSArray *)data
{
    NSLog(@"pushMany <%@>: %@", modelClass, data);
    NSMutableArray *records = [NSMutableArray array];
    for (NSDictionary *datum in data) {
        [records addObject:[self push:modelClass withData:datum]];
    }
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
        // Has Many
        if (relationship.isToMany)
        {
            NSArray *ids = (NSArray *)origVal;
            NSArray *records = [self deserializeRecordIds:ids withRelationship:relationship withStore:store];
            val = [NSSet setWithArray:records];
        }
        // Belongs To / Has One
        else
        {
            SLNid nid = (SLNid)origVal;
            val = [self deserializeRecordId:nid withRelationship:relationship withStore:store];
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

@end
