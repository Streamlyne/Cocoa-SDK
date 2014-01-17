//
//  SLOrganization.m
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/22/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLOrganization.h"

@implementation SLOrganization

@dynamic name;

+ (NSString *) type
{
    return @"organization";
}

+ (NSDictionary *) attributeMappings
{
    NSMutableDictionary *attrMap = [NSMutableDictionary dictionaryWithDictionary:[[[self superclass] class] attributeMappings]];
    [attrMap setValue:@"name" forKey:@"name"];
    return [NSDictionary dictionaryWithDictionary: attrMap];
}

@end
