//
//  SLAsset.m
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 11/24/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLAsset.h"

@implementation SLAsset

- (id) init
{
    self = [super init];
    if (self) {
        // Initialize variables
        SLValue *assetNumber = [[SLValue alloc]initWithType:[NSString class]];
        SLValue *serialNumber = [[SLValue alloc]initWithType:[NSString class]];
        SLValue *description = [[SLValue alloc]initWithType:[NSString class]];
        SLValue *mfg = [[SLValue alloc]initWithType:[NSString class]];
        SLValue *location = [[SLValue alloc]initWithType:[NSString class]];
        SLValue *costCenter = [[SLValue alloc]initWithType:[NSString class]];

        // Edit data schema
        NSMutableDictionary *tempData = [self.data mutableCopy];
        [tempData setValue:assetNumber forKey:@"number_asset"];
        [tempData setValue:serialNumber forKey:@"number_serial"];
        [tempData setValue:description forKey:@"description"];
        [tempData setValue:mfg forKey:@"mfg"];
        [tempData setValue:location forKey:@"location"];
        [tempData setValue:costCenter forKey:@"cost_center"];
        
        self.data = tempData;
    }
    return self;
}

+(NSString *) type
{
    return @"asset";
}

@end
