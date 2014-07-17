//
//  SLObjectIdTransform.m
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-17.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLObjectIdTransform.h"

@implementation SLObjectIdTransform

- (NSDictionary *)serialize:(NSString *)deserialized
{
    return @{
             @"$oid": deserialized
            };
}

- (NSString *)deserialize:(NSDictionary *)serialized
{
    return serialized[@"$oid"];
}

@end
