//
//  SLStore.m
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-17.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLStore.h"

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

- (SLModel *) push:(Class)modelClass withData:(NSDictionary *)datum
{
    //
    SLNid nid = (NSString *) datum[@"id"];
    SLModel *record = [self record:modelClass forId:nid];
    
    // TODO: Normalize Relationships from IDs into Records
    
    //
    [record setupData:datum];
    
    return record;
}

- (SLModel *) record:(Class)modelClass forId:(SLNid)nid
{
    // FIXME: find the record if it already exists
    SLModel *record = [[modelClass alloc] init];
    
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

@end
