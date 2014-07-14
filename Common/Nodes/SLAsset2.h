//
//  SLAsset.h
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 11/24/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLNode.h"

@interface SLAsset : SLNode

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * costCenter;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * mfg;
@property (nonatomic, retain) NSString * serial;

@end
