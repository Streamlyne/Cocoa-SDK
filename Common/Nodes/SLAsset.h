//
//  SLAsset.h
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-14.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SLNode.h"


@interface SLAsset : SLNode

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * costCenter;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * mfg;
@property (nonatomic, retain) NSString * serial;
@property (nonatomic, retain) NSSet *attributes;
@end

@interface SLAsset (CoreDataGeneratedAccessors)

- (void)addAttributesObject:(NSManagedObject *)value;
- (void)removeAttributesObject:(NSManagedObject *)value;
- (void)addAttributes:(NSSet *)values;
- (void)removeAttributes:(NSSet *)values;

@end
