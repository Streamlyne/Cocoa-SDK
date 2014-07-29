//
//  SLAttribute.m
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-23.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLAttribute.h"


@implementation SLAttribute

@dynamic name;
@dynamic parameters;
@dynamic assetName;
@dynamic desc;


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

@end
