//
//  MyCalenderViewController.m
//  Sure_sp
//
//  Created by Ranosys on 24/03/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "MyCalenderViewController.h"
#import "SWRevealViewController.h"
#import "AddBookingViewController.h"
#import "BookingInformationViewController.h"
#import "MyCalenderDataModel.h"


@interface MyCalenderViewController (){
    
    
    int start,last,startMin,lastMin,value;
    NSMutableArray *dateValue, *bookingListArray;
    NSMutableDictionary  *bookingListDic;
    NSMutableDictionary *frameDic;
    MyCalenderDataModel *getCalenderData;
    NSString *slotStartTime;
    NSString *slotEndTime;
    
    __weak IBOutlet UILabel *noRecordsLbl;
    int tag;
}
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIToolbar *pickerToolBar;
@property (weak, nonatomic) IBOutlet UIButton *calenderBtn;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIView *secondView;

@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *leftButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *rightButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *calenderDateOutlet;

- (IBAction)leftArrow:(UIButton *)sender;

- (IBAction)rightArrow:(UIButton *)sender;
- (IBAction)calanderPicker:(UIButton *)sender;

//PopUp view Outlets
@property (weak, nonatomic) IBOutlet UIView *popupBackView;
@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UIButton *blockTheSlotOutlet;
@property (weak, nonatomic) IBOutlet UIButton *addBookingOutlet;

- (IBAction)crossActton:(UIButton *)sender;
- (IBAction)blockTheSlot:(UIButton *)sender;
- (IBAction)addBooking:(UIButton *)sender;


@end

@implementation MyCalenderViewController
@synthesize popupBackView,popupView,blockTheSlotOutlet,addBookingOutlet,dateString;

#pragma mark - Webservice
//method to remove local notification if customer cancelled the booking.
-(void)removeLocalNotification :(NSString *)bookingId
{
    NSArray *notificationArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for(UILocalNotification *notification in notificationArray)
    {
        if([notification.userInfo isEqualToDictionary:[NSDictionary dictionaryWithObject:bookingId forKey:@"BookingId"]])
        {
            // delete this notification
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }

}
//method to delete manually added booking.
-(void)deleteBooking : (NSString *)bookingId
{
    [[WebService sharedManager] deleteBooking:bookingId success:^(id responseObject)
     {
         UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:[responseObject objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
         [alert show];
         [self removeLocalNotification:bookingId];
         [myDelegate ShowIndicator];
         [self performSelector:@selector(callSpCalenderFromServer) withObject:nil afterDelay:.2];
         
     } failure:^(NSError *error)
     {
         
     }];
    
}
//method to get cencelled bookings from customer.
-(void)getCancelledBooking
{
    [[WebService sharedManager] getListOfCancelBooking :^(id responseObject)
     {
         if ([responseObject isKindOfClass:[NSArray class]])
         {
             NSArray * cancelledList =[responseObject mutableCopy];
         for (int i =0; i<cancelledList.count; i++)
         {
             NSDictionary * tempDict = [cancelledList objectAtIndex:i];
             NSArray *notificationArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
             for(UILocalNotification *notification in notificationArray)
             {
                 if([notification.userInfo isEqualToDictionary:[NSDictionary dictionaryWithObject:[tempDict objectForKey:@"BookingId"] forKey:@"BookingId"]])
                 {
                     // delete this notification
                     [[UIApplication sharedApplication] cancelLocalNotification:notification];
                 }
             }
         }
         }
         
     } failure:^(NSError *error)
     {
         
     }];

}
//method to get service provider calendar.
-(void)callSpCalenderFromServer
{
    [[WebService sharedManager] getSpCalender:dateString success:^(id calenderModel)
     {
         [self getCancelledBooking];
         getCalenderData=[[MyCalenderDataModel alloc]init];
         getCalenderData=calenderModel;
         [_scrollview addSubview:_secondView];
         [self customCalanderMethod];
         
     } failure:^(NSError *error)
     {
         
     }];
    
}
//method to block the slot.
-(void)blockSlot
{
    if ([slotEndTime isEqualToString:@"00:00"])
    {
        slotEndTime=@"23:59";
    }
    [ [WebService sharedManager] getblockedSlot:dateString startTime:slotStartTime endTime:slotEndTime success:^(id responseObject)
     {
         UIAlertView *  alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:[responseObject objectForKey:@"Message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
         alert.tag=1;
         [alert show];
         
     } failure:^(NSError *error)
     {
         
     }];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag==1)
    {
        popupBackView.hidden=YES;
        [myDelegate ShowIndicator];
        [self performSelector:@selector(callSpCalenderFromServer) withObject:nil afterDelay:.2];
        
    }
    else if (alertView.tag==5 && buttonIndex==0)
    {
        NSDictionary *tempDict = [getCalenderData.bookingsList objectAtIndex:tag];
        [myDelegate ShowIndicator];
        [self performSelector:@selector(deleteBooking:) withObject:[tempDict objectForKey:@"BookingId"] afterDelay:.1];
        
    }
    
    
}


#pragma mark - end


#pragma mark - View life Cycle
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewDidLoad
{
     [super viewDidLoad];
    self.title = @"My Calendar";
    
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateformate setLocale:locale];
    [dateformate setDateFormat:@"dd-MMMM-YYYY"];
    dateString=[dateformate stringFromDate:[NSDate date]];
    [_calenderDateOutlet setTitle:[self formatDateToDisplay:[NSDate date]] forState:UIControlStateNormal];
    
    [dateformate setDateFormat:@"EEEE"];
    _dayLabel.text=[[dateformate stringFromDate:[NSDate date]]uppercaseString];
    
    
    popupBackView.hidden=YES;
    
    [self setFrameOfObjects];
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [myDelegate ShowIndicator];
    [self performSelector:@selector(callSpCalenderFromServer) withObject:nil afterDelay:.2];
    
}
//method to set frame of objects.
-(void) setFrameOfObjects
{
    _scrollview.translatesAutoresizingMaskIntoConstraints = YES;
    _dayLabel.translatesAutoresizingMaskIntoConstraints = YES;
    _secondView.translatesAutoresizingMaskIntoConstraints = YES;
    _bottomView.translatesAutoresizingMaskIntoConstraints = YES;
    _leftButtonOutlet.translatesAutoresizingMaskIntoConstraints = YES;
    _rightButtonOutlet.translatesAutoresizingMaskIntoConstraints = YES;
    _calenderDateOutlet.translatesAutoresizingMaskIntoConstraints = YES;
     _datePicker.translatesAutoresizingMaskIntoConstraints = YES;
    _pickerToolBar.translatesAutoresizingMaskIntoConstraints =YES;
    _dayLabel.frame=CGRectMake(90, 0, self.view.frame.size.width-90, 40);
    _scrollview.frame=CGRectMake(0, 40, self.view.frame.size.width,  self.view.frame.size.height-144);
    _bottomView.frame=CGRectMake(0, self.scrollview.frame.origin.y+self.scrollview.frame.size.height, self.view.frame.size.width, 40);
    
    _leftButtonOutlet.frame=CGRectMake(8, 0, 40, 40);
    _rightButtonOutlet.frame=CGRectMake(self.view.frame.size.width-40, 0, 40, 40);
    _calenderDateOutlet.frame=CGRectMake((self.bottomView.frame.size.width/2)-70, 8, self.calenderDateOutlet.frame.size.width, self.calenderDateOutlet.frame.size.height);
    //    _calenderBtn.frame=CGRectMake((self.bottomView.frame.size.width/2)-75, self.calenderBtn.frame.origin.y, self.calenderBtn.frame.size.width, self.calenderBtn.frame.size.height);
}
//method to design calendar according to bookings and free slots.
-(void)customCalanderMethod
{
    
    dateValue=[NSMutableArray new];
    frameDic=[NSMutableDictionary new];
    
    value=0;
   
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
    bookingListArray=[getCalenderData.bookingsList mutableCopy];
    
    NSString *startTime=getCalenderData.businessStartHours;
    
    
    NSArray *startdate=[self stringColonSeparation:startTime];
    start=[[startdate objectAtIndex:0] intValue];
    startMin=[[startdate objectAtIndex:1] intValue];
    
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc]init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter1 setLocale:locale];
    [dateFormatter1 setDateFormat:@"dd-MMMM-yyyy"];
    NSString *tempCurrentDate=[dateFormatter1 stringFromDate:[NSDate date]];
    NSDate *currentDate = [dateFormatter1 dateFromString:tempCurrentDate];
    NSDate *serverDate = [dateFormatter1 dateFromString:dateString];
    NSString *endTime;
    
    if ([getCalenderData.businessEndHours isEqualToString:@"23:59"])
    {
       endTime=@"24:00";
    }
    else
    {
    endTime=getCalenderData.businessEndHours;
    }
    if (([serverDate compare:currentDate] == NSOrderedAscending))
    {
        endTime =@"24:00";
    }
    NSArray *enddate=[self stringColonSeparation:endTime];
    
    
    last=[[enddate objectAtIndex:0] intValue];
    lastMin=[[enddate objectAtIndex:1] intValue];
    if ((last==0 && start!=0))
    {
        last =24;
    }
    
    
    
    value=(last-start-1)*2;
    if (startMin!=0)
    {
        value=value+1;
    }
    else{
        value=value+2;
    }
    if (lastMin!=0)
    {
        value=value+1;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale1 = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale1];
    dateFormatter.dateFormat = @"HH:mm";
    NSDate *date = [dateFormatter dateFromString:startTime];
    
    //  dateFormatter.dateFormat = @"hh:mm a";
    
    for (int i=0; i<value; i++) {
        [dateValue addObject:[[dateFormatter stringFromDate:date] lowercaseString]];
        date=[date dateByAddingTimeInterval:60*30];
    }
    
    if (dateValue.count<1)
    {
        noRecordsLbl.hidden = NO;
    }
    else
    {
        noRecordsLbl.hidden = YES;
        
    }
    
    if (value*40>self.scrollview.frame.size.height)
        _secondView.frame=CGRectMake(0, 0,self.scrollview.frame.size.width, value*40);
    else
        _secondView.frame=CGRectMake(0, 0,self.scrollview.frame.size.width, self.scrollview.frame.size.height);
    
    
    _scrollview.contentInset = UIEdgeInsetsMake(0, 0, self.secondView.frame.size.height, 0);
    
    
    for (int i=0; i<value; i++)
    {
        [self customLabelMethod:i];
    }
    
    for (int i=0;i<bookingListArray.count;i++)
    {
        NSMutableDictionary *dataDic=[bookingListArray objectAtIndex:i];
        NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc]
                            initWithLocaleIdentifier:@"en_US"];
        [dateFormatter1 setLocale:locale];
        dateFormatter1.dateFormat = @"HH:mm";
        NSDate *now = [dateFormatter1 dateFromString:[dataDic objectForKey:@"StartTime"]];
        NSDate *then;
        NSTimeInterval timeInterval;
        if ([[dataDic objectForKey:@"EndTime"] isEqualToString:@"23:59"]) {
            then  = [dateFormatter1 dateFromString:@"23:30"];
            timeInterval=[then timeIntervalSinceDate:now]+ 60*30;
        } else {
            then = [dateFormatter1 dateFromString:[dataDic objectForKey:@"EndTime"]];
            timeInterval=[then timeIntervalSinceDate:now] ;
        }
        int timeIntervalInt=timeInterval/1800;
        
        NSDate *date1 = [dateFormatter1 dateFromString:[dataDic objectForKey:@"StartTime"]];
        NSString *dateStr=[dateFormatter1 stringFromDate:date1];
        //NSDate *datetwo = [dateFormatter1 dateFromString:[dataDic objectForKey:@"serviceEndTime"]];
        
        // dateFormatter1.dateFormat = @"hh:mm a";
        NSString *dateChecker=[[dateFormatter1 stringFromDate:date1] lowercaseString];
        //        NSString *enddateChecker=[[dateFormatter1 stringFromDate:datetwo] lowercaseString];
        
        if ([frameDic objectForKey:dateChecker]!=nil) {
            
            NSString *buttonFrams=[frameDic objectForKey:dateChecker];
            CGRect rect = CGRectFromString(buttonFrams);
            UIButton *but= [[UIButton alloc]initWithFrame:CGRectMake(90, rect.origin.y, self.view.frame.size.width-90, 40*timeIntervalInt)];
            UILabel* titleLabel = [[UILabel alloc]
                                   initWithFrame:CGRectMake(10, 0,
                                                            but.frame.size.width-40,but.frame.size.height)] ;
            titleLabel.text = [dataDic objectForKey:@"ServiceName"];
            titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size: 15.0];
            titleLabel.numberOfLines=2;
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            [but addSubview:titleLabel];
        
            [[but layer] setBorderWidth:0.3f];
            [[but layer] setBorderColor:[UIColor whiteColor].CGColor];
            but.tag=i;
            UIButton *cancel= [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-40, but.frame.origin.y+ (but.frame.size.height/2)-20, 40, 40)];
            //cancel.backgroundColor = [UIColor grayColor];
            [cancel addTarget:self action:@selector(CancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
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
                cancel.enabled=NO;
            }
         
            else if (([serverDate compare:currentDate] != NSOrderedDescending) && [[dateFormatter1 dateFromString:dateStr] compare:[dateFormatter1 dateFromString:currentTime]] == NSOrderedAscending)
            {
                
                cancel.enabled=NO;
                
            }
            
            int status=[[dataDic objectForKey:@"Status"] intValue];
            
            if (status==1)
            {
                but.titleLabel.font=[UIFont fontWithName:@"HelveticaNeue" size:15];
                [but setTitleColor:[UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0] forState:UIControlStateNormal];
                [but setTitle:@"Blocked" forState:UIControlStateNormal];
                but.backgroundColor=[UIColor colorWithRed:150.0/255.0 green:150/255.0 blue:150.0/255.0 alpha:1.0];
                [cancel setImage:[UIImage imageNamed:[NSString stringWithFormat:@"close_icon_gray"]] forState:UIControlStateNormal];
    
                 [self.secondView addSubview:but];
                 [self.secondView addSubview:cancel];
               
            }
            else if (status==6)
            {
                [but setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                but.backgroundColor=[UIColor colorWithRed:255.0/255.0 green:63.0/255.0 blue:64.0/255.0 alpha:1.0];
                 [self.secondView addSubview:but];
                [but addTarget:self action:@selector(goToBookingDetail:) forControlEvents:UIControlEventTouchUpInside];

            }
            else if (status==2)
            {
                [but setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                but.backgroundColor=[UIColor colorWithRed:255.0/255.0 green:63.0/255.0 blue:64.0/255.0 alpha:1.0];
                [cancel setImage:[UIImage imageNamed:[NSString stringWithFormat:@"close_icon"]] forState:UIControlStateNormal];
                 [self.secondView addSubview:but];
                 [self.secondView addSubview:cancel];
                [but addTarget:self action:@selector(goToBookingDetail:) forControlEvents:UIControlEventTouchUpInside];
            }

            
            cancel.tag=i;
            
            
           
           
            
        }
    }
    [self addNotificationsForBookings];
   
}
-(void)customLabelMethod:(int)iValue
{
    UILabel *time=[[UILabel alloc]initWithFrame:CGRectMake(0, iValue*40, 90, 40)];
    time.backgroundColor=[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    time.textAlignment=NSTextAlignmentCenter;
    time.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    time.textColor=[UIColor darkGrayColor];
    time.text=[dateValue objectAtIndex:iValue];
    
    [self.secondView addSubview:time];
    
    UILabel *jobs=[[UILabel alloc]initWithFrame:CGRectMake(90, iValue*40, self.view.frame.size.width-90, 40)];
    if (iValue%2==0)
        jobs.backgroundColor=[UIColor whiteColor];
    else
        jobs.backgroundColor=[UIColor colorWithRed:244.0/255.0 green:243.0/255.0 blue:242.0/255.0 alpha:1.0];
    
    jobs.textAlignment=NSTextAlignmentCenter;
    
    jobs.textColor=[UIColor colorWithRed:110.0/255.0 green:110.0/255.0 blue:110.0/255.0 alpha:1.0];
    jobs.font= [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
    jobs.text=@"+";
    CGRect frame=jobs.frame;
    [frameDic setObject:NSStringFromCGRect(frame) forKey:time.text];
    
    [self.secondView addSubview:jobs];
    
    
    UIButton *but= [[UIButton alloc]initWithFrame:CGRectMake(90, iValue*40, self.view.frame.size.width-90, 40)];
    [but addTarget:self action:@selector(addSlot:) forControlEvents:UIControlEventTouchUpInside];
    but.backgroundColor=[UIColor clearColor];
    but.tag=iValue;
    
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
    
    if (([serverDate compare:currentDate] == NSOrderedAscending))
    {
        but.enabled=NO;
        jobs.alpha = .4;
    }
    else if (([serverDate compare:currentDate] != NSOrderedDescending) && [[dateFormatter1 dateFromString:[dateValue objectAtIndex:iValue]] compare:[dateFormatter1 dateFromString:currentTime]] == NSOrderedAscending)
    {
        
        but.enabled=NO;
        jobs.alpha = .4;
        
    }
    
    
    [self.secondView addSubview:but];
    
}
//method to add to add local notification for confirmed bookings.
-(void)addNotificationsForBookings
{
    NSArray *notificationArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (int i=0; i<bookingListArray.count; i++) {
        NSDictionary * tempDict = [bookingListArray objectAtIndex:i];
        bool shouldAdd = true;
        for (int j = 0; j<notificationArray.count; j++)
        {
            UILocalNotification *notification = [notificationArray objectAtIndex:j];
            if([notification.userInfo isEqualToDictionary:[NSDictionary dictionaryWithObject:[tempDict objectForKey:@"BookingId"] forKey:@"BookingId"]])
            {
                shouldAdd = false;
                break;
            }
        }
        if (shouldAdd)
        {
            [self reminderAlert:tempDict];
        }
    }

}
-(void)reminderAlert : (NSDictionary *)dataDict

{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:locale];
    [dateFormat setDateFormat:@"dd MMM yyyy"];
    NSDate *date =[dateFormat dateFromString:_calenderDateOutlet.titleLabel.text];
    [dateFormat setDateFormat:@"MMM d,yyyy"];
    NSString *fireDate=[dateFormat stringFromDate:date];
    [dateFormat setDateFormat:@"HH:mm"];
    NSDate *fireToTime=[dateFormat dateFromString:[dataDict objectForKey:@"StartTime"]];
    [dateFormat setDateFormat:@"hh:mm a"];
    NSString *CheckTOTime = [dateFormat stringFromDate:fireToTime];
    NSString *startdate1= [NSString stringWithFormat:@"%@ %@",fireDate,CheckTOTime];
    [dateFormat setDateFormat:@"MMM d,yyyy hh:mm a"];
    NSDate *startDate = [dateFormat dateFromString:startdate1];
    NSTimeInterval notiInterval =[startDate timeIntervalSinceDate:[NSDate date]] -30*60;
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:notiInterval];
    notification.alertBody = [NSString stringWithFormat:@"%@ %@ %@ %@",@"You have booking appointment for",[dataDict objectForKey:@"ServiceName"],@"at",[dataDict objectForKey:@"StartTime"]];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 0;
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:[dataDict objectForKey:@"BookingId"] forKey:@"BookingId"];
    notification.userInfo = infoDict;
    
    NSMutableArray *notifications = [[NSMutableArray alloc] init];
    [notifications addObject:notification];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    
}


#pragma mark - end
#pragma mark - IBActions
- (IBAction)blockTheSlot:(UIButton *)sender
{
    [blockTheSlotOutlet setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0]] forState:UIControlStateHighlighted];
    [myDelegate ShowIndicator];
    [self performSelector:@selector(blockSlot) withObject:nil afterDelay:.1];
}
- (IBAction) goToBookingDetail: (id)sender
{
     NSDictionary *tempDict = [getCalenderData.bookingsList objectAtIndex:[sender tag]];
    myDelegate.superClassView = @"backView";
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BookingInformationViewController *objProductDetail =[storyboard instantiateViewControllerWithIdentifier:@"BookingInformationViewController"];
    objProductDetail.bookingID=[tempDict objectForKey:@"BookingId"];
    [self.navigationController pushViewController:objProductDetail animated:YES];
}


- (IBAction) CancelButtonClicked: (id)sender
{
    tag = (int)[sender tag];
    NSMutableDictionary *dataDic=[bookingListArray objectAtIndex:[sender tag]];
    if ([[dataDic objectForKey:@"Status"] intValue]==1)
    {
        NSDictionary *tempDict = [getCalenderData.bookingsList objectAtIndex:[sender tag]];
        [myDelegate ShowIndicator];
        [self performSelector:@selector(deleteBooking:) withObject:[tempDict objectForKey:@"BookingId"] afterDelay:.1];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Are you sure you want to cancel this booking?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        [alert show];
        alert.tag =5;
        
    }
}

- (IBAction) addSlot: (id)sender
{
    slotStartTime=[dateValue objectAtIndex:[sender tag]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    // dateFormatter.dateFormat = @"hh:mm a";
    dateFormatter.dateFormat = @"HH:mm";
    NSDate *date = [dateFormatter dateFromString:slotStartTime];
    
    slotStartTime = [dateFormatter stringFromDate:date];
    
    
    date=[date dateByAddingTimeInterval:60*30];
    slotEndTime=[dateFormatter stringFromDate:date];
    
    popupBackView.hidden=NO;
    
    
}


- (IBAction)crossActton:(UIButton *)sender
{
    popupBackView.hidden=YES;
    
}

- (IBAction)addBooking:(UIButton *)sender
{
    
    [addBookingOutlet setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0]] forState:UIControlStateHighlighted];
    popupBackView.hidden=YES;
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddBookingViewController *objAddBooking =[storyboard instantiateViewControllerWithIdentifier:@"AddBookingViewController"];
    objAddBooking.bookingDate=dateString;
    objAddBooking.bookingStartTime=slotStartTime;
    objAddBooking.bookingEndTime=slotEndTime;
    objAddBooking.calenderData=getCalenderData;
    [self.navigationController pushViewController:objAddBooking animated:YES];
    
}

#pragma mark - Date Picker

- (IBAction)leftArrow:(UIButton *)sender {
    
    NSArray *viewsToRemove = [self.secondView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    _scrollview.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc]init];
    NSLocale *locale = [[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
    [dateFormatter1 setLocale:locale];
    [dateFormatter1 setDateFormat:@"dd-MMMM-yyyy"];
    NSDate *date =[dateFormatter1 dateFromString:dateString]; // your date from the server will go here.
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = -1;
    NSDate *newDate = [calendar dateByAddingComponents:components toDate:date options:0];
    dateString=[dateFormatter1 stringFromDate:newDate];
    [_calenderDateOutlet setTitle:[self formatDateToDisplay:newDate] forState:UIControlStateNormal];
    [dateFormatter1 setDateFormat:@"EEEE"];
    _dayLabel.text=[[dateFormatter1 stringFromDate:newDate] uppercaseString];
    [myDelegate ShowIndicator];
    [self performSelector:@selector(callSpCalenderFromServer) withObject:nil afterDelay:.2];
    
}

- (IBAction)rightArrow:(UIButton *)sender
{
    NSArray *viewsToRemove = [self.secondView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    _scrollview.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc]init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter1 setLocale:locale];
    [dateFormatter1 setDateFormat:@"dd-MMMM-yyyy"];
    NSDate *date =[dateFormatter1 dateFromString:dateString]; // your date from the server will go here.
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = 1;
    NSDate *newDate = [calendar dateByAddingComponents:components toDate:date options:0];
    dateString=[dateFormatter1 stringFromDate:newDate];
    [_calenderDateOutlet setTitle:[self formatDateToDisplay:newDate] forState:UIControlStateNormal];
    [dateFormatter1 setDateFormat:@"EEEE"];
    _dayLabel.text=[[dateFormatter1 stringFromDate:newDate]uppercaseString];
    [myDelegate ShowIndicator];
    [self performSelector:@selector(callSpCalenderFromServer) withObject:nil afterDelay:.2];
    
}

- (IBAction)calanderPicker:(UIButton *)sender
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _datePicker.backgroundColor=[UIColor whiteColor];
    _datePicker.frame = CGRectMake(_datePicker.frame.origin.x, self.view.frame.size.height-_datePicker.frame.size.height , self.view.frame.size.width, _datePicker.frame.size.height);
    _pickerToolBar.backgroundColor=[UIColor whiteColor];
    _pickerToolBar.frame = CGRectMake(_pickerToolBar.frame.origin.x, _datePicker.frame.origin.y-44, self.view.frame.size.width, _pickerToolBar.frame.size.height);
    [UIView commitAnimations];
}

-(void)hidePickerWithAnimation
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _datePicker.frame = CGRectMake(_datePicker.frame.origin.x, 1000, self.view.frame.size.width, _datePicker.frame.size.height);
    _pickerToolBar.frame = CGRectMake(_pickerToolBar.frame.origin.x, 1000, self.view.frame.size.width, _pickerToolBar.frame.size.height);
    [UIView commitAnimations];
}

- (IBAction)cancelToolBarAction:(id)sender
{
    [self hidePickerWithAnimation];
}

- (IBAction)doneToolBarAction:(id)sender
{
    NSArray *viewsToRemove = [self.secondView subviews];
    for (UIView *v in viewsToRemove)
    {
        [v removeFromSuperview];
    }
    _scrollview.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"dd-MMMM-YYYY"];
    dateString = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:_datePicker.date]];
    [_calenderDateOutlet setTitle:[self formatDateToDisplay:_datePicker.date] forState:UIControlStateNormal];
    [dateFormatter setDateFormat:@"EEEE"];
    _dayLabel.text=[[dateFormatter stringFromDate:_datePicker.date]uppercaseString];
    [myDelegate ShowIndicator];
    [self performSelector:@selector(callSpCalenderFromServer) withObject:nil afterDelay:.2];
    [self hidePickerWithAnimation];
}
#pragma mark - end

#pragma mark - Change background color at higlighted state
-(UIImage *)imageWithColor:(UIColor *)color
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
#pragma mark - end

#pragma mark - Helper methods
//Method to formate date.
-(NSString *)formatDateToDisplay : (NSDate *)date
{
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateformate setLocale:locale];
    [dateformate setDateFormat:@"dd MMM YYYY"];
    NSString *dateStr=[dateformate stringFromDate:date];
    return dateStr;
}
-(NSArray *)stringColonSeparation:(NSString *)date{
    NSArray *strings = [date componentsSeparatedByString:@":"];
    return strings;
}

-(NSArray *)stringCommaSeparation:(NSString *)date
{
    NSArray *arrayStrings = [date componentsSeparatedByString:@","];
    return arrayStrings;
}

-(NSString *)stringSpaceSeparation:(NSString *)date{
    NSArray *strings = [date componentsSeparatedByString:@" "];
    return [strings objectAtIndex:0];
}
#pragma mark -end


@end
