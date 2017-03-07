//
//  PendingConfirmationCell.m
//  Sure_sp
//
//  Created by Ranosys on 25/05/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "PendingConfirmationCell.h"
#import "PendingConfirmationModel.h"
@implementation PendingConfirmationCell
@synthesize customerNameLabel;
@synthesize dateLabel;
@synthesize timeLabel;
@synthesize serviceName;
@synthesize serviceCharge;
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)displayData : (PendingConfirmationModel *)model
{
 
    customerNameLabel.text = model.name;
    dateLabel.text = [myDelegate formatDateToDisplay:model.bookingDate];
    if ([model.endTime isEqualToString:@"23:59"]) {
        model.endTime=@"24:00";
    }
    timeLabel.text = [NSString stringWithFormat:@"%@ to %@",model.startTime,model.endTime];
    serviceName.text= model.serviceName;
    serviceCharge.text =model.serviceCharges;

}
@end
