//
//  PendingConfirmationCell.h
//  Sure_sp
//
//  Created by Ranosys on 25/05/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PendingConfirmationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *customerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceName;
@property (weak, nonatomic) IBOutlet UILabel *serviceCharge;

-(void)displayData : (PendingConfirmationModel *)model;
@end
