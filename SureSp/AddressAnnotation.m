//
//  AddressAnnotation.m
//  Sure_sp
//
//  Created by Ranosys on 27/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "AddressAnnotation.h"

@implementation AddressAnnotation
@synthesize coordinate;

- (NSString *)subtitle{
    return nil;
}

- (NSString *)title{
    return nil;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
    coordinate=c;
    return self;
}
@end
