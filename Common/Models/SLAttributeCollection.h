//
//  SLAttributeCollection.h
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-22.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SLModel.h"

@interface SLAttributeCollection : SLModel

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSManagedObject *attributes;

@end
