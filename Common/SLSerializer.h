//
//  SLSerializer.h
//  Streamlyne Cocoa SDK
//
//  Created by Glavin Wiechert on 2014-07-17.
//  Copyright (c) 2014 Streamlyne. All rights reserved.
//

#import "SLObject.h"
#import "SLTransform.h"

@interface SLSerializer : SLObject

/**
 
 */
-(void)registerTransform:(SLTransform *)transform forClass:(Class *)cls;

@end
