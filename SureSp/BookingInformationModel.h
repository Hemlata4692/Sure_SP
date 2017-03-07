//
//  BookingInformationModel.h
//  Sure_sp
//
//  Created by Hema on 21/05/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookingInformationModel : NSObject

@property(nonatomic,retain)NSString * bookingDate;
@property(nonatomic,retain)NSString * customerAddress;
@property(nonatomic,retain)NSString * customerContact;
@property(nonatomic,retain)NSString * customerName;
@property(nonatomic,retain)NSString * remarks;
@property(nonatomic,retain)NSString * endTime;
@property(nonatomic,retain)NSString * latitude;
@property(nonatomic,retain)NSString * longitude;
@property(nonatomic,retain)NSString * startTime;
@property(nonatomic,retain)NSString * serviceCharges;
@property(nonatomic,retain)NSString * serviceName;
@property(nonatomic,retain)NSString * serviceType;

@end
