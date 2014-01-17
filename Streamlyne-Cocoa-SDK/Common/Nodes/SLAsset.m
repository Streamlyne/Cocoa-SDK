//
//  SLAsset.m
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 11/24/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLAsset.h"

@implementation SLAsset

@dynamic assetNumber;
@dynamic costCenter;
@dynamic desc;
@dynamic location;
@dynamic mfg;
@dynamic serial;

+(NSString *) type
{
    return @"asset";
}


+ (NSDictionary *) attributeMappings
{
    NSMutableDictionary *attrMap = [NSMutableDictionary dictionaryWithDictionary:[[[self superclass] class] attributeMappings]];
    [attrMap setValue:@"assetNumber" forKey:@"number_asset"];
    [attrMap setValue:@"serial" forKey:@"number_serial"];
    [attrMap setValue:@"desc" forKey:@"description"];
    [attrMap setValue:@"mfg" forKey:@"mfg"];
    [attrMap setValue:@"location" forKey:@"location"];
    [attrMap setValue:@"costCenter" forKey:@"cost_center"];
    return [NSDictionary dictionaryWithDictionary: attrMap];
}

@end
