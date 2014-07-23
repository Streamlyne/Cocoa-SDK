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
@property (nonatomic, retain) NSString * asset_name;
@property (nonatomic, retain) NSString * desc;

@end
