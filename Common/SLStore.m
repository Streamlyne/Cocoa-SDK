//
//  SLStore.m
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-17.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLStore.h"
#import "SLObjectIdTransform.h"
#import "CoreData+MagicalRecord.h"
#import <PromiseKit/Promise+When.h>

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

- (PMKPromise *) createRecord:(Class<SLModelProtocol>)modelClass withProperties:(NSDictionary *)properties
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        
        __block SLModel *record;
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            record = (SLModel *)[modelClass MR_createInContext:localContext];
            [record setupData:properties];
            [localContext MR_saveToPersistentStoreAndWait];
            record = [record MR_inContext:self.context];
            //            [self.context MR_saveToPersistentStoreAndWait];
        } completion:^(BOOL success, NSError *error) {
            NSLog(@"%hhd %@ %@", success, error, record);
            if (error) {
                rejecter(error);
            } else {
                fulfiller(record);
            }
        }];
    }];
}

- (PMKPromise *) record:(Class<SLModelProtocol>)modelClass forId:(SLNid)nid
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        
        __block SLModel *record;
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            
            NSLog(@"record:forId:, before find node");
            record = [modelClass MR_findFirstByAttribute:@"nid" withValue:nid inContext:localContext];
            NSLog(@"record:forId: %@, node: %@", nid, record);
            if (record == nil) {
                NSLog(@"Record does not exist! %@", nid);
                record = (SLModel *)[modelClass MR_createInContext:localContext];
                record.nid = nid;
            }
            [localContext MR_saveToPersistentStoreAndWait];
            record = [record MR_inContext:self.context];
            //            [self.context MR_saveToPersistentStoreAndWait];
        } completion:^(BOOL success, NSError *error) {
            NSLog(@"%hhd %@ %@", success, error, record);
            if (error) {
                rejecter(error);
            } else {
                fulfiller(record);
            }
        }];
        
    }];
}


- (PMKPromise *) find:(Class)modelClass byId:(SLNid)nid
{
    id q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self.adapter find:modelClass withId:nid withStore:self]
    .thenOn(q, ^(NSDictionary *adapterPayload) {
        // FIXME: Should used a shared Serializer, etc.
        SLSerializer *serializer = [[SLSerializer alloc] init];
        // Extract from Payload
        NSArray *extractedPayload = [serializer extractArray:modelClass withPayload:adapterPayload withStore:self];
        return [self pushMany:modelClass withData:extractedPayload];
    });
}

- (PMKPromise *) findAll:(Class)modelClass
{
    id q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self.adapter findAll:modelClass withStore:self]
    .thenOn(q, ^(NSDictionary *adapterPayload) {
        // FIXME: Should used a shared Serializer, etc.
        SLSerializer *serializer = [[SLSerializer alloc] init];
        // Extract from Payload
        NSArray *extractedPayload = [serializer extractArray:modelClass withPayload:adapterPayload withStore:self];
        return [self pushMany:modelClass withData:extractedPayload];
    });
}

- (PMKPromise *) findMany:(Class)modelClass withIds:(NSArray *)ids
{
    id q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self.adapter findMany:modelClass withIds:ids withStore:self]
    .thenOn(q, ^(NSDictionary *adapterPayload) {
        // FIXME: Should used a shared Serializer, etc.
        SLSerializer *serializer = [[SLSerializer alloc] init];
        // Extract from Payload
        NSArray *extractedPayload = [serializer extractArray:modelClass withPayload:adapterPayload withStore:self];
        return [self pushMany:modelClass withData:extractedPayload];
    });
}

- (PMKPromise *) find:(Class)modelClass withQuery:(NSDictionary *)query;
{
    id q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    return [self.adapter findQuery:modelClass withQuery:query withStore:self]
    .thenOn(q, ^(NSDictionary *adapterPayload) {
        // FIXME: Should used a shared Serializer, etc.
        SLSerializer *serializer = [[SLSerializer alloc] init];
        // Extract from Payload
        NSArray *extractedPayload = [serializer extractArray:modelClass withPayload:adapterPayload withStore:self];
        return [self pushMany:modelClass withData:extractedPayload];
    });
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

- (PMKPromise *) push:(Class)modelClass withData:(NSDictionary *)datum
{
    NSLog(@"push: %@",datum);
    SLNid nid = (NSString *) datum[@"nid"];
    
    return [PMKPromise when:@[
                              [self record:modelClass forId:nid],
                              [self normalizeRelationships:modelClass withData:datum withStore:self]
                              ]
            ]
    .then(^(NSArray *results) {
        
        SLModel *record = results[0];
        NSDictionary *newDatum = results[1];
        NSLog(@"record: %@", record);
        NSLog(@"post normalizeRelationships datum: %@", newDatum);
        
        //
        [record setupData:newDatum];
        NSLog(@"Pushed record: %@", record);
        
        return record;
    });
}

- (PMKPromise *) pushMany:(Class)modelClass withData:(NSArray *)data
{
    NSLog(@"pushMany <%@>: %@", modelClass, data);
    NSMutableArray *records = [NSMutableArray array];
    for (NSDictionary *datum in data) {
        [records addObject:[self push:modelClass withData:datum]];
    }
    return [PMKPromise when:records];
}

- (PMKPromise *)normalizeRelationships:(Class)modelClass withData:(NSDictionary *)data withStore:(SLStore *)store
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        NSLog(@"normalizeRelationships data: %@", data);
        NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:data];
        NSDictionary *relationships = [modelClass relationshipsByName];
        NSMutableArray *relationshipPromises = [NSMutableArray array];
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
            
            Class<SLModelProtocol> relationshipModel = [self typeForRelationship:relationship];
            // Has Many
            if (relationship.isToMany)
            {
                NSArray *ids = (NSArray *)origVal;
                PMKPromise *relPromise = [self deserializeRecordIds:ids withRelationship:relationship withStore:store];
                [relationshipPromises addObject:relPromise];
                relPromise
                .then(^(NSArray *records) {
                    id val;
                    if (relationship.isOrdered)
                    {
                        val = [NSOrderedSet orderedSetWithArray:records];
                    }
                    else {
                        val = [NSSet setWithArray:records];
                    }
                    NSLog(@"rel val: %@", val),
                    [results setValue:val forKey:relationshipKey];
                    // Load all of the records
                    [self findMany:relationshipModel withIds:ids];
                })
                .catch(rejecter);
            }
            // Belongs To / Has One
            else
            {
                SLNid nid = (SLNid)origVal;
                PMKPromise *relPromise = [self deserializeRecordId:nid withRelationship:relationship withStore:store];
                [relationshipPromises addObject:relPromise];
                relPromise
                .then(^(SLModel *val) {
                    [results setValue:val forKey:relationshipKey];
                    // Load this record
                    [self find:relationshipModel byId:nid];
                })
                .catch(rejecter);
            }
        }
        [PMKPromise when:relationshipPromises]
        .then(^() {
            fulfiller([NSDictionary dictionaryWithDictionary:results]);
        })
        .catch(rejecter);
        
    }];
    
}

- (PMKPromise *) deserializeRecordId:(SLNid)nid withRelationship:(NSRelationshipDescription *)relationship withStore:(SLStore *)store {
    NSLog(@"deserializeRecordId");
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        Class<SLModelProtocol> modelClass = [self typeForRelationship:relationship];
        PMKPromise *recordPromise = [self record:modelClass forId:nid];
        recordPromise
        .then(^(SLModel *record) {
            fulfiller(record);
        })
        .catch(rejecter);
    }];
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

- (PMKPromise *) deserializeRecordIds:(NSArray *)ids withRelationship:(NSRelationshipDescription *)relationship withStore:(SLStore *)store {
    NSMutableArray *arr = [NSMutableArray array];
    for (SLNid nid in ids)
    {
        id v = [self deserializeRecordId:nid withRelationship:relationship withStore:store];
        [arr addObject:v];
    }
    return [PMKPromise when:arr];
}

- (NSDictionary *) serialize:(SLModel *)record withOptions:(NSDictionary *) options
{
    return [self.adapter serialize:record withOptions:options];
}

@end
