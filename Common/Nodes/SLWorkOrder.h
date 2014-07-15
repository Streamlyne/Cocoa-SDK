//
//  SLWorkOrder.h
//  Streamlyne-iOS-SDK
//
//  Created by Glavin Wiechert on 11/22/2013.
//  Copyright (c) 2013 Streamlyne. All rights reserved.
//

#import "SLModel.h"

@interface SLWorkOrder : SLModel

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSString *notesCompletion;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *costCenter;
@property (nonatomic, retain) NSDate *dateCompleted;
@property (nonatomic, retain) NSDate *dateDue;

@end
