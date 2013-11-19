//
//  SLNode.h
//  Streamlyne-iOS-SDK
//
//  Created by Dawson Reid on 11/19/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "SLNodeManager.h"

@interface SLNode : NSObject {
    
    /**
     String s -> SLValue s
     */
    @private
    NSDictionary *data;
    
    @protected
    NSString *route;
    
    @private
    id nodeManager;
}

- (SLNode *) initWithManager:(id) manager;

- (SLNode *) initWithManager:(id) manager withData:(NSDictionary *) data;

- (void) update:(NSString *)attr value:(id)value;

/**
 
 */
- (Boolean *) save;



@end
