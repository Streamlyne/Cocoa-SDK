//
//  SLUser.h
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/21/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLModel.h"
#import "SLOrganization.h"

/**
 Custom `SLNode`, `SLUser`.
 */
@interface SLUser : SLModel {
    
}

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * jobTitle;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * password;

@end
