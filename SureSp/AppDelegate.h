//
//  AppDelegate.h
//  SidebarDemoApp
//
//  Created by Ranosys on 06/02/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    int messageType;
    NSString * bookingId;
}
@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,retain)UINavigationController * navController;
@property(nonatomic,assign)int count,shouldCancelDownload;
@property(nonatomic,retain)UIImage * sideBarImage;
@property(nonatomic,assign) bool shouldDownload;
@property (nonatomic, retain) NSMutableDictionary *multiplePickerDic;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property(nonatomic,strong) NSString *latitude;
@property(nonatomic,strong) NSString *longitude;
@property(nonatomic,retain)NSString * deviceToken;
@property(nonatomic,retain) UINavigationController *currentNavigationController;
@property(nonatomic,assign)int messageType;
@property(nonatomic,strong) NSString *superClassView;
@property(nonatomic,strong) NSString *bookingId;
@property(nonatomic,assign)int pushCount;
-(void)openActiveSessionWithPermissions:(NSArray *)permissions allowLoginUI:(BOOL)allowLoginUI;
// Methos for show indicator
- (void) ShowIndicator;

//Method for stop indicator
- (void)StopIndicator;
-(void) AWSInitialization;
-(void)startImageDownloading:(NSString *)ImageName;
-(void)registerDeviceForNotification;
-(void)unrigisterForNotification;
-(NSString *)formatDateToDisplay : (NSString*)dateString;
@end

