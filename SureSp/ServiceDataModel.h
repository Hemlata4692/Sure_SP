//
//  ServiceDataModel.h
//  Sure_sp
//
//  Created by Ranosys on 27/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceDataModel : NSObject
@property(nonatomic,retain)NSString * name;
@property(nonatomic,retain)NSString * serviceCharges;
@property(nonatomic,retain)NSString * serviceDescription;
@property(nonatomic,retain)NSString * serviceType;
@property(nonatomic,retain)NSArray *  serviceImages;
@end


//ServiceResponse =
//(
// {
//     BookBeforeHrs = 0;
//     CanDelete = 1;
//     DaysAdvanceBooking = 0;
//     IsSuccess = 0;
//     Message = "";
//     Name = "bucket folder testing";
//     ServiceCharges = 12;
//     ServiceDescription = desc;
//     ServiceId = 85;
//     ServiceImages =             (
//                                  {
//                                      Image = "Sure_Sp200415053440-2.jpeg";
//                                  },
//                                  {
//                                      Image = "1429536200178_1647";
//                                  }
//                                  );
//     ServiceType = 1;
//     SlotDurationHrs = 0;
//     UserId = "";
// },