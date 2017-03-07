//
//  CommentsTableCell.h
//  Sure_sp
//
//  Created by Ranosys on 17/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASStarRatingView.h"
@interface CommentsTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *separatorLabel;
@property (weak, nonatomic) IBOutlet UIView *dateStarView;
@property (weak, nonatomic) IBOutlet ASStarRatingView *starRatingView;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;

-(void)displayCommentData :(NSDictionary *)commentsDict;
-(void)layoutView : (CGRect )rect;
@end
