//
//  SLAsset.m
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-14.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLAsset.h"


@implementation SLAsset

@dynamic name;
@dynamic costCenter;
@dynamic desc;
@dynamic location;
@dynamic mfg;
@dynamic serial;
@dynamic attributes;

+ (NSString *) type
{
    return @"asset";
}

@end
