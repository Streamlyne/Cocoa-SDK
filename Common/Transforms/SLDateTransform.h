//
//  SLDateTransform.h
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-17.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLTransform.h"

@interface SLDateTransform : SLTransform
+ (NSDictionary *)serialize:(NSDate *)deserialized;
+ (NSDate *)deserialize:(NSDictionary *)serialized;
@end
