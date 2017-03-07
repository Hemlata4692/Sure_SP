//
//  PendingConfirmationModel.h
//  Sure_sp
//
//  Created by Ranosys on 25/05/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PendingConfirmationModel : NSObject
@property(nonatomic,retain)NSString * bookingDate;
@property(nonatomic,retain)NSString * endTime;
@property(nonatomic,retain)NSString * name;
@property(nonatomic,retain)NSString * serviceCharges;
@property(nonatomic,retain)NSString * serviceId;
@property(nonatomic,retain)NSString * serviceName;
@property(nonatomic,retain)NSString * startTime;
@property(nonatomic,retain)NSString * userId;
@property(nonatomic,retain)NSString * bookingId;
@property(nonatomic,retain)NSString * message;
@end
