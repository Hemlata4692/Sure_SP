//
//  MrLoadingView.m
//  MrLoadingView
//
//  Created by ChenHao on 2/11/15.
//  Copyright (c) 2015 xxTeam. All rights reserved.
//

#import "HHAlertView.h"
#import "AppDelegate.h"

#define OKBUTTON_BACKGROUND_COLOR [UIColor colorWithRed:158/255.0 green:214/255.0 blue:243/255.0 alpha:1]
#define CANCELBUTTON_BACKGROUND_COLOR [UIColor colorWithRed:255/255.0 green:20/255.0 blue:20/255.0 alpha:1]


NSInteger const HHAlertview_SIZE_WIDTH = 260;
NSInteger const HHAlertview_SIZE_HEIGHT = 250;
NSInteger const Simble_SIZE      = 60;
NSInteger const Simble_TOP      = 20;

NSInteger const Button_SIZE_WIDTH        = 100;
NSInteger const Buutton_SIZE_HEIGHT      = 30;



NSInteger const HHAlertview_SIZE_TITLE_FONT = 25;
NSInteger const HHAlertview_SIZE_DETAIL_FONT = 18;

static selectButton STAblock;


@interface HHAlertView(){
    UIView *customView;
}

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *OkButton;

@property (nonatomic, strong) UIView *logoView;

@end


@implementation HHAlertView



+ (instancetype)shared
{
    static dispatch_once_t once = 0;
    static HHAlertView *alert;
    
    dispatch_once(&once, ^{
        alert = [[HHAlertView alloc] init];
    });
    return alert;
}



- (instancetype)init
{
    AppDelegate *appdelegate=[UIApplication sharedApplication].delegate;
    self = [[HHAlertView alloc] initWithFrame:CGRectMake(0, 0, appdelegate.window.frame.size.width, appdelegate.window.frame.size.height)];
    self.alpha = 0;
    customView=[[UIView alloc] initWithFrame:CGRectMake(20, (appdelegate.window.frame.size.height/2)-125, appdelegate.window.frame.size.width-40, 250)];
    [self setBackgroundColor:[UIColor whiteColor]];
    
    return self;
}


+ (void)showAlertWithStyle:(HHAlertStyle )HHAlertStyle inView:(UIView *)view Title:(NSString *)title detail:(NSString *)detail cancelButton:(NSString *)cancel Okbutton:(NSString *)ok
{
    
    
            [[self shared] drawWraning];
        
    
    
    [[self shared] configtext:title detail:detail];
    
    
    [[self shared] configButton:cancel Okbutton:ok];
    
    [view addSubview:[self shared]];
    [[self shared] show];
}



+ (void)showAlertWithStyle:(HHAlertStyle)HHAlertStyle inView:(UIView *)view Title:(NSString *)title detail:(NSString *)detail cancelButton:(NSString *)cancel Okbutton:(NSString *)ok block:(selectButton)block
{
    
            [[self shared] drawWraning];
           [[self shared] configtext:title detail:detail];
    
    
    [[self shared] configButton:cancel Okbutton:ok];
    
    [view addSubview:[self shared]];
    [[self shared] show];
    
}



- (void)configtext:(NSString *)title detail:(NSString *)detail
{
    if (_titleLabel==nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,10, customView.frame.size.width, 50)];
    }
    //     _titleLabel.backgroundColor=[UIColor greenColor];
    _titleLabel.text = title;
    [_titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:28]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    _titleLabel.textColor=[UIColor grayColor];
    [customView addSubview:_titleLabel];
    
    if (_detailLabel==nil) {
        _detailLabel  = [[UILabel alloc] initWithFrame:CGRectMake(_titleLabel.frame.origin.x+10, _titleLabel.frame.origin.y+60, _titleLabel.frame.size.width-20,75)];
    }
    
    _detailLabel.text = detail;
    //    _detailLabel.backgroundColor=[UIColor yellowColor];
    _detailLabel.numberOfLines=3;
    _detailLabel.textColor = [UIColor grayColor];
    [_detailLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
    [_detailLabel setTextAlignment:NSTextAlignmentCenter];
    [customView addSubview:_detailLabel];
    
}


- (void)configButton:(NSString *)cancel Okbutton:(NSString *)ok
{
    //    if (cancel==nil) {
    //        if (_OkButton==nil) {
    //            _OkButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, Button_SIZE_WIDTH, Buutton_SIZE_HEIGHT)];
    //        }
    //        else
    //        {
    //            [_OkButton setFrame:CGRectMake(0, 0, Button_SIZE_WIDTH, Buutton_SIZE_HEIGHT)];
    //        }
    //
    //        [_OkButton setTitle:ok forState:UIControlStateNormal];
    //        [_OkButton setBackgroundColor:OKBUTTON_BACKGROUND_COLOR];
    //        [[_OkButton layer] setCornerRadius:5];
    //
    //        [_OkButton addTarget:self action:@selector(dismissWithOk) forControlEvents:UIControlEventTouchUpInside];
    //
    //
    //
    //        [customView addSubview:_OkButton];
    //
    //    }
    //
    //
    //    if (cancel!=nil && ok!=nil) {
    //        if (_cancelButton == nil) {
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake((customView.frame.size.width/2)-130, customView.frame.size.height-60, 125, 45)];
    //        }
    
    [_cancelButton setBackgroundColor:[UIColor whiteColor]];
    [_cancelButton setTitle:cancel forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [[_cancelButton layer] setCornerRadius:2];
    _cancelButton.layer.shadowColor=[UIColor blackColor].CGColor;
    _cancelButton.layer.shadowOpacity=0.5f;
    _cancelButton.layer.shadowOffset=CGSizeMake(-1, -1);
    [_cancelButton addTarget:self action:@selector(dismissWithCancel) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:_cancelButton];
    
    
    
    _OkButton = [[UIButton alloc] initWithFrame:CGRectMake((customView.frame.size.width/2)+5, customView.frame.size.height-60, 125, 45)];
    [_OkButton setTitle:ok forState:UIControlStateNormal];
    [_OkButton setBackgroundColor:[UIColor colorWithRed:255/255.0 green:64/255.0 blue:63/255.0 alpha:1]];
    [_OkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[_OkButton layer] setCornerRadius:2];
    _OkButton.layer.shadowColor=[UIColor blackColor].CGColor;
    _OkButton.layer.shadowOpacity=0.5f;
    _OkButton.layer.shadowOffset=CGSizeMake(-1, -1);
    [_OkButton addTarget:self action:@selector(dismissWithOk) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:_OkButton];
    //    }
}

- (void)dismissWithCancel
{
    
    if (STAblock!=nil) {
        STAblock(HHAlertButtonCancel);
    }
    else
    {
        [_delegate didClickButtonAnIndex:HHAlertButtonCancel];
    }
    [HHAlertView Hide];
}

- (void)dismissWithOk
{
    
    if (STAblock!=nil) {
        STAblock(HHAlertButtonOk);
    }
    else
    {
        [_delegate didClickButtonAnIndex:HHAlertButtonOk];
    }
    [HHAlertView Hide];
}


- (void)destroy
{
    
    [UIView animateWithDuration:0.0 animations:^{
        self.alpha=0.0;
        self.layer.cornerRadius = 10;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 5);
        self.layer.shadowOpacity = 0.3f;
        self.layer.shadowRadius = 10.0f;
    } completion:^(BOOL finished) {
        [_OkButton removeFromSuperview];
        [_cancelButton removeFromSuperview];
        _OkButton=nil;
        _cancelButton = nil;
        STAblock=nil;
        [self removeFromSuperview];
    }];
}



- (void)show
{
    [UIView animateWithDuration:0.0 animations:^{
        self.alpha=1;
        self.layer.cornerRadius = 0;
        //        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.backgroundColor=[UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:0.4].CGColor;
        //        self.layer.shadowOffset = CGSizeMake(0, 5);
        //        self.layer.shadowOpacity = 0.3f;
        //        self.layer.shadowRadius = 0.0f;
    } completion:^(BOOL finished) {
        
    }];
    
}


+ (void)Hide
{
    [[self shared] destroy];
}


#pragma helper mehtod

- (CGSize)getMainScreenSize
{
    return [[UIScreen mainScreen] bounds].size;
}

- (CGSize)getSelfSize
{
    return self.frame.size;
}


#pragma draw method

- (void)drawError
{
    [_logoView removeFromSuperview];
    _logoView = [[UIView alloc] initWithFrame:CGRectMake(([self getSelfSize].width-Simble_SIZE)/2, Simble_TOP, Simble_SIZE, Simble_SIZE)];
    
    
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(Simble_SIZE/2, Simble_SIZE/2) radius:Simble_SIZE/2 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    
    CGPoint p1 =  CGPointMake(Simble_SIZE/4, Simble_SIZE/4);
    [path moveToPoint:p1];
    
    CGPoint p2 =  CGPointMake(Simble_SIZE/4*3, Simble_SIZE/4*3);
    [path addLineToPoint:p2];
    
    CGPoint p3 =  CGPointMake(Simble_SIZE/4*3, Simble_SIZE/4);
    [path moveToPoint:p3];
    
    CGPoint p4 =  CGPointMake(Simble_SIZE/4, Simble_SIZE/4*3);
    [path addLineToPoint:p4];
    
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.lineWidth = 5;
    layer.path = path.CGPath;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor redColor].CGColor;
    
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = 0.5;
    [layer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
    
    [_logoView.layer addSublayer:layer];
    [self addSubview:_logoView];
}


- (void)drawTick
{
    
    //    [_logoView removeFromSuperview];
    //    _logoView = [[UIView alloc] initWithFrame:CGRectMake(([self getSelfSize].width-Simble_SIZE)/2, Simble_TOP, Simble_SIZE, Simble_SIZE)];
    //
    //    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(Simble_SIZE/2, Simble_SIZE/2) radius:Simble_SIZE/2 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    //
    //    path.lineCapStyle = kCGLineCapRound;
    //    path.lineJoinStyle = kCGLineCapRound;
    //
    //    [path moveToPoint:CGPointMake(Simble_SIZE/4, Simble_SIZE/2)];
    //    CGPoint p1 = CGPointMake(Simble_SIZE/4+10, Simble_SIZE/2+10);
    //    [path addLineToPoint:p1];
    //
    //
    //    CGPoint p2 = CGPointMake(Simble_SIZE/4*3, Simble_SIZE/4);
    //    [path addLineToPoint:p2];
    //
    //    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    //    layer.fillColor = [UIColor clearColor].CGColor;
    //    layer.strokeColor = [UIColor greenColor].CGColor;
    //    layer.lineWidth = 5;
    //    layer.path = path.CGPath;
    //
    //    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    //    animation.fromValue = @0;
    //    animation.toValue = @1;
    //    animation.duration = 0.5;
    //    [layer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
    //
    //    [_logoView.layer addSublayer:layer];
    customView.backgroundColor=[UIColor whiteColor];
    [self addSubview:customView];
}

- (void)drawWraning
{
    customView.backgroundColor=[UIColor whiteColor];
    
    [self addSubview:customView];
}

@end
// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net