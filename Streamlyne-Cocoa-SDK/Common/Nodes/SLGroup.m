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


+ (NSString *) keyForKey:(NSString *)key {
    if ([key isEqualToString: @"name"]) {
        return @"name";
    } else if ([key isEqualToString: @"description"]) {
        return @"desc";
    } else {
        return [[[self superclass] class] keyForKey:key];
    }
}

@end
