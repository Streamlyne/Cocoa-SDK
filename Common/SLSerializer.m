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

//-(void)registerTransform:(Class<SLTransformProtocol> *)transform forClass:(Class)cls
//{
//    NSString *clsName = NSStringFromClass(cls);
//    [self.registeredTransforms setValue:transform forKey:clsName];
//}

-(Class<SLTransformProtocol>)transformForAttributeType:(NSAttributeType)type
{
    switch (type)
    {
        case NSDateAttributeType:
        {
            return [SLDateTransform class];
        }
            break;
        default:
            return nil;
    }
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
//    NSMutableDictionary *results = [NSMutableDictionary dictionary];
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
    //    NSLog(@"normalizeAttributes Payload: %@", payload);
//    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:payload];
    NSDictionary *attributes = [modelClass attributesByName];
    for (NSString *attributeKey in attributes)
    {
        NSAttributeDescription *attribute = attributes[attributeKey];
        
        // TODO: Handle renaming keys for attributes
        //NSLog(@"attribute: %@", attribute);
        //NSLog(@"attributeKey: %@", attributeKey);
        NSString *payloadKey = [modelClass keyForAttribute:attributeKey];
        //NSLog(@"payloadKey: %@", payloadKey);
        if (![attributeKey isEqualToString:payloadKey])
        {
            // Attribute's Key is different
            // Rename it.
            id origVal = [payload objectForKey:payloadKey];
            if (origVal == nil)
            {
                continue;
            }
            NSAttributeType type = [attribute attributeType];
            //
            id val = origVal;
            Class<SLTransformProtocol> transform = [self transformForAttributeType:type];
            if (transform != nil)
            {
                val = [transform deserialize:origVal];
            }
            //NSLog(@"Val: %@", val);
            [results setValue:val forKey:attributeKey];
            [results removeObjectForKey:payloadKey];
        }
        
    }
    return [NSDictionary dictionaryWithDictionary:results];
}



- (NSDictionary *)normalizeRelationships:(Class)modelClass withPayload:(NSDictionary *)payload
{
    NSLog(@"normalizeRelationships Payload: %@", payload);
    NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:payload];
    NSDictionary *relationships = [modelClass relationshipsByName];
    for (NSString *relationshipKey in relationships)
    {
        NSRelationshipDescription *relationship = relationships[relationshipKey];
        
        // TODO: Handle renaming keys for attributes
        NSLog(@"relationship: %@", relationship);
        NSLog(@"relationshipKey: %@", relationshipKey);
        NSString *payloadKey = [modelClass keyForAttribute:relationshipKey];
        NSLog(@"payloadKey: %@", payloadKey);
        id origVal = [payload objectForKey:payloadKey];
        if (origVal == nil)
        {
            continue;
        }
        //
        id val = origVal;
        NSLog(@"OriginVal: %@", val);
        if ([relationship isToMany])
        {
            // Has Many
            NSLog(@"Has Many");
            NSMutableArray *r = [NSMutableArray array];
            for (NSDictionary *i in (NSArray *)origVal )
            {
                SLNid j = [SLObjectIdTransform deserialize:(NSDictionary *)i];
                NSLog(@"i: %@, j: %@", i, j);
                [r addObject:j];
            }
            val = [NSArray arrayWithArray:r];
        }
        else
        {
            // Belongs-To / Has-One
            NSLog(@"Belongs To / Has One");
            SLNid nid = [SLObjectIdTransform deserialize:(NSDictionary *)origVal];
            val = nid;
        }
        NSLog(@"Val: %@", val);
        [results setValue:val forKey:relationshipKey];
        if (![relationshipKey isEqualToString:payloadKey])
        {
            // Attribute's Key is different
            // Rename it.
            [results removeObjectForKey:payloadKey];
        }
    }
    return [NSDictionary dictionaryWithDictionary:results];
}


- (NSDictionary *) serialize:(SLModel *)record withOptions:(NSDictionary *)options
{
    __block NSDictionary *serialized = [NSDictionary dictionary];
    
    // TODO: Implement option, `excludeId`.
    
    Class<SLModelProtocol> modelClass = [record class];
    
    // Attributes
    NSArray *excludedAttributeKeys = @[@"syncState", @"nid"];
    // Iterate through all attributes and use the correct Transform to serialize.
    [modelClass eachAttribute:^(NSString *key, NSAttributeDescription *attribute) {
        // Check if should be exlcuded
        if ([excludedAttributeKeys containsObject:key]) {
            return; // Ignore this
        }
        // Continue serializing this attribute
        serialized = [self serializeAttribute:record withKey:key withData:serialized];
    }];
    
    // Relationships
    [modelClass eachRelationship:^(NSString *key, NSRelationshipDescription *relationship) {
        if ([relationship isToMany]) {
            serialized = [self serializeHasMany:record withKey:key withData:serialized];
        } else {
            serialized = [self serializeBelongsTo:record withKey:key withData:serialized];
        }
    }];
    
    return serialized;
}

- (NSDictionary *) serializeAttribute:(SLModel *)record withKey:(NSString *)key withData:(NSDictionary *)data
{
    NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:data];
    
    Class<SLModelProtocol> modelClass = [record class];
    NSDictionary *attributes = [modelClass attributesByName];
    NSAttributeDescription *attribute = attributes[key];
    NSAttributeType type = [attribute attributeType];
    NSString *payloadKey = [modelClass keyForAttribute:key];
    id origVal = [record valueForKeyPath:key];
    Class<SLTransformProtocol> transform = [self transformForAttributeType:type];
    id val = origVal;
    // Transform, if available.
    if (transform != nil)
    {
        val = [transform serialize:origVal];
    }
    // Replace all nil with null, which is allowed in Dictionarys.
    if (val == nil)
    {
        val = [NSNull null];
    }
    [results setObject:val forKey:payloadKey];
    //
    return [NSDictionary dictionaryWithDictionary:results];
}

- (NSDictionary *) serializeBelongsTo:(SLModel *)record withKey:(NSString *)key withData:(NSDictionary *)data
{
    return data;
}

- (NSDictionary *) serializeHasMany:(SLModel *)record withKey:(NSString *)key withData:(NSDictionary *)data
{
    return data;
}



@end
