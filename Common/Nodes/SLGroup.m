//
//  SLGroup.m
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 11/25/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLGroup.h"

@implementation SLGroup

@dynamic desc;
@dynamic name;

+(NSString *) type
{
    return @"group";
}

+ (NSDictionary *) attributeMappings
{
    NSMutableDictionary *attrMap = [NSMutableDictionary dictionaryWithDictionary:[[[self superclass] class] attributeMappings]];
    [attrMap setValue:@"name" forKey:@"name"];
    [attrMap setValue:@"desc" forKey:@"description"];
    return [NSDictionary dictionaryWithDictionary: attrMap];
}

@end
