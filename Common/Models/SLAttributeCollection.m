//
//  SLAttributeCollection.m
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-22.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLAttributeCollection.h"


@implementation SLAttributeCollection

@dynamic name;
@dynamic desc;
@dynamic attributes;


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
