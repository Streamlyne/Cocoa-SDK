//
//  SLOrganization.m
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/22/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLOrganization.h"

@implementation SLOrganization

- (id) init
{
    self = [super init];
    if (self) {
        // Initialize variables
        SLValue *name = [[SLValue alloc]initWithType:[NSString class]];
        // Edit data schema
        NSMutableDictionary *tempData = [self.data mutableCopy];
        [tempData setValue:name forKey:@"name"];
        self.data = tempData;
    }
    return self;
}

+ (NSString *) type
{
    return @"organization";
}

@end
