//
//  UITextView+Validations.m
//  Sure_sp
//
//  Created by Hema on 06/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "UITextView+Validations.h"

@implementation UITextView (Validations)

- (BOOL)isEmpty {
    return ([self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) ? YES : NO;
}

@end
