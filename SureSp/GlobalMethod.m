//
//  CustomTextfield.m
//  PriceTag
//
//  Created by Ranosys on 05/08/14.
//  Copyright (c) 2014 Ranosys. All rights reserved.
//

#import "GlobalMethod.h"
@implementation GlobalMethod


+(BOOL)validateEmailString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+]+@[A-Za-z0-9.]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (int)getIphoneModel
{
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ){
        
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        if( screenHeight < screenWidth ){
            screenHeight = screenWidth;
        }
        
        if( screenHeight > 480 && screenHeight < 667 )
        {
            return 1;
        }
        else if ( screenHeight > 480 && screenHeight < 736 )
        {
            return 2;
        }
        else if ( screenHeight > 480 )
        {
            return 3;
            
        }
        else
        {
            return 0;
        }
    }
    
    
    return -1;
    
}

+(UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}



@end
