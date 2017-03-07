//
//  BusinessProfileDataModel.h
//  Sure_sp
//
//  Created by Ranosys on 27/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceDataModel.h"
@interface BusinessProfileDataModel : NSObject
@property(nonatomic,retain)NSString * address;
@property(nonatomic,retain)NSString * bookings;
@property(nonatomic,retain)NSString * businessDescription;
@property(nonatomic,retain)NSString * businessName;
@property(nonatomic,retain)NSString * bussinessHours;
@property(nonatomic,retain)NSString * city;
@property(nonatomic,retain)NSString * contact;
@property(nonatomic,retain)NSString * latitude;
@property(nonatomic,retain)NSString * longitude;
@property(nonatomic,retain)NSString * name;
@property(nonatomic,retain)NSString * overallRating;
@property(nonatomic,retain)NSString * pinCode;
@property(nonatomic,retain)NSString * profileImage;
@property(nonatomic,retain)NSString * inShop;
@property(nonatomic,retain)NSMutableArray * serviceDataArray;
@property(nonatomic,retain)NSArray * comments;
@end




