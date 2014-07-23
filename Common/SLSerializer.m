//
//  SLSerializer.m
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-17.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLSerializer.h"
#import "SLModel.h"

// Transforms
#import "SLObjectIdTransform.h"
#import "SLDateTransform.h"

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

- (NSArray *) extractArray:(Class)modelClass withPayload:(NSDictionary *)payload withStore:(SLStore *)store
{
    NSArray *results = payload[@"results"];
    NSMutableArray *extracted = [NSMutableArray array];
    for (NSDictionary *p in results)
    {
        NSDictionary *s = [self extractSingle:modelClass withPayload:p withStore:store];
        [extracted addObject:s];
    }
    return [NSArray arrayWithArray:extracted];
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
    SLNid nid = [SLObjectIdTransform deserialize:dId];
    // Save!
    [results setValue:nid forKey:@"nid"];
    // Remove the old field
    [results removeObjectForKey:@"_id"];
    // Done!
    return [NSDictionary dictionaryWithDictionary:results];
}

- (NSDictionary *)normalizeAttributes:(Class)modelClass withPayload:(NSDictionary *)payload
{
    NSLog(@"Payload: %@", payload);
    NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:payload];
    NSDictionary *attributes = [modelClass attributesByName];
    for (NSString *attributeKey in attributes)
    {
        NSAttributeDescription *attribute = attributes[attributeKey];
        
        // TODO: Handle renaming keys for attributes
        NSLog(@"attribute: %@", attribute);
        NSLog(@"attributeKey: %@", attributeKey);
        NSString *payloadKey = [modelClass keyForAttribute:attributeKey];
        NSLog(@"payloadKey: %@", payloadKey);
        if (![attributeKey isEqualToString:payloadKey])
        {
            // Attribute's Key is different
            // Rename it.
            id origVal = [payload objectForKey:payloadKey];
            if (origVal == nil)
            {
                continue;
            }
            // TODO: Handle different types of Attributes with Transforms
            NSAttributeType type = [attribute attributeType];
            //
            id val = origVal;
            switch (type)
            {
                case NSDateAttributeType:
                {
                    val = [SLDateTransform deserialize:origVal];
                }
                break;
            }
            NSLog(@"Val: %@", val);
            [results setValue:val forKey:attributeKey];
            [results removeObjectForKey:payloadKey];
        }
        
    }
    return [NSDictionary dictionaryWithDictionary:results];
}

- (NSDictionary *)normalizeRelationships:(Class)modelClass withPayload:(NSDictionary *)payload
{
    // TODO: Iterate thru relationships
    return payload;
}

@end
