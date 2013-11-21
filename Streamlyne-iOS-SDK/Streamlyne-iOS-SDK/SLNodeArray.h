//
//  SLNodeArray.h
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/21/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLNode.h"

/**
 TODO:
 Any subclass of NSArray must override the primitive instance methods count and objectAtIndex:. These methods must operate on the backing store that you provide for the elements of the collection. For this backing store you can use a static array, a standard NSArray object, or some other data type or mechanism. You may also choose to override, partially or fully, any other NSArray method for which you want to provide an alternative implementation.
 Source: http://stackoverflow.com/a/4351448/2578205
 */
@interface SLNodeArray : NSMutableArray

@end
