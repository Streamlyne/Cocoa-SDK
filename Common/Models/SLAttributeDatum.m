//
//  SLAttributeDatum.m
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-29.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLAttributeDatum.h"
#import "SLAttribute.h"


@implementation SLAttributeDatum

@dynamic data;
@dynamic attribute;


+ (NSString *) type
{
    return @"attributes";
}

@end
