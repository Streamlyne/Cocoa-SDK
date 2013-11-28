//
//  SLGroup.m
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 11/25/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLGroup.h"

@implementation SLGroup
- (id) init
{
    self = [super init];
    if (self) {
        // Initialize variables
        SLValue *name = [[SLValue alloc]initWithType:[NSString class]];
        SLValue *description = [[SLValue alloc]initWithType:[NSString class]];
        
        // Edit data schema
        NSMutableDictionary *tempData = [self.data mutableCopy];
        [tempData setValue:name forKey:@"name"];
        [tempData setValue:description forKey:@"description"];

        self.data = tempData;
    }
    return self;
}

+(NSString *) type
{
    return @"group";
}

@end
