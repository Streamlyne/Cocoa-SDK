//
//  SLNode.m
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

//#import "SLNode.h"
#import "SLSDK.h"

@implementation SLNode


+ (id) init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Not implemented."
                                 userInfo:nil];
}


+ (SLNode *) readById:(int)nid
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Not implemented."
                                 userInfo:nil];
}


+ (NSArray *) readAll
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Not implemented."
                                 userInfo:nil];
}


+ (SLNode *) createWithData:(NSDictionary *)data withRels:(NSArray *)rels
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Not implemented."
                                 userInfo:nil];
}


+ (SLNode *) createWithData:(NSDictionary *)data
{
    return [SLNode createWithData:data withRels:nil];
}


+ (SLNode *) createWithRels:(NSArray *)rels
{
    return [SLNode createWithData:nil withRels:rels];
}


+ (SLNode *) create
{
    return [SLNode createWithData:nil withRels:nil];
}

@end
