//
//  SLTransform.h
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-17.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLObject.h"

@interface SLTransform : SLObject

- (id) deserialize:(id)serialized;
- (id) serialize:(id)deserialized;

@end
