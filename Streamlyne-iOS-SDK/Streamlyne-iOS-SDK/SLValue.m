//
//  SLValue.m
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLSDK.h"

@implementation SLValue


- (id) init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Not implemented."
                                 userInfo:nil];
}


- (id) initWithType:(id)type
{
    self = [super init];
    
    
    return self;
}


- (id) initWithType:(id)theType withValue:(id)theValue
{
    self = [self initWithType:theType];
    if (self)
    {
        [self set:theValue];
    }
    return self;
}


- (id) get
{
    return nil;
}


- (BOOL) set:(id)value
{
    return true;
}


- (BOOL) isSaved
{
    return false;
}


- (void) setSaved
{
    
}


- (void) addPredicate:(id)predicate
{
    
}

@end
