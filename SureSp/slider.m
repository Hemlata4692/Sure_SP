//
//  slider.m
//  CustomRangeSlider
//
//  Created by Ranosys on 14/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "slider.h"
#define kMinHandleDistance          10.0
#define kBoundaryValueThreshold     0.01
#define kMovingAnimationDuration    0.3

//create the gradient
static const CGFloat colors [] = {
    0.85, 0.85, 0.85, 1.0,
    0.85, 0.85, 0.85, 1.0
};

@interface slider (PrivateMethods)
- (void)updateValues;
- (void)addToContext:(CGContextRef)context roundRect:(CGRect)rrect withRoundedCorner1:(BOOL)c1 corner2:(BOOL)c2 corner3:(BOOL)c3 corner4:(BOOL)c4 radius:(CGFloat)radius;
- (void)updateHandleImages;
@end
@implementation slider
@synthesize minSelectedValue, maxSelectedValue;
@synthesize minHandle, maxHandle;

- (void) dealloc
{
    CGColorRelease(bgColor);
    self.minHandle = nil;
    self.maxHandle = nil;
    [super dealloc];
}

#pragma mark Object initialization

-(void)resizeSliderFrame :(CGRect)aFrame minValue:(float)aMinValue maxValue:(float)aMaxValue barHeight:(float)height
{

    if (aMinValue < aMaxValue) {
        minValue = aMinValue;
        maxValue = aMaxValue;
    }
    else {
        minValue = aMaxValue;
        maxValue = aMinValue;
    }
    valueSpan = maxValue - minValue;
    sliderBarHeight = height;
    sliderBarWidth = self.frame.size.width / self.transform.a;  //calculate the actual bar width by dividing with the cos of the view's angle
    
    self.minHandle = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"handle.png"] highlightedImage:[UIImage imageNamed:@"handle.png"]] autorelease];
    self.minHandle.center = CGPointMake(5, sliderBarHeight * 0.5);
    [self addSubview:self.minHandle];
    
    self.maxHandle = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"handle.png"] highlightedImage:[UIImage imageNamed:@"handle.png"]] autorelease];
    self.maxHandle.center = CGPointMake(248, sliderBarHeight * 0.5);
    [self addSubview:self.maxHandle];
    
    bgColor = CGColorRetain([UIColor darkGrayColor].CGColor);
    self.backgroundColor = [UIColor clearColor];
    
    //init
    latchMin = NO;
    latchMax = NO;
    [self updateValues];


}

- (id) initWithFrame:(CGRect)aFrame minValue:(float)aMinValue maxValue:(float)aMaxValue barHeight:(float)height
{
    self = [super initWithFrame:aFrame];
    if (self)
    {
        if (aMinValue < aMaxValue) {
            minValue = aMinValue;
            maxValue = aMaxValue;
        }
        else {
            minValue = aMaxValue;
            maxValue = aMinValue;
        }
        valueSpan = maxValue - minValue;
        sliderBarHeight = height;
        sliderBarWidth = self.frame.size.width / self.transform.a;  //calculate the actual bar width by dividing with the cos of the view's angle
        
        self.minHandle = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"handle.png"] highlightedImage:[UIImage imageNamed:@"handle.png"]] autorelease];
        self.minHandle.center = CGPointMake(5, sliderBarHeight * 0.5);
        [self addSubview:self.minHandle];
        
        self.maxHandle = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"handle.png"] highlightedImage:[UIImage imageNamed:@"handle.png"]] autorelease];
        self.maxHandle.center = CGPointMake(248, sliderBarHeight * 0.5);
        [self addSubview:self.maxHandle];
        
        bgColor = CGColorRetain([UIColor darkGrayColor].CGColor);
        self.backgroundColor = [UIColor clearColor];
        
        //init
        latchMin = NO;
        latchMax = NO;
        [self updateValues];
    }
    return self;
}

- (void) moveSlidersToPosition:(NSNumber *)leftSlider rightSlider:(NSNumber *)rightSlider animated:(BOOL)animated {
    CGFloat duration = animated ? kMovingAnimationDuration : 0.0;
    [UIView transitionWithView:self duration:duration options:UIViewAnimationOptionCurveLinear
                    animations:^(void){
                        self.minHandle.center = CGPointMake(sliderBarWidth * ((float)[leftSlider intValue] / 100), sliderBarHeight * 0.5);
                        self.maxHandle.center = CGPointMake(sliderBarWidth * ((float)[rightSlider intValue] / 100), sliderBarHeight * 0.5);
                        [self updateValues];
                        //force redraw
                        [self setNeedsDisplay];
                        //notify listeners
                        [self sendActionsForControlEvents:UIControlEventValueChanged];
                    }
                    completion:^(BOOL finished) {
                    }];
}


+ (id) doubleSlider
{
    return [[[self alloc] initWithFrame:CGRectMake(0., 0., 258, 40.) minValue:0.0 maxValue:258.0 barHeight:10.0] autorelease];
}

#pragma mark Touch tracking

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    if ( CGRectContainsPoint(self.minHandle.frame, touchPoint) ) {
        latchMin = YES;
    }
    else if ( CGRectContainsPoint(self.maxHandle.frame, touchPoint) ) {
        latchMax = YES;
    }
    [self updateHandleImages];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    if ( latchMin || CGRectContainsPoint(self.minHandle.frame, touchPoint) ) {
        if (touchPoint.x < self.maxHandle.center.x - kMinHandleDistance && touchPoint.x >= 6.0) {
            self.minHandle.center = CGPointMake(touchPoint.x, self.minHandle.center.y);
            [self updateValues];
        }
    }
    else if ( latchMax || CGRectContainsPoint(self.maxHandle.frame, touchPoint) ) {
        if (touchPoint.x > self.minHandle.center.x + kMinHandleDistance && touchPoint.x < sliderBarWidth-8) {
            self.maxHandle.center = CGPointMake(touchPoint.x, self.maxHandle.center.y);
            [self updateValues];
        }
    }
    // Send value changed alert
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    //redraw
    [self setNeedsDisplay];
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    latchMin = NO;
    latchMax = NO;
    [self updateHandleImages];
}

#pragma mark Custom Drawing

- (void) drawRect:(CGRect)rect
{
    //FIX: optimise and save some reusable stuff
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    //    CGGradientRef *gradient;
    //    UIColor *startColour = [UIColor colorWithRed:99.0/255.0f green:150.0/255.0f blue:200.0/255.0f alpha:1.0];
    //    UIColor *endColour = [UIColor colorWithRed:47.0/255.0f green:103.0/255.0f blue:156.0/255.0f alpha:1.0];
    //    gradient.colors = [NSArray arrayWithObjects:(id)[startColour CGColor], (id)[endColour CGColor], nil];
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    CGRect rect1 = CGRectMake(0.0, 0.0, self.minHandle.center.x, sliderBarHeight);
    CGRect rect2 = CGRectMake(self.minHandle.center.x, 0.0, self.maxHandle.center.x - self.minHandle.center.x, sliderBarHeight);
    CGRect rect3 = CGRectMake(self.maxHandle.center.x, 0.0, sliderBarWidth - self.maxHandle.center.x, sliderBarHeight);
    
    CGContextSaveGState(context);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    //add the right rect
    [self addToContext:context roundRect:rect3 withRoundedCorner1:NO corner2:YES corner3:YES corner4:NO radius:5.0f];
    //add the left rect
    [self addToContext:context roundRect:rect1 withRoundedCorner1:YES corner2:NO corner3:NO corner4:YES radius:5.0f];
    
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    CGGradientRelease(gradient), gradient = NULL;
    
    //draw middle rect
    CGContextRestoreGState(context);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:214.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1.0].CGColor);
    CGContextFillRect(context, rect2);
    
    [super drawRect:rect];
}

- (void)addToContext:(CGContextRef)context roundRect:(CGRect)rrect withRoundedCorner1:(BOOL)c1 corner2:(BOOL)c2 corner3:(BOOL)c3 corner4:(BOOL)c4 radius:(CGFloat)radius
{
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
    
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, c1 ? radius : 0.0f);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, c2 ? radius : 0.0f);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, c3 ? radius : 0.0f);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, c4 ? radius : 0.0f);
}


#pragma mark Helper

- (void)updateHandleImages
{
    self.minHandle.highlighted = latchMin;
    self.maxHandle.highlighted = latchMax;
}

- (void)updateValues
{
    
    //	self.minSelectedValue = minValue + self.minHandle.center.x / sliderBarWidth * valueSpan;
    //snap to min value
    //    if (self.minSelectedValue < minValue + kBoundaryValueThreshold * valueSpan) self.minSelectedValue = minValue;
    int check=self.minHandle.center.x/5;
    self.minSelectedValue=check;
    check=self.maxHandle.center.x/5;
    self.maxSelectedValue =check;
    //snap to max value
    //    if (self.maxSelectedValue > maxValue - kBoundaryValueThreshold * valueSpan) self.maxSelectedValue = maxValue;
}

@end
