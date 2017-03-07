//
//  AddServiceViewController.h
//  Sure_sp
//
//  Created by Ranosys on 25/03/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackViewController.h"


@interface AddServiceViewController : BackViewController
@property(nonatomic,strong)NSString * serviceId;
@property(nonatomic,assign)bool canEdit;


@end
