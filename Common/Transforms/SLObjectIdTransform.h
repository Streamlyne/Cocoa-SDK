//
//  SLObjectIdTransform.h
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-17.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLTransformProtocol.h"

@interface SLObjectIdTransform : SLObject <SLTransformProtocol>
+ (NSDictionary *)serialize:(NSString *)deserialized;
+ (NSString *)deserialize:(NSDictionary *)serialized;
@end
