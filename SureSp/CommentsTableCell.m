//
//  CommentsTableCell.m
//  Sure_sp
//
//  Created by Ranosys on 17/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "CommentsTableCell.h"

@implementation CommentsTableCell
@synthesize commentTextView,dateLabel,separatorLabel,dateStarView,starRatingView;
@synthesize commentsLabel;
- (void)awakeFromNib {
    // Initialization code
    if (self==nil) {
        
    }
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)dealloc
{
    commentTextView = nil;
    dateLabel = nil;
    separatorLabel = nil;
    dateStarView = nil;

}
// method to set layouts of cell objects.
-(void)layoutView : (CGRect )rect
{
    self.commentTextView.translatesAutoresizingMaskIntoConstraints =YES;;
    self.dateLabel.translatesAutoresizingMaskIntoConstraints=YES;
    self.starRatingView.translatesAutoresizingMaskIntoConstraints= YES;
    self.separatorLabel.translatesAutoresizingMaskIntoConstraints=YES;
    self.dateStarView.translatesAutoresizingMaskIntoConstraints=YES;
    commentsLabel.translatesAutoresizingMaskIntoConstraints=YES;
    //commentsLabel.backgroundColor = [UIColor redColor];
    self.commentsLabel.frame =CGRectMake(self.commentsLabel.frame.origin.x, self.commentsLabel.frame.origin.y, rect.size.width-32, self.commentsLabel.frame.size.height);
    //self.commentTextView.frame =CGRectMake(16, self.frame.origin.y+10, rect.size.width-32, self.commentTextView.frame.size.height);
    self.separatorLabel.frame =CGRectMake(0, self.separatorLabel.frame.origin.y, rect.size.width, self.separatorLabel.frame.size.height);
    self.dateStarView.frame =CGRectMake(0, self.dateStarView.frame.origin.y, rect.size.width, self.dateStarView.frame.size.height);
    starRatingView.frame =CGRectMake(rect.size.width-95, self.starRatingView.frame.origin.y, 95, self.starRatingView.frame.size.height);
}
//method to display data in cell.
-(void)displayCommentData :(NSDictionary *)commentsDict
{
    self.commentTextView.text =[commentsDict objectForKey:@"Comment"];
    self.commentsLabel.text = [commentsDict objectForKey:@"Comment"];
    self.dateLabel.text = [myDelegate formatDateToDisplay:[commentsDict objectForKey:@"CommentedOn"]];
    
    starRatingView.backgroundColor = [UIColor clearColor];
    starRatingView.canEdit = NO;
    starRatingView.leftMargin=2.5;
    starRatingView.midMargin=.5;
    starRatingView.maxRating = 5;
    starRatingView.rating = [[commentsDict objectForKey:@"Rating"]floatValue];
    starRatingView.minAllowedRating = .5;
    starRatingView.maxAllowedRating = 5;
    

}

@end
