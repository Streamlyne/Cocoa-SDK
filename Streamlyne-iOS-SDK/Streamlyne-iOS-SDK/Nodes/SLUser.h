//
//  SLUser.h
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/21/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLNode.h"
#import "SLOrganization.h"

/**
 Custom `SLNode`, `SLUser`.
 */
@interface SLUser : SLNode {
    
}

/**
 
 */
+ (void) registerUser:(SLUser *)theUser
     withOrganization:(SLOrganization *)theOrg
         withCallback:(SLSuccessCallback)theCallback;

+ (void) registerUserWithEmail:(NSString *)email
                  withPassword:(NSString *)password
                  withJobTitle:(NSString *)jobTitle
                 withFirstName:(NSString *)firstName
                  withLastName:(NSString *)lastName
              withOrganization:(SLOrganization *)theOrg
                  withCallback:(SLSuccessCallback)theCallback;

@end
