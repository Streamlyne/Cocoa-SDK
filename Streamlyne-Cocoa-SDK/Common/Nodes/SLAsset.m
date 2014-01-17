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



+ (NSString *) keyForKey:(NSString *)key {
    if ([key isEqualToString: @"number_asset"]) {
        return @"assetNumber";
    } else if ([key isEqualToString:@"number_serial"]) {
        return @"serial";
    } else if ([key isEqualToString:@"description"]) {
        return @"desc";
    } else if ([key isEqualToString:@"mfg"]) {
        return @"mfg";
    } else if ([key isEqualToString:@"location"]) {
        return @"location";
    } else if ([key isEqualToString:@"cost_center"]) {
        return @"costCenter";
    } else {
        return [[[self superclass] class] keyForKey:key];
    }
}

@end
