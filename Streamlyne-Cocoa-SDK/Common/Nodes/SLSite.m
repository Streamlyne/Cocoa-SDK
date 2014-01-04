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

+ (NSString *) keyForKey:(NSString *)key {
    if ([key isEqualToString: @"name"]) {
        return @"name";
    } else if ([key isEqualToString:@"location"]) {
        return @"location";
    } else {
        // return [[super class] keyForKey:key];
        return key;
    }
}

@end
