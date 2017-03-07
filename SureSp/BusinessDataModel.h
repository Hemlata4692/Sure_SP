//
//  BusinessRegisterDataModel.h
//  Sure_sp
//
//  Created by Hema on 11/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusinessDataModel : NSObject

@property(nonatomic,strong) NSString *Address;
@property(nonatomic,strong) NSString *businessDescription;
@property(nonatomic,strong) NSString *businessName;
@property(nonatomic,strong) NSArray *businessHours;
@property(nonatomic,strong) NSString *Contact;
@property(nonatomic,strong) NSString *inShop;
@property(nonatomic,strong) NSString *Name;
@property(nonatomic,strong) NSString *onSite;
@property(nonatomic,strong) NSString *otherSubCategory;
@property(nonatomic,strong) NSString *pinCode;
@property(nonatomic,strong) NSString *profileImage;
@property(nonatomic,strong) NSString *serviceCategory;
@property(nonatomic,strong) NSArray *subCategory;
@property(nonatomic,retain) NSString * cityId;
@end
