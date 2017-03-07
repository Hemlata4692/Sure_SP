//
//  BookingInformationViewController.m
//  Sure_sp
//
//  Created by Ranosys on 23/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "BookingInformationViewController.h"
#import "BookingRequestViewController.h"
#import "UITextField+Padding.h"
#import "UIPlaceHolderTextView.h"
#import "UIView+RoundedCorner.h"
#import "BookingInformationModel.h"
#import "UITextField+Validations.h"
#import "UITextView+Validations.h"
#import "MJGeocodingServices.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "SWRevealViewController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0)
#define kBaseUrl @"http://maps.googleapis.com/maps/api/directions/json?"
@interface BookingInformationViewController ()<MKMapViewDelegate ,MKAnnotation ,MKOverlay,SWRevealViewControllerDelegate>
{
    
    UIBarButtonItem *backMenuButton,*menuButton;
    NSString *customerLatitude;
    NSString *customerLongitude;
    MJGeocoder *forwardGeocoder;
    NSString *spLocation;
    NSString *destLat;
    NSString *destLong;
}
-(MKPolyline *)polylineWithEncodedString:(NSString *)encodedString ;
-(void)addAnnotationSrcAndDestination :(CLLocationCoordinate2D )srcCord :(CLLocationCoordinate2D)destCord;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *currencyContainer;
@property (weak, nonatomic) IBOutlet UILabel *serviceChargesLabel;
@property (weak, nonatomic) IBOutlet UITextField *serviceNameField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *contactField;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIView *dateTimeView;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *remarksTextView;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *addressTextView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *bookingTimeLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property(nonatomic,retain)NSMutableArray * bookingInformationData;

@property (weak, nonatomic) IBOutlet UIView *bookingInfoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bookingInfoViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingSpaceBookingInfoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingSpaceBookingInfoView;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;



@end

@implementation BookingInformationViewController
@synthesize currencyContainer,nameField,contactField,serviceNameField,serviceChargesLabel,callButton,dateTimeView,addressTextView,remarksTextView,mapView;
@synthesize bookingID,bookingInformationData;
@synthesize dateLabel,bookingTimeLabel,activityIndicator;
@synthesize boundingMapRect,coordinate;

#pragma mark - left navigaton bar button
- (void)addLeftBarButtonWithImage:(UIImage *)buttonImage secondImage:(UIImage *)menuImage {
    CGRect framing = CGRectMake(0, 0, menuImage.size.width, menuImage.size.height);
    
    UIButton *menu = [[UIButton alloc] initWithFrame:framing];
    [menu setBackgroundImage:menuImage forState:UIControlStateNormal];
    
    menuButton =[[UIBarButtonItem alloc] initWithCustomView:menu];
    //    self.navigationItem.leftBarButtonItem = backMenuButton;
    framing = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    
    
    UIButton *button = [[UIButton alloc] initWithFrame:framing];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    backMenuButton =[[UIBarButtonItem alloc] initWithCustomView:button];
    //    self.navigationItem.leftBarButtonItem = backMenuButton;
    
    
    [button addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([myDelegate.superClassView isEqualToString:@"sureView"]) {
        self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:menuButton, nil];
        
    }
    else{
        self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:backMenuButton,menuButton, nil];
        
    }
    
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        
        [menu addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
}

-(void)backButtonAction :(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - end

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back"] secondImage:[UIImage imageNamed:@"menu.png"]];
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    self.title=@"Booking Information";
    
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
    
    [self addPaddingToFields];
    [self setCornerRadius];
    
    
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getBookingInformationFromServer) withObject:nil afterDelay:.1];
    
    
    
    activityIndicator.hidden=YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) addPaddingToFields
{
    [nameField addTextFieldPaddingWithoutImages:nameField];
    [serviceNameField addTextFieldPaddingWithoutImages:serviceNameField];
    [contactField addTextFieldPaddingWithoutImages:contactField];
    
    [addressTextView setTextContainerInset:UIEdgeInsetsMake(9, 5, 0,0)];
    [addressTextView setPlaceholder:@"Address"];
    
    [remarksTextView setTextContainerInset:UIEdgeInsetsMake(9, 5, 0,0)];
    [remarksTextView setPlaceholder:@"Remarks"];
    
    [callButton.layer setShadowColor:[UIColor darkGrayColor].CGColor];
    [callButton.layer setShadowOpacity:1.0];
    [callButton.layer setShadowRadius:2.0];
    [callButton.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    [callButton.layer setBorderWidth:1.0];
    [callButton.layer setBorderColor:(__bridge CGColorRef)([UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0])];
    
}

-(void) setCornerRadius
{
    [currencyContainer setCornerRadius:1.0f];
    [serviceChargesLabel setCornerRadius:1.0f];
    [serviceNameField setCornerRadius:1.0f];
    [nameField setCornerRadius:1.0f];
    [contactField setCornerRadius:1.0f];
    [dateTimeView setCornerRadius:1.0f];
    [callButton setCornerRadius:1.0f];
    [addressTextView setCornerRadius:1.0f];
    [remarksTextView setCornerRadius:1.0f];
    [mapView setCornerRadius:1.0f];
    
}
#pragma mark - end

#pragma mark - Webservice methods

-(void)getBookingInformationFromServer
{
    [[WebService sharedManager]getBookingInformation:bookingID success:^(id getBookingInformation)
     {
         bookingInformationData=[getBookingInformation mutableCopy];
         [self displayBookingData];
         [myDelegate StopIndicator];
         
     } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
     }] ;
    
}

-(void) displayBookingData
{
    BookingInformationModel *data =[bookingInformationData objectAtIndex:0];
    serviceNameField.text=data.serviceName;
    serviceChargesLabel.text=data.serviceCharges;
    nameField.text=data.customerName;
    contactField.text=data.customerContact;
    destLat=data.latitude;
    destLong=data.longitude;
    if ([data.customerAddress isEqualToString: @""])
    {
        addressTextView.text=@"NA";
        mapView.hidden=YES;
        activityIndicator.hidden=YES;
        [activityIndicator stopAnimating];
        self.bookingInfoViewHeightConstraint.constant=150;
        self.leadingSpaceBookingInfoView.constant=0;
        self.trailingSpaceBookingInfoView.constant=0;
        
    }
    else
    {
        addressTextView.text=data.customerAddress;
        mapView.hidden=NO;
        spLocation=[NSString stringWithFormat:@"%@,%@", destLat,destLong];
        [self addMapPAth];
    }
    if ([data.remarks isEqualToString: @""])
    {
        remarksTextView.text=@"NA";
        
    }
    else
    {
        remarksTextView.text=data.remarks;
        
    }
    
    dateLabel.text=[myDelegate formatDateToDisplay:data.bookingDate];
    if ([data.endTime isEqualToString:@"23:59"]) {
        data.endTime=@"24:00";
    }
    bookingTimeLabel.text=[NSString stringWithFormat:@"%@ %@ %@",data.startTime,@"to",data.endTime];
    
}


#pragma mark - end

#pragma mark - Call Action

- (IBAction)callBtn:(id)sender
{
    NSString *phoneNumber = [@"tel://" stringByAppendingString:contactField.text];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    
}
#pragma mark - end

#pragma mark - end

-(void) addMapPAth
{
    dispatch_async(kBgQueue, ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        activityIndicator.hidden=NO;
        [activityIndicator startAnimating];
        NSString *strUrl;
        strUrl=[NSString stringWithFormat:@"%@origin=%@&destination=%@&sensor=true",kBaseUrl,spLocation,addressTextView.text];
        
        strUrl=[strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *data =[NSData dataWithContentsOfURL:[NSURL URLWithString:strUrl]];
        
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
    
    
}

#pragma mark - json parser

- (void)fetchedData:(NSData *)responseData {
    NSError* error;
    
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData //1
                          
                          options:kNilOptions
                          error:&error];
    NSArray *arrRouts=[json objectForKey:@"routes"];
    if ([arrRouts isKindOfClass:[NSArray class]]&&arrRouts.count==0)
    {
        [activityIndicator stopAnimating];
        activityIndicator.hidden=YES;
        UIAlertView *alrt=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"Didn't find direction." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alrt show];
        
        return;
    }
    NSArray* arrpolyline = [[[json valueForKeyPath:@"routes.legs.steps.polyline.points"] objectAtIndex:0] objectAtIndex:0]; //2
    double srcLat=[[[[json valueForKeyPath:@"routes.legs.start_location.lat"] objectAtIndex:0] objectAtIndex:0] doubleValue];
    double srcLong=[[[[json valueForKeyPath:@"routes.legs.start_location.lng"] objectAtIndex:0] objectAtIndex:0] doubleValue];
    double destLat1=[[[[json valueForKeyPath:@"routes.legs.end_location.lat"] objectAtIndex:0] objectAtIndex:0] doubleValue];
    double destLong1=[[[[json valueForKeyPath:@"routes.legs.end_location.lng"] objectAtIndex:0] objectAtIndex:0] doubleValue];
    CLLocationCoordinate2D sourceCordinate = CLLocationCoordinate2DMake(srcLat, srcLong);
    CLLocationCoordinate2D destCordinate = CLLocationCoordinate2DMake(destLat1, destLong1);
    
    
    [self addAnnotationSrcAndDestination:sourceCordinate :destCordinate];
    //    NSArray *steps=[[aary objectAtIndex:0]valueForKey:@"steps"];
    
    //    replace lines with this may work
    
    NSMutableArray *polyLinesArray =[[NSMutableArray alloc]initWithCapacity:0];
    
    for (int i = 0; i < [arrpolyline count]; i++)
    {
        NSString* encodedPoints = [arrpolyline objectAtIndex:i] ;
        MKPolyline *route = [self polylineWithEncodedString:encodedPoints];
        [polyLinesArray addObject:route];
    }
    
    [mapView addOverlays:polyLinesArray];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [activityIndicator stopAnimating];
    activityIndicator.hidden=YES;
}

#pragma mark - add annotation on source and destination

-(void)addAnnotationSrcAndDestination :(CLLocationCoordinate2D )srcCord :(CLLocationCoordinate2D)destCord
{
    MKPointAnnotation *sourceAnnotation = [[MKPointAnnotation alloc]init];
    MKPointAnnotation *destAnnotation = [[MKPointAnnotation alloc]init];
    sourceAnnotation.coordinate=srcCord;
    destAnnotation.coordinate=destCord;
    //    sourceAnnotation.title=spLocation;
    //
    //    destAnnotation.title=addressTextView.text;
    
    [mapView addAnnotation:sourceAnnotation];
    [mapView addAnnotation:destAnnotation];
    
    //    MKCoordinateRegion region;
    //
    //    MKCoordinateSpan span;
    //    span.latitudeDelta=2;
    //    span.latitudeDelta=2;
    //    region.center=srcCord;
    //    region.span=span;
    //
    //
    //    mapView.region=region;
}

#pragma mark - decode map polyline

- (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString {
    const char *bytes = [encodedString UTF8String];
    NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger idx = 0;
    
    NSUInteger count = length / 4;
    CLLocationCoordinate2D *coords = calloc(count, sizeof(CLLocationCoordinate2D));
    NSUInteger coordIdx = 0;
    
    float latitude = 0;
    float longitude = 0;
    while (idx < length) {
        char byte = 0;
        int res = 0;
        char shift = 0;
        
        do {
            byte = bytes[idx++] - 63;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
        latitude += deltaLat;
        
        shift = 0;
        res = 0;
        
        do {
            byte = bytes[idx++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
        longitude += deltaLon;
        
        float finalLat = latitude * 1E-5;
        float finalLon = longitude * 1E-5;
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(finalLat, finalLon);
        coords[coordIdx++] = coord;
        
        if (coordIdx == count) {
            NSUInteger newCount = count + 10;
            coords = realloc(coords, newCount * sizeof(CLLocationCoordinate2D));
            count = newCount;
        }
    }
    
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:coordIdx];
    free(coords);
    
    return polyline;
}
#pragma mark - map overlay
- (MKOverlayView *)mapView:(MKMapView *)mapView
            viewForOverlay:(id<MKOverlay>)overlay {
    
    MKPolylineView *overlayView = [[MKPolylineView alloc] initWithOverlay:overlay];
    overlayView.lineWidth = 2;
    overlayView.strokeColor = [UIColor purpleColor];
    overlayView.fillColor = [[UIColor purpleColor] colorWithAlphaComponent:0.1f];
    return overlayView;
    
}

#pragma mark - map annotation
- (MKAnnotationView *)mapView:(MKMapView *)mapView1 viewForAnnotation:(id <MKAnnotation>)annotation
{
    if (annotation==mapView.userLocation) {
        return nil;
    }
    static NSString *annotaionIdentifier=@"annotationIdentifier";
    MKPinAnnotationView *aView=(MKPinAnnotationView*)[mapView1 dequeueReusableAnnotationViewWithIdentifier:annotaionIdentifier ];
    if (aView==nil) {
        
        aView=[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotaionIdentifier];
        aView.pinColor = MKPinAnnotationColorRed;
        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        //        aView.image=[UIImage imageNamed:@"arrow"];
        aView.animatesDrop=TRUE;
        aView.canShowCallout = YES;
        aView.calloutOffset = CGPointMake(-5, 5);
    }
    
    return aView;
}

@end
