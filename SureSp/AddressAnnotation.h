//
//  AddressAnnotation.h
//  Sure_sp
//
//  Created by Ranosys on 27/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface AddressAnnotation : NSObject<MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
}
-(id)initWithCoordinate:(CLLocationCoordinate2D) c;
@end
