//
//  SLSerializer.m
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-17.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLSerializer.h"

// Transforms
#import "SLObjectIdTransform.h"

@interface SLSerializer ()
@property (nonatomic, retain) NSDictionary *registeredTransforms;
@end

@implementation SLSerializer

-(void)registerTransform:(SLTransform *)transform forClass:(Class)cls
{
    NSString *clsName = NSStringFromClass(cls);
    [self.registeredTransforms setValue:transform forKey:clsName];
}

- (NSDictionary *) serialize:(SLModel *)record withOptions:(NSDictionary *)options
{
    // Iterate through all attributes and use the correct Transform to serialize.
    return @{};
}

- (NSDictionary *)extractSingle:(Class)modelClass withPayload:(NSDictionary *)payload withStore:(SLStore *)store
{
    NSDictionary *results = [self normalize:modelClass withPayload:payload];
    return results;
}

- (NSDictionary *)normalize:(Class)modelClass withPayload:(NSDictionary *)payload
{
    NSDictionary *results = [self normalizeIdWithPayload:payload];
    results = [self normalizeAttributes:modelClass withPayload:results];
    results = [self normalizeRelationships:modelClass withPayload:results];
    return results;
}

- (NSDictionary *)normalizeIdWithPayload:(NSDictionary *)payload
{
    NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:payload];
    // Get Dictionary form ObjectId
    NSDictionary *dId = payload[@"_id"];
    // Convert to String Id
    SLNid nid = [[SLObjectIdTransform alloc] deserialize:dId];
    // Save!
    [results setValue:nid forKey:@"nid"];
    // Remove the old field
    [results removeObjectForKey:@"_id"];
    // Done!
    return [NSDictionary dictionaryWithDictionary:results];
}

- (NSDictionary *)normalizeAttributes:(Class)modelClass withPayload:(NSDictionary *)payload
{
    // TODO: Iterate thru attributes
    // TODO: Handle different types of Attributes with Transforms
    return payload;
}

- (NSDictionary *)normalizeRelationships:(Class)modelClass withPayload:(NSDictionary *)payload
{
    // TODO: Iterate thru relationships
    return payload;
}

@end
