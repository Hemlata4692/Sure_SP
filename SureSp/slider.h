//
//  slider.h
//  CustomRangeSlider
//
//  Created by Ranosys on 14/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface slider : UIControl{
    float minSelectedValue;
    float maxSelectedValue;
    float minValue;
    float maxValue;
    float valueSpan;
    BOOL latchMin;
    BOOL latchMax;
    
    UIImageView *minHandle;
    UIImageView *maxHandle;
    
    float sliderBarHeight;
    float sliderBarWidth;
    
    CGColorRef bgColor;
}

@property float minSelectedValue;
@property float maxSelectedValue;

@property (nonatomic, retain) UIImageView *minHandle;
@property (nonatomic, retain) UIImageView *maxHandle;

- (id) initWithFrame:(CGRect)aFrame minValue:(float)minValue maxValue:(float)maxValue barHeight:(float)height;
+ (id) doubleSlider;
- (void) moveSlidersToPosition:(NSNumber *)leftSlider rightSlider:(NSNumber *)rightSlider animated:(BOOL)animated;
-(void)resizeSliderFrame :(CGRect)aFrame minValue:(float)aMinValue maxValue:(float)aMaxValue barHeight:(float)height;
@end
