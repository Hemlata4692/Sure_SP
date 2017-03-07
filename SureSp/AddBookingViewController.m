//
//  AddBookingViewController.m
//  Sure_sp
//
//  Created by Ranosys on 16/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "AddBookingViewController.h"
#import "UIView+RoundedCorner.h"
#import "UITextView+Validations.h"
#import "UITextField+Padding.h"
#import "UIPlaceHolderTextView.h"
#import "UITextField+Validations.h"
#import "UITextView+Validations.h"
#import <EventKit/EventKit.h>

@interface AddBookingViewController ()
{
    NSDictionary *serviceListDict;
    NSMutableArray *serviceListArray;
    NSString *serviceID;
    double serviceSlotHrs;
    NSString *serviceCharges;
    BOOL checkSlots;
    int serviceType;
    __weak IBOutlet UIButton *AddressButton;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *bookingView;

@property (weak, nonatomic) IBOutlet UITextField *serviceNameField;
@property (weak, nonatomic) IBOutlet UIButton *serviceNameBtn;
@property (weak, nonatomic) IBOutlet UILabel *hourLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UIView *timeDateView;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *remarksField;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *addressTextView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *calendarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *timerImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *currencyView;
@property (weak, nonatomic) IBOutlet UIToolbar *pickerToolbar;

@property (weak, nonatomic) IBOutlet UIImageView *currencyImageView;

@property (weak, nonatomic) IBOutlet UIPickerView *serviceListPicker;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@end

@implementation AddBookingViewController
@synthesize scrollView,bookingView, serviceNameBtn,serviceNameField,hourLabel,nameField,phoneField,timeDateView,remarksField,addressTextView,dateLabel,timeLabel,currencyImageView,currencyView,calendarImageView,timerImageView;
@synthesize bookingDate,bookingStartTime,bookingEndTime,calenderObj,calenderData;


#pragma mark - View life cycle
//method to grant permission for calendar.
-(void)accessToCalenderForiOS8
{
    
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        // iOS 6 and later
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {
                // code here for when the user allows your app to access the calendar
                //[self performCalendarActivity:eventStore];
            } else {
                // code here for when the user does NOT allow your app to access the calendar
            }
        }];
    } else {
        // code here for iOS < 6.0
        //[self performCalendarActivity:eventStore];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"Add Booking";
    checkSlots=true;
    [self accessToCalenderForiOS8];
    [self addTextFieldPadding];
    [self roundedCorner];
    [self setframesOfObjects];
    AddressButton.hidden = YES;
    serviceListArray=[[NSMutableArray alloc]init];
    
    NSArray * fieldArray = @[nameField,phoneField,addressTextView,remarksField];
    //Keyboard toolbar action to display toolbar with keyboard to move next,previous
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fieldArray]];
    [self.keyboardControls setDelegate:self];
    
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getServiceListFromServer) withObject:nil afterDelay:.1];
    
    
    dateLabel.text=bookingDate;
    if ([bookingEndTime isEqualToString:@"00:00"]) {
        bookingEndTime=@"24:00";
    }
    timeLabel.text=[NSString stringWithFormat:@"%@ %@ %@",bookingStartTime,@"to",bookingEndTime];
    
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//method to add placeholder and and padding to fields
-(void)addTextFieldPadding
{
    nameField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [serviceNameField addTextFieldPaddingWithoutImages:serviceNameField];
    [nameField addTextFieldPaddingWithoutImages:nameField];
    [phoneField addTextFieldPaddingWithoutImages:phoneField];
    [addressTextView setPlaceholder:@"Address*"];
    [addressTextView setTextContainerInset:UIEdgeInsetsMake(9, 5, 0,0)];
    [remarksField setPlaceholder:@"Remarks"];
    [remarksField setTextContainerInset:UIEdgeInsetsMake(9, 5, 0,0)];
}
//method to round corner of fields
-(void) roundedCorner
{
    [nameField setCornerRadius:1.0f];
    [serviceNameField setCornerRadius:1.0f];
    [serviceNameBtn setCornerRadius:1.0f];
    [hourLabel setCornerRadius:1.0f];
    [phoneField setCornerRadius:1.0f];
    [remarksField setCornerRadius:1.0f];
    [addressTextView setCornerRadius:1.0f];
    
}
#pragma mark - end

#pragma mark - Webservice methods

//method to get service list from server.
-(void)getServiceListFromServer
{
    [[WebService sharedManager]getServiceList:^(id responseObject) {
        
        serviceListDict=(NSDictionary *)responseObject;
        
        
    } failure:^(NSError *error) {
        
    }] ;
    
}
//method to set local lotification before half an hour of booking
-(void)reminderAlert : (NSDictionary *)dataDict

{
    
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:locale];
    [dateFormat setDateFormat:@"dd-MMMM-yyyy"];
    NSDate *date =[dateFormat dateFromString:dateLabel.text];
    [dateFormat setDateFormat:@"MMM d,yyyy"];
    NSString *fireDate=[dateFormat stringFromDate:date];
    [dateFormat setDateFormat:@"HH:mm"];
    NSDate *fireToTime=[dateFormat dateFromString:bookingStartTime];
    [dateFormat setDateFormat:@"hh:mm a"];
    NSString *CheckTOTime = [dateFormat stringFromDate:fireToTime];
    NSString *startdate1= [NSString stringWithFormat:@"%@ %@",fireDate,CheckTOTime];
    [dateFormat setDateFormat:@"MMM d,yyyy hh:mm a"];
    NSDate *startDate = [dateFormat dateFromString:startdate1];
    NSTimeInterval notiInterval =[startDate timeIntervalSinceDate:[NSDate date]] -30*60;
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:notiInterval];
    notification.alertBody = [NSString stringWithFormat:@"%@ %@ %@ %@",@"You have booking appointment for",serviceNameField.text,@"at",bookingStartTime];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 0;
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:[dataDict objectForKey:@"BookingId"] forKey:@"BookingId"];
    notification.userInfo = infoDict;
    NSMutableArray *notifications = [[NSMutableArray alloc] init];
    [notifications addObject:notification];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
}
//method to request booking to sp
-(void)bookRequestWebService
{
    if ([bookingEndTime isEqualToString:@"24:00"]) {
        bookingEndTime=@"23:59";
    }
    [[WebService sharedManager] addBookingt:serviceID customerName:nameField.text customerContact:phoneField.text bookingDate:dateLabel.text remarks:remarksField.text address:addressTextView.text startTime:bookingStartTime endTime:bookingEndTime success:^(id responseObject)
     {
         [self reminderAlert:responseObject];
         UIAlertView *  alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:[responseObject objectForKey:@"Message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         alert.tag=1;
         [alert show];
         
     }
                                    failure:^(NSError *error)
     {
         
     }];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag==1)
    {
        calenderObj.dateString=bookingDate;
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
}

#pragma mark - end


#pragma mark - Textfield methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self hidePickerWithAnimation];
    [self.keyboardControls setActiveField:textField];
    if (textField == phoneField) {
        [scrollView setContentOffset:CGPointMake(0, phoneField.frame.origin.y) animated:YES];
    }
    
    
    
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.keyboardControls setActiveField:textView];
    if (textView == remarksField)
    {
        [scrollView setContentOffset:CGPointMake(0, remarksField.frame.origin.y-12) animated:YES];
    }
    else if (textView==addressTextView)
    {
        [scrollView setContentOffset:CGPointMake(0, addressTextView.frame.origin.y-12) animated:YES];
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

#pragma mark - Method for reframing Objects

-(void) removeAutolayouts
{
    scrollView.translatesAutoresizingMaskIntoConstraints=YES;
    bookingView.translatesAutoresizingMaskIntoConstraints=YES;
    currencyView.translatesAutoresizingMaskIntoConstraints=YES;
    currencyImageView.translatesAutoresizingMaskIntoConstraints=YES;
    serviceNameField.translatesAutoresizingMaskIntoConstraints=YES;
    serviceNameBtn.translatesAutoresizingMaskIntoConstraints = YES;
    hourLabel.translatesAutoresizingMaskIntoConstraints = YES;
    nameField.translatesAutoresizingMaskIntoConstraints =YES;
    phoneField.translatesAutoresizingMaskIntoConstraints =YES;
    timeDateView.translatesAutoresizingMaskIntoConstraints =YES;
    calendarImageView.translatesAutoresizingMaskIntoConstraints =YES;
    timerImageView.translatesAutoresizingMaskIntoConstraints =YES;
    remarksField.translatesAutoresizingMaskIntoConstraints =YES;
    addressTextView.translatesAutoresizingMaskIntoConstraints=YES;
    addressTextView.translatesAutoresizingMaskIntoConstraints =YES;
    dateLabel.translatesAutoresizingMaskIntoConstraints =YES;
    timeLabel.translatesAutoresizingMaskIntoConstraints =YES;
    addressTextView.translatesAutoresizingMaskIntoConstraints = YES;
    _serviceListPicker.translatesAutoresizingMaskIntoConstraints =YES;
    _pickerToolbar.translatesAutoresizingMaskIntoConstraints=YES;
    
}
-(void)setframesOfObjects
{
    [self removeAutolayouts];
    scrollView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    bookingView.frame=CGRectMake(0, bookingView.frame.origin.y, self.view.frame.size.width, bookingView.frame.size.height+150);
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, self.bookingView.frame.size.height, 0);
    currencyView.hidden=YES;
    currencyImageView.hidden=YES;
    hourLabel.hidden=YES;
    serviceNameField.frame=CGRectMake(16,serviceNameField.frame.origin.y-64,self.view.frame.size.width-32,serviceNameField.frame.size.height);
    serviceNameBtn.frame=CGRectMake(16,serviceNameBtn.frame.origin.y-64,self.view.frame.size.width-32,serviceNameBtn.frame.size.height);
    serviceNameBtn.imageEdgeInsets = UIEdgeInsetsMake(0, serviceNameBtn.frame.size.width-34, 0, 0);
    [self setframesToReuse];
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, self.bookingView.frame.size.height, 0);
}

-(void)setframesToReuse
{
    nameField.frame=CGRectMake(16,serviceNameBtn.frame.origin.y+serviceNameField.frame.size.height+14,self.view.frame.size.width-32,nameField.frame.size.height);
    phoneField.frame=CGRectMake(16,nameField.frame.origin.y+nameField.frame.size.height+14,self.view.frame.size.width-32,phoneField.frame.size.height);
    timeDateView.frame=CGRectMake(16,phoneField.frame.origin.y+phoneField.frame.size.height+14,self.view.frame.size.width-32,timeDateView.frame.size.height);
    
    calendarImageView.frame=CGRectMake(14,calendarImageView.frame.origin.y,calendarImageView.frame.size.width,calendarImageView.frame.size.height);
    dateLabel.frame=CGRectMake(calendarImageView.frame.origin.x+calendarImageView.frame.size.width+8,dateLabel.frame.origin.y,dateLabel.frame.size.width,dateLabel.frame.size.height);
    
    timerImageView.frame=CGRectMake(self.timeDateView.frame.size.width-(timeLabel.frame.size.width+14+timerImageView.frame.size.width+8),timerImageView.frame.origin.y,timerImageView.frame.size.width,timerImageView.frame.size.height);
    timeLabel.frame=CGRectMake(timeDateView.frame.size.width- (14+timeLabel.frame.size.width),timeLabel.frame.origin.y,timeLabel.frame.size.width,timeLabel.frame.size.height);
    
    
    addressTextView.frame=CGRectMake(16,timeDateView.frame.origin.y+timeDateView.frame.size.height+14,self.view.frame.size.width-32,addressTextView.frame.size.height);
    remarksField.frame=CGRectMake(16,addressTextView.frame.origin.y+addressTextView.frame.size.height+14,self.view.frame.size.width-32,remarksField.frame.size.height);
    AddressButton.frame =addressTextView.frame;
}

-(void)reframeOfObjects
{
    if (![serviceNameField.text isEqual:@""])
    {
        [self removeAutolayouts];
        currencyView.hidden=NO;
        currencyImageView.hidden=NO;
        hourLabel.hidden=NO;
        
        currencyView.frame=CGRectMake(16,bookingView.frame.origin.y+16,(self.view.frame.size.width/2)-30,currencyView.frame.size.height);
        currencyImageView.frame=CGRectMake(8,currencyImageView.frame.origin.y,currencyImageView.frame.size.width,currencyImageView.frame.size.height);
        hourLabel.frame=CGRectMake(currencyImageView.frame.origin.x+currencyImageView.frame.size.width,hourLabel.frame.origin.y,hourLabel.frame.size.width+2,hourLabel.frame.size.height);
        
        serviceNameField.frame=CGRectMake(16,currencyView.frame.origin.y+currencyView.frame.size.height+14,self.view.frame.size.width-32,serviceNameField.frame.size.height);
        serviceNameBtn.frame=CGRectMake(16,currencyView.frame.origin.y+currencyView.frame.size.height+14,self.view.frame.size.width-32,serviceNameBtn.frame.size.height);
        serviceNameBtn.imageEdgeInsets = UIEdgeInsetsMake(0, serviceNameBtn.frame.size.width-34, 0, 0);
        [self setframesToReuse];
    }
}


#pragma mark - Picker Methods




-(void) changeTimeAccSlot
{
    NSString *tempString=[NSString stringWithFormat:@"%.1f",serviceSlotHrs];
    NSArray *subStrings = [tempString componentsSeparatedByString:@"."];
    int firstIntHrs= [[subStrings objectAtIndex:0]intValue];
    int secondIntMin=[[subStrings objectAtIndex:1]intValue];
    
    if (secondIntMin ==5)
    {
        secondIntMin=30;
    }
    else
    {
        secondIntMin=00;
    }
    
    
    NSArray *subStrings1 = [bookingStartTime componentsSeparatedByString:@":"];
    NSString *firstString1 = [subStrings1 objectAtIndex:0];
    int firstInt1=[firstString1 intValue];
    
    NSString *lastString1 = [subStrings1 objectAtIndex:1];
    int secondInt2=[lastString1 intValue];
    
    NSString *finalBookingSlotHrs;
    NSString *endTimeHrs;
    NSString *finalBookingSlotMin=[NSString stringWithFormat:@"%d",secondInt2+secondIntMin];
    if ([finalBookingSlotMin isEqualToString:@"60"])
    {
        finalBookingSlotMin=@"1";
        finalBookingSlotHrs=[NSString stringWithFormat:@"%d",firstInt1+firstIntHrs+[finalBookingSlotMin intValue]];
        endTimeHrs=[NSString stringWithFormat:@"%@:%@",finalBookingSlotHrs,@"00"];
    }
    else
    {
        finalBookingSlotHrs=[NSString stringWithFormat:@"%d",firstInt1+firstIntHrs];
        endTimeHrs=[NSString stringWithFormat:@"%@:%@",finalBookingSlotHrs,finalBookingSlotMin];
    }
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    dateFormatter.dateFormat = @"HH:mm";
    NSDate *date = [dateFormatter dateFromString:endTimeHrs];
    
    //dateFormatter.dateFormat = @"hh:mm";
    endTimeHrs = [dateFormatter stringFromDate:date];
    if (endTimeHrs ==nil) {
        endTimeHrs=@"00:00";
    }
    bookingEndTime=endTimeHrs;
    
}

-(void)hidePickerWithAnimation
{
    scrollView.scrollEnabled=YES;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _serviceListPicker.frame = CGRectMake(_serviceListPicker.frame.origin.x, 1000, self.view.bounds.size.width, _serviceListPicker.frame.size.height);
    _pickerToolbar.frame = CGRectMake(_pickerToolbar.frame.origin.x, 1000, self.view.bounds.size.width, _pickerToolbar.frame.size.height);
    [UIView commitAnimations];
}

-(void) checkAvailibilityOfSlots
{
    checkSlots=true;
    
    NSString *tempStartTime=bookingStartTime;
    
    int slotToBeBooked=serviceSlotHrs/0.5;
    
    for (int i=0; i<slotToBeBooked; i++)
    {
        
        if ([tempStartTime isEqualToString:calenderData.businessEndHours])
        {
            UIAlertView *  alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"You can't book service for this slot." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            checkSlots=false;
            return;
        }
        
        else
        {
            for (int j=0; j<calenderData.bookingsList.count; j++)
            {
                NSMutableDictionary *dataDic=[calenderData.bookingsList objectAtIndex:j];
                
                if ([tempStartTime isEqualToString:[dataDic objectForKey:@"StartTime"]])
                {
                    UIAlertView *  alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"You can't book service for this slot." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    checkSlots=false;
                    return;
                }
                
            }
        }
        
        //increase time by interval of half an hour
        NSArray *subStrings1 = [tempStartTime componentsSeparatedByString:@":"];
        NSString *firstString1 = [subStrings1 objectAtIndex:0];
        int firstInt1=[firstString1 intValue];
        
        NSString *lastString1 = [subStrings1 objectAtIndex:1];
        int secondInt2=[lastString1 intValue];
        
        NSString *finalAvailSlot;
        NSString *startTimeHrs;
        NSString *endTimeMin;
        NSString *endTimeHrs;
        NSString *chkTimeSlot;
        
        if (secondInt2==0)
        {
            endTimeMin=[NSString stringWithFormat:@"%d",secondInt2+30];
            startTimeHrs=[NSString stringWithFormat:@"%d",firstInt1];
            finalAvailSlot=[NSString stringWithFormat:@"%@:%@",startTimeHrs,endTimeMin];
            chkTimeSlot=[NSString stringWithFormat:@"%@.%@",startTimeHrs,endTimeMin];
        }
        else
        {
            endTimeMin=[NSString stringWithFormat:@"%d",secondInt2+30];
            
            if ([endTimeMin isEqualToString:@"60"])
            {
                endTimeMin=@"1";
                endTimeHrs=[NSString stringWithFormat:@"%d",firstInt1+[endTimeMin intValue]];
                finalAvailSlot=[NSString stringWithFormat:@"%@:%@",endTimeHrs,@"00"];
                chkTimeSlot=[NSString stringWithFormat:@"%@:%@",endTimeHrs,@"00"];
            }
            
        }
        if ([chkTimeSlot floatValue]>24.00)
        {
            UIAlertView *  alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"You can't book service for this slot." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            checkSlots=false;
            return;
        }
        if ([finalAvailSlot isEqualToString:@"24:00"])
        {
            tempStartTime=finalAvailSlot;
        }
        else{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *locale = [[NSLocale alloc]
                                initWithLocaleIdentifier:@"en_US"];
            [dateFormatter setLocale:locale];
            dateFormatter.dateFormat = @"HH:mm";
            NSDate *date = [dateFormatter dateFromString:finalAvailSlot];
            
            finalAvailSlot = [dateFormatter stringFromDate:date];
            
            tempStartTime=finalAvailSlot;
        }
    }
    
}


#pragma mark - end

#pragma mark - Pickerview Delegate Methods


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
    
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return serviceListArray.count;
    
}



-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [serviceListArray objectAtIndex:row];
    
    
}

#pragma mark - end

#pragma mark - IButton Actions
- (IBAction)toolBarDoneClicked:(id)sender
{
    if (serviceListArray.count>0)
    {
        
        NSInteger index = [_serviceListPicker selectedRowInComponent:0];
        serviceNameField.text=[serviceListArray objectAtIndex:index];
        NSArray * tmpary = [serviceListDict objectForKey:@"ServiceResponse"];
        NSDictionary * tempDict =[tmpary objectAtIndex:index];
        serviceID=[tempDict objectForKey:@"ServiceId"];
        serviceSlotHrs=[[tempDict objectForKey:@"SlotDurationHrs"]doubleValue];
        serviceCharges=[tempDict objectForKey:@"ServiceCharges"];
        serviceType =  [[tempDict objectForKey:@"ServiceType"]intValue];
        hourLabel.text=serviceCharges;
        if (serviceType==2)
        {
            addressTextView.text = @"";
            addressTextView.editable = NO;
            AddressButton.hidden = NO;
            [addressTextView setPlaceholder:@"Address"];
            addressTextView.alpha = .5;
            self.keyboardControls.fields = nil;
            NSArray * fieldArray = @[nameField,phoneField,remarksField];
            self.keyboardControls.fields = fieldArray;
            
        }
        else
        {
            AddressButton.hidden = YES;
            addressTextView.editable = YES;
            [addressTextView setPlaceholder:@"Address*"];
            addressTextView.alpha = 1;
            self.keyboardControls.fields = nil;
            NSArray * fieldArray = @[nameField,phoneField,addressTextView,remarksField];
            self.keyboardControls.fields = fieldArray;
            
        }
        [self changeTimeAccSlot];
        if ([bookingEndTime isEqualToString:@"00:00"]) {
            bookingEndTime=@"24:00";
        }
        timeLabel.text=[NSString stringWithFormat:@"%@ %@ %@",bookingStartTime,@"to",bookingEndTime];
    }
    [self hidePickerWithAnimation];
    [self reframeOfObjects];
}

- (IBAction)getServiceList:(id)sender
{
    [[self.keyboardControls activeField]resignFirstResponder];
    scrollView.scrollEnabled=NO;
    NSArray * tempAry  = [serviceListDict objectForKey:@"ServiceResponse"];
    [serviceListArray removeAllObjects];
    for (int i = 0; i<tempAry.count; i++)
    {
        NSDictionary * tempDict =[tempAry objectAtIndex:i];
        [serviceListArray addObject:[tempDict objectForKey:@"Name"]];
    }
    [_serviceListPicker reloadAllComponents];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _serviceListPicker.frame = CGRectMake(_serviceListPicker.frame.origin.x, self.view.bounds.size.height-_serviceListPicker.frame.size.height , self.view.bounds.size.width, _serviceListPicker.frame.size.height);
    _pickerToolbar.frame = CGRectMake(_pickerToolbar.frame.origin.x, _serviceListPicker.frame.origin.y-44, self.view.bounds.size.width, _pickerToolbar.frame.size.height);
    [UIView commitAnimations];
}
- (IBAction)saveAction:(id)sender
{
    if([self performValidations])
    {
        [self checkAvailibilityOfSlots];
        if (checkSlots==true)
        {
            
            [myDelegate ShowIndicator];
            [self performSelector:@selector(bookRequestWebService) withObject:nil afterDelay:.1];
            
            
        }
    }
    
}

- (BOOL)performValidations
{
    UIAlertView *alert;
    if ([serviceNameField isEmpty] || [nameField isEmpty] || [phoneField isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please fill in all mandatory(*) fields." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if (serviceType==1 && [addressTextView isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please fill in all mandatory(*) fields." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    return YES;
}


#pragma mark - end
@end
