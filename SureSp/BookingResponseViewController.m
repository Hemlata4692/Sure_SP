//
//  BookingResponseViewController.m
//  Sure_sp
//
//  Created by Ranosys on 05/06/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "BookingResponseViewController.h"
#import "UITextField+Padding.h"
#import "UIPlaceHolderTextView.h"
#import "UIView+RoundedCorner.h"
#import "BSKeyboardControls.h"
#import "UITextField+Validations.h"
#import "UITextView+Validations.h"
#import "PendingConfirmationModel.h"
#import "BookingInformationModel.h"
#import "SWRevealViewController.h"

@interface BookingResponseViewController ()<BSKeyboardControlsDelegate>
{
    UIBarButtonItem *backMenuButton,*menuButton;

    NSString *dateString;
    NSString *serviceStartTime;
}


@property (weak, nonatomic) IBOutlet UILabel *acceptRejectLbl;
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
@property (weak, nonatomic) IBOutlet UIImageView *acceptRejImg;

@property(nonatomic,retain)NSMutableArray * bookingInfoData;

@end

@implementation BookingResponseViewController

@synthesize serviceName,serviceType,chargesPerHour,description,timerLabel,dateLabel;
@synthesize phoneNoField,nameField,addressView,remarksView,dateTimeView,scrollView;
@synthesize bookingID,bookingInfoData,acceptRejectLbl,acceptRejImg;


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
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"Booking Request";
    // Do any additional setup after loading the view.
    
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back"] secondImage:[UIImage imageNamed:@"menu.png"]];
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
    
    [self addPaddingToFields];
    [self setCornerRadius];
     
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

#pragma mark -end

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
    if (myDelegate.messageType==4)
    {
        acceptRejectLbl.text=@"The following booking has been accepted by the customer.";
        acceptRejImg.image=[UIImage imageNamed:@"click"];
    }
    else if (myDelegate.messageType==5)
    {
        acceptRejectLbl.textColor=[UIColor colorWithRed:253.0/255.0 green:68.0/255.0 blue:63.0/255.0 alpha:1.0];
        acceptRejectLbl.text=@"The following booking has been rejected by the customer.";
        acceptRejImg.image=[UIImage imageNamed:@"close_rej"];
    }
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
#pragma mark - end
@end
