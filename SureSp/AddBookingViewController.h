//
//  AddBookingViewController.h
//  Sure_sp
//
//  Created by Ranosys on 16/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSKeyboardControls.h"
#import "BackViewController.h"
#import "MyCalenderViewController.h"
#import "MyCalenderDataModel.h"

@interface AddBookingViewController : BackViewController <BSKeyboardControlsDelegate>
@property (strong, nonatomic) NSString *bookingDate;
@property (strong, nonatomic) NSString *bookingStartTime;
@property (strong, nonatomic) NSString *bookingEndTime;
@property (strong, nonatomic) MyCalenderDataModel *calenderData;
@property(strong, nonatomic) MyCalenderViewController *calenderObj;

@end
