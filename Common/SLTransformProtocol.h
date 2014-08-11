//
//  SLTransform.h
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-17.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLObject.h"

@protocol SLTransformProtocol <NSObject>

@required
+ (id) deserialize:(id)serialized;
@required
+ (id) serialize:(id)deserialized;

@end
