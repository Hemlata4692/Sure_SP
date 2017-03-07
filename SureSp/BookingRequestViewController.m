//
//  BookingRequestViewController.m
//  Sure_sp
//
//  Created by Ranosys on 24/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "BookingRequestViewController.h"
#import "UITextField+Padding.h"
#import "UIPlaceHolderTextView.h"
#import "UIView+RoundedCorner.h"
#import "BSKeyboardControls.h"
#import "UITextField+Validations.h"
#import "UITextView+Validations.h"
#import "PendingConfirmationModel.h"
#import "BookingInformationModel.h"

@interface BookingRequestViewController ()<BSKeyboardControlsDelegate>
{
    NSString *dateString;
    NSString *serviceStartTime;
}
@property (weak, nonatomic) IBOutlet UILabel *serviceName;
@property (weak, nonatomic) IBOutlet UILabel *serviceType;
@property (weak, nonatomic) IBOutlet UILabel *chargesPerHour;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *addressView;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *remarksView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneNoField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIView *dateTimeView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *rejectOutlet;
@property (weak, nonatomic) IBOutlet UIButton *confirmOutlet;
@property(nonatomic,retain)NSMutableArray * bookingInfoData;

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

@end

@implementation BookingRequestViewController
@synthesize serviceName,serviceType,chargesPerHour,description,timerLabel,dateLabel;
@synthesize phoneNoField,nameField,addressView,remarksView,dateTimeView,scrollView,rejectOutlet,confirmOutlet;

@synthesize bookingID,bookingInfoData;

#pragma mark -view life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.title=@"Booking Request";
    // Do any additional setup after loading the view.
    
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
    
    [self addPaddingToFields];
    [self setCornerRadius];
    [self addShadowOnButtons];
//    if (myDelegate.messageType==4 || myDelegate.messageType==5)
//    {
//        rejectOutlet.hidden =YES;
//        confirmOutlet.hidden=YES;
//        myDelegate.messageType=0;
//    }
    [myDelegate StopIndicator];
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getBookingInformation) withObject:nil afterDelay:.1];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) addPaddingToFields
{
    [nameField addTextFieldPaddingWithoutImages:nameField];
    [phoneNoField addTextFieldPaddingWithoutImages:phoneNoField];
    
    [addressView setTextContainerInset:UIEdgeInsetsMake(9, 5, 0,0)];
    [addressView setPlaceholder:@"NA"];
    
    [remarksView setTextContainerInset:UIEdgeInsetsMake(9, 5, 0,0)];
    [remarksView setPlaceholder:@"NA"];
    
}

-(void) setCornerRadius
{
    [nameField setCornerRadius:1.0f];
    [phoneNoField setCornerRadius:1.0f];
    [addressView setCornerRadius:1.0f];
    [remarksView setCornerRadius:1.0f];
    [dateTimeView setCornerRadius:1.0f];
}

-(void) addShadowOnButtons
{
    
    [rejectOutlet.layer setShadowColor:[UIColor darkGrayColor].CGColor];
    [rejectOutlet.layer setShadowOpacity:1.0];
    [rejectOutlet.layer setShadowRadius:4.0];
    [rejectOutlet.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    [rejectOutlet.layer setBorderWidth:1.0];
    [rejectOutlet.layer setBorderColor:(__bridge CGColorRef)([UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0])];
    [rejectOutlet.layer setCornerRadius:1.0];
    
    [confirmOutlet.layer setShadowColor:[UIColor darkGrayColor].CGColor];
    [confirmOutlet.layer setShadowOpacity:1.0];
    [confirmOutlet.layer setShadowRadius:4.0];
    [confirmOutlet.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    [confirmOutlet.layer setBorderWidth:1.0];
    [confirmOutlet.layer setBorderColor:(__bridge CGColorRef)([UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0])];
    [confirmOutlet.layer setCornerRadius:1.0];
}
#pragma mark -end

#pragma mark - Textfield methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    [self.keyboardControls setActiveField:textField];
    if (textField == nameField) {
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    else if (textField == phoneNoField)
    {
        [scrollView setContentOffset:CGPointMake(0, phoneNoField.frame.origin.y-5) animated:YES];
    }
    
    
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.keyboardControls setActiveField:textView];
    if (textView == addressView) {
        [scrollView setContentOffset:CGPointMake(0, addressView.frame.origin.y-5) animated:YES];
    }
    else if (textView == remarksView)
    {
        [scrollView setContentOffset:CGPointMake(0, remarksView.frame.origin.y-5) animated:YES];
    }
    
    
    
}
- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
    UIView *view;
    
    if ([[UIDevice currentDevice].systemVersion floatValue]< 7.0) {
        view = field.superview.superview;
    } else {
        view = field.superview.superview.superview;
    }
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [keyboardControls.activeField resignFirstResponder];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
}
#pragma mark - end

#pragma mark - Webservice methods

-(void)getBookingInformation
{
    self.bookingID=myDelegate.bookingId;
    [[WebService sharedManager]getBookingInformation:bookingID success:^(id getBookingInformation)
     {
         bookingInfoData=[getBookingInformation mutableCopy];
          BookingInformationModel *customerInfo =[bookingInfoData objectAtIndex:0];
         [self displayCustomerImformation:customerInfo];
         [myDelegate StopIndicator];
         
     } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
     }];
    
}

-(void)displayCustomerImformation : (BookingInformationModel *)model
{
    serviceName.text = model.serviceName;
    nameField.text = model.customerName;
    dateLabel.text = [myDelegate formatDateToDisplay:model.bookingDate];
    dateString=model.bookingDate;
    if ([model.endTime isEqualToString:@"23:59"]) {
        model.endTime=@"24:00";
    }
    timerLabel.text =[NSString stringWithFormat:@"%@ to %@",model.startTime,model.endTime];
    serviceStartTime=model.startTime;
    chargesPerHour.text = model.serviceCharges;
    if ([model.serviceType intValue]==1)
    {
        serviceType.text=@"On-Site";
    }
    else
    {
        serviceType.text=@"In-Shop";
    }
    phoneNoField.text=model.customerContact;
    if ([model.customerAddress isEqualToString:@""]) {
        addressView.text=@"NA";
    }
    else
    {
    addressView.text=model.customerAddress;
    }
    if ([model.remarks isEqualToString:@""]) {
        remarksView.text=@"NA";
    }
    else
    {
        remarksView.text=model.remarks;
    }

}
-(void)callRejectWebService
{
    [[WebService sharedManager]rejectBooking:bookingID success:^(id responseObject)
     {
         [myDelegate StopIndicator];
         
         UIAlertView *  alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:[responseObject objectForKey:@"Message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         alert.tag=1;
         [alert show];
         
     } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
     }] ;
}

-(void)callConfirmWebService
{
    [[WebService sharedManager]acceptBooking:bookingID success:^(id responseObject)
     {
         [myDelegate StopIndicator];
         UIAlertView *  alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:[responseObject objectForKey:@"Message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         alert.tag=1;
         [alert show];
         
         
     } failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
     }] ;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag==1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
}

#pragma mark - end

#pragma mark - Button actions
- (IBAction)rejectBookingAction:(id)sender
{
    [myDelegate ShowIndicator];
    [self performSelector:@selector(callRejectWebService) withObject:nil afterDelay:.1];
}
- (IBAction)confirmBookingAction:(id)sender
{
    [self performConfirmValidations];

}

-(void)performConfirmValidations
{
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc]init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter1 setLocale:locale];
    [dateFormatter1 setDateFormat:@"dd-MMMM-yyyy"];
    NSString *tempCurrentDate=[dateFormatter1 stringFromDate:[NSDate date]];
    NSDate *currentDate = [dateFormatter1 dateFromString:tempCurrentDate];
    NSDate *serverDate = [dateFormatter1 dateFromString:dateString];
    
    [dateFormatter1 setDateFormat:@"HH:mm"];
    
    NSString *currentTime=[dateFormatter1 stringFromDate:[NSDate date]];
    
    if ([serverDate compare:currentDate] == NSOrderedAscending)
    {
        
      UIAlertView*  alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"You cannot confirm this booking as service time has passed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    else if (([serverDate compare:currentDate] != NSOrderedDescending) && [[dateFormatter1 dateFromString:serviceStartTime] compare:[dateFormatter1 dateFromString:currentTime]] == NSOrderedAscending)
    {
        
       
        
        UIAlertView*  alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"You cannot confirm this booking as service time has passed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    else
    {
        [myDelegate ShowIndicator];
        [self performSelector:@selector(callConfirmWebService) withObject:nil afterDelay:.1];
    }

}
#pragma mark - end
@end
