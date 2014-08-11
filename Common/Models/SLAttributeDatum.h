//
//  SLAttributeDatum.h
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-29.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SLModel.h"

@class SLAttribute;

@interface SLAttributeDatum : SLModel

@property (nonatomic, retain) id value;
@property (nonatomic, retain) SLAttribute *attribute;

@end
