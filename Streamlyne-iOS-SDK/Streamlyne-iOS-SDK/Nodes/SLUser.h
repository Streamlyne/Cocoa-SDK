//
//  SLUser.h
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/21/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLNode.h"

/**
 Custom `SLNode`, `SLUser`.
 */
@interface SLUser : SLNode {
    
}

/**
 
 */
+ (void) registerUser:(SLUser *)theUser withCallback:(SLSuccessCallback)theCallback;

@end
