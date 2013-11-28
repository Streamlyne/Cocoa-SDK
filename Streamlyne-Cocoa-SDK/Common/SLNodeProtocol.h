//
//  SLNodeProtocol.h
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/23/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLObject.h"

@protocol SLNodeProtocol <NSObject>

/**
 String s -> SLValue s
 */
@required
@property (strong, nonatomic) NSDictionary *data;

/**
 A list of relationships to this node.
 */
@required
@property (strong, nonatomic) SLRelationshipArray *rels;

@required
@property (strong, nonatomic) SLNid nid;

@required
- (NSString *) type;

@end
