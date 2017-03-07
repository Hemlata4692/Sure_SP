//
//  AppDelegate.m
//  SidebarDemoApp
//
//  Created by Ranosys on 06/02/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "GAI.h"
#import <FacebookSDK/FacebookSDK.h>
#import "BusinessRegisterViewController.h"
#import "MyCalenderViewController.h"
#import <AWSCore/AWSCore.h>
#import "Constants.h"
#import "AWSDownload.h"
#import "HHAlertView.h"
#import "PendingConfirmationViewController.h"
#import "BookingRequestViewController.h"
#import "SWRevealViewController.h"
#import "BookingResponseViewController.h"

@interface AppDelegate ()<AWSDownloadDelegate,HHAlertViewDelegate>
{
}

@end

@implementation AppDelegate
id<GAITracker> tracker;
@synthesize navController;
@synthesize count,shouldCancelDownload;
@synthesize sideBarImage;
@synthesize shouldDownload,multiplePickerDic;
@synthesize latitude,longitude,locationManager;
@synthesize deviceToken;
@synthesize superClassView;
@synthesize messageType;
@synthesize bookingId;
@synthesize pushCount;
//@synthesize navigationController;
#pragma mark - Activity indicator
- (void) ShowIndicator
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    hud.dimBackground=YES;
    hud.labelText=@"Loading...";
}

//Method for stop indicator
- (void)StopIndicator
{
    [MBProgressHUD hideHUDForView:self.window animated:YES];
}
#pragma mark- register unregister for notification
-(void)registerDeviceForNotification
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}
-(void)unrigisterForNotification
{
    
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    
}
#pragma mark -end

#pragma mark - end

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken1
{
    NSString *token = [[deviceToken1 description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.deviceToken = token;
    [[WebService sharedManager] registerDeviceForPushNotification:^(id responseObject) {
        
    } failure:^(NSError *error) {
        
    }] ;

}

- (void)didClickButtonAnIndex:(HHAlertButton)button
{
    if (button == HHAlertButtonOk &&[HHAlertView shared].tag==1)
    {
        
        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PendingConfirmationViewController *view1=[sb instantiateViewControllerWithIdentifier:@"PendingConfirmationViewController"];
        
        [self.currentNavigationController pushViewController:view1 animated:YES];
    }
    else if(([HHAlertView shared].tag==4 || [HHAlertView shared].tag==5) && button == HHAlertButtonOk)
    {
        superClassView = @"backView";
        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BookingResponseViewController *view1=[sb instantiateViewControllerWithIdentifier:@"BookingResponseViewController"];
        view1.bookingID =bookingId;
        [self.currentNavigationController pushViewController:view1 animated:YES];
        
    }
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"]!=nil)
    {
        
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [self getNotificationMessage:userInfo];
    if (application.applicationState == UIApplicationStateActive ||[HHAlertView shared].hidden ==YES)
    {
        
        [[HHAlertView shared] setDelegate:self];
        [HHAlertView shared].tag = messageType;
        [HHAlertView showAlertWithStyle:HHAlertStyleWraning inView:self.window Title:@"Booking Request" detail:[self getNotificationMessage:userInfo] cancelButton:@"Cancel" Okbutton:@"Open"];
    }
    else
    {
        if (messageType==1)
        {
            pushCount = 1;
        }
        else if(messageType==4 || messageType==5)
        {
            pushCount = 2;
            superClassView = @"sureView";
            
        }
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SWRevealViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.window setRootViewController:objReveal];
        [self.window setBackgroundColor:[UIColor whiteColor]];
        [self.window makeKeyAndVisible];
    }
        [self addEventToCalender:userInfo];
    }
    
}

-(void)addEventToCalender : (NSDictionary *)userInfo
{
   

}

-(NSString *)getNotificationMessage : (NSDictionary *)userInfo
{
    NSString * message;
    messageType =[[userInfo objectForKey:@"MessageType"]intValue];
    [[NSUserDefaults standardUserDefaults]setInteger:[[userInfo objectForKey:@"PendingConfirmation"]intValue] forKey:@"PendingConfirmation"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    bookingId =[userInfo objectForKey:@"BookingId"];
    switch (messageType)
    {
        case 1:
            
            message = @"You have a new booking request.";
            break;
        case 4:
            
            message = @"Customer has confirmed booking request.";
            break;
        case 5:
            
            message = @"Customer has cancelled booking request.";
            break;
        default:
            break;
    }
    
    return message;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    shouldCancelDownload=0;
//    [self registerDeviceForNotification];
    
    // Override point for customization after application launch.
    //  [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.0/255.0 green:130.0/255.0 blue:241.0/255.0 alpha:1.0]];
    
    multiplePickerDic=[NSMutableDictionary new];
    // [[UINavigationBar appearance] setTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"header.png"]]];
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 5;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker. Replace with your tracking ID.
    tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-62313121-2"];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0 )
    {
        [locationManager requestWhenInUseAuthorization];
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
    CLLocation *location = [myDelegate.locationManager location];
    // Configure the new event with information from the location
    CLLocationCoordinate2D coordinate = [location coordinate];
    latitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
    longitude = [NSString stringWithFormat:@"%f", coordinate.longitude] ;
    
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"header.png"] forBarMetrics:UIBarMetricsDefault];
    shouldDownload = true;
    //set navigation bar button color
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeue-Regular" size:18.0], NSFontAttributeName, nil]];
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.navController = (UINavigationController *)[self.window rootViewController];
    count = 0;
    //[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"HasBusinessProfile"];
    if(([[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"]!=nil && [[NSUserDefaults standardUserDefaults] integerForKey:@"HasBusinessProfile"]==1))
    {
        //Once the user is logged in login screen will appear
        
        
        SWRevealViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.window setRootViewController:objReveal];
        [self.window setBackgroundColor:[UIColor whiteColor]];
        [self.window makeKeyAndVisible];
        [self AWSInitialization];
        
    }
    else if (([[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"]!=nil && [[NSUserDefaults standardUserDefaults] integerForKey:@"HasBusinessProfile"]==0))
    {
        
        SWRevealViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.window setRootViewController:objReveal];
        [self.window setBackgroundColor:[UIColor whiteColor]];
        [self.window makeKeyAndVisible];
        [self AWSInitialization];
        
    }
    else
    {
        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navController setViewControllers: [NSArray arrayWithObject: objReveal]
                                      animated: YES];
        
    }
    NSString * temp = [d objectForKey:@"testing"];
    if (temp == nil)
    {
        temp = @"true";
        [d setObject:temp forKey:@"testing"];
    }
    
    application.applicationIconBadgeNumber = 0;
    NSDictionary *remoteNotifiInfo = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    
    //Accept push notification when app is not open
    if (remoteNotifiInfo)
    {
        //self.currentNavigationController = self.navController;
        [self application:application didReceiveRemoteNotification:remoteNotifiInfo];
    }
    
    //permission for local notification in iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    UILocalNotification *localNotiInfo = [launchOptions objectForKey: UIApplicationLaunchOptionsLocalNotificationKey];
    
    //Accept local notification when app is not open
    if (localNotiInfo)
    {
        [self application:application didReceiveLocalNotification:localNotiInfo];
    }
    //Accept local notification when app is not open
    
    
    //#ifdef DEBUG
    //    [AmazonLogger verboseLogging];
    //#else
    //    [AmazonLogger turnLoggingOff];
    //#endif
    //
    //    [AmazonErrorHandler shouldNotThrowExceptions];
    
    return YES;
}


-(void) AWSInitialization
{
    S3BucketName=[[NSUserDefaults standardUserDefaults] objectForKey:@"BucketName"];
    AWSStaticCredentialsProvider *credentialsProvider = [[ AWSStaticCredentialsProvider alloc]initWithAccessKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"AccessKey"] secretKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"SecretKey"]];
    AWSServiceConfiguration *configuration =  [[AWSServiceConfiguration alloc]initWithRegion:AWSRegionAPSoutheast1 credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // [FBAppEvents activateApp];
    if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
        [self openActiveSessionWithPermissions:nil allowLoginUI:NO];
    }
    
    [FBAppCall handleDidBecomeActive];
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

-(void)openActiveSessionWithPermissions:(NSArray *)permissions allowLoginUI:(BOOL)allowLoginUI
{
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:allowLoginUI
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      // Create a NSDictionary object and set the parameter values.
                                      NSDictionary *sessionStateInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                                        session, @"session",
                                                                        [NSNumber numberWithInteger:status], @"state",
                                                                        error, @"error",
                                                                        nil];
                                      
                                      // Create a new notification, add the sessionStateInfo dictionary to it and post it.
                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"SessionStateChangeNotification"
                                                                                          object:nil
                                                                                        userInfo:sessionStateInfo];
                                      
                                  }];
    
}

-(NSString *)formatDateToDisplay : (NSString*)dateString
{
    
    NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateformate setLocale:locale];
    [dateformate setDateFormat:@"dd-MMMM-yyyy"];
    NSDate *date =[dateformate dateFromString:dateString];
    
    [dateformate setDateFormat:@"dd MMM YYYY"];
    
    NSString *dateStr=[dateformate stringFromDate:date];
    return dateStr;
}


#pragma mark - AWSDownload delegate
-(void)startImageDownloading:(NSString *)ImageName
{
    if(ImageName != nil)
    {
        NSMutableArray * awsImageArray=[NSMutableArray new];
        [awsImageArray addObject:ImageName];
        AWSDownload *download;
        download = [[AWSDownload alloc]init];
        download.delegate = self;
        [download listObjects:self ImageName:awsImageArray folderName:@"businessprofileimages"];
    }
}
-(void)ListObjectprocessCompleted:DownloadimageArray
{
    NSMutableArray * awsImageArray=[DownloadimageArray mutableCopy];
    [myDelegate StopIndicator];
    id object = [awsImageArray objectAtIndex:0];
    if ([object isKindOfClass:[AWSS3TransferManagerDownloadRequest class]]) {
        
        AWSS3TransferManagerDownloadRequest *downloadRequest = object;
        downloadRequest.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (totalBytesExpectedToWrite > 0) {
                    
                }
            });
        };
        
    } else if ([object isKindOfClass:[NSURL class]]) {
        
    }
    
    
}
-(void)DownloadprocessCompleted:(AWSS3TransferManagerDownloadRequest *)downloadRequest index:(NSUInteger)index
{
    sideBarImage =[UIImage imageWithData:[NSData dataWithContentsOfURL:downloadRequest.downloadingFileURL]];
    
    
}
#pragma mark - end delegate
@end
