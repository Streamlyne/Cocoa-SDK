//
//  SLAttribute.h
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-23.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SLModel.h"

@interface SLAttribute : SLModel

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id parameters;
@property (nonatomic, retain) NSString * assetName;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * humanName;

/**
 Query for the related Asset to this Attribute.
 This promise is cached for performance. 
 Subsequent requests will return the same promise which has the same resulting Asset.
 */
- (PMKPromise *) asset;

@end
