//
//  SLUser.m
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/21/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLUser.h"

@implementation SLUser

- (id) init
{
    self = [super init];
    if (self) {
        // Initialize variables
        self->element_type = @"SLUser";
    }
    return self;
}


@end
