//
//  serviceDetailModel.h
//  Sure_sp
//
//  Created by Ranosys on 23/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface serviceDetailModel : NSObject
@property(nonatomic,retain)NSString * bookBeforeHours;
@property(nonatomic,retain)NSString * serviceName;
@property(nonatomic,retain)NSString * serviceDescription;
@property(nonatomic,retain)NSString * serviceType;
@property(nonatomic,retain)NSString * serviceCharges;
@property(nonatomic,retain)NSString * advanceBookingDays;
@property(nonatomic,retain)NSString * slotDurationHours;
@property(nonatomic,retain)NSMutableArray * imageNameArray;

@end

