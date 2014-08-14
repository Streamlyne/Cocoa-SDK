//
//  SLAttribute.m
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-23.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLAttribute.h"
#import "SLStore.h"
#import "SLObjectIdTransform.h"
#import "SLAsset.h"

@implementation SLAttribute

@dynamic name;
@dynamic parameters;
@dynamic assetName;
@dynamic desc;
@dynamic humanName;

+ (NSString *) type
{
    return @"attributes";
}

+ (NSString *) keyForAttribute:(NSString *)attribute
{
    attribute = [super keyForAttribute:attribute];
    
    if ([attribute isEqualToString:@"desc"])
    {
        return @"description";
    }
    return attribute;
}

- (PMKPromise *) asset
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfiller, PMKPromiseRejecter rejecter) {
        // Build request
        NSDictionary *oid = [SLObjectIdTransform serialize:self.nid];
        NSDictionary *query = @{@"criteria": @{@"attributes": oid}, @"limit": @1};
        // Send request
        [[SLStore sharedStore] find:[SLAsset class] withQuery:query]
        .then(^(NSArray *assets) {
            NSLog(@"Assets: %@", assets);
            if ([assets count] > 0)
            {
                return fulfiller([assets objectAtIndex:0]);
            } else
            {
                return fulfiller(nil);
            }
        })
        .catch(rejecter);
    }];
}

@end
