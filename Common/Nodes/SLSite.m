//
//  SLSite.m
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 1/3/2014.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLSite.h"

@implementation SLSite

@dynamic name, location;

- (id) init
{
    self = [super init];
    if (self) {

    }
    return self;
}

+(NSString *) type
{
    return @"site";
}


+ (NSDictionary *) attributeMappings
{
    NSMutableDictionary *attrMap = [NSMutableDictionary dictionaryWithDictionary:[[[self superclass] class] attributeMappings]];
    [attrMap setValue:@"name" forKey:@"name"];
    [attrMap setValue:@"location" forKey:@"location"];
    return [NSDictionary dictionaryWithDictionary: attrMap];
}


@end
