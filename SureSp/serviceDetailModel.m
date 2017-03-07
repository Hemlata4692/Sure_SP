//
//  serviceDetailModel.m
//  Sure_sp
//
//  Created by Ranosys on 23/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "serviceDetailModel.h"

@implementation serviceDetailModel
@synthesize bookBeforeHours;
@synthesize serviceName;
@synthesize serviceDescription;
@synthesize serviceType;
@synthesize serviceCharges;
@synthesize advanceBookingDays;
@synthesize imageNameArray;
@synthesize slotDurationHours;

-(void)dealloc
{

    bookBeforeHours = nil;
    serviceName = nil;
    serviceDescription = nil;
    serviceType = nil;
    advanceBookingDays =nil;
    imageNameArray = nil;
    serviceCharges = nil;

}

@end
