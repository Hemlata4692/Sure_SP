//
//  WebService.h
//  Sure_sp
//
//  Created by Ranosys on 30/03/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"


//live link
//#define BASE_URL                                    @"http://54.169.111.150/suresvc/Sure.svc"

//beta link
#define BASE_URL                                  @"http://52.74.126.34/sureappsvcbeta/Sure.svc"

//test link
//#define BASE_URL                                  @"http://52.74.144.192/sureappsvc/Sure.svc"

//qa link
//#define BASE_URL                                  @"http://52.74.144.192/sureappsvcqa/Sure.svc"
@class BusinessDataModel;
@class serviceDetailModel;
@class MyCalenderDataModel;
@class PendingConfirmationModel;
@interface WebService : NSObject

@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
+ (id)sharedManager;


//AWS key methods
-(void)getAWSKey:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

//Login screen methods
-(void)registerUser:(NSString *)mailId password:(NSString *)password success:(void (^)(id))success failure:(void (^)(NSError *))failure;
-(void)userLoginFb:(NSString *)mailId success:(void (^)(id))success failure:(void (^)(NSError *))failure;
- (void)userLogin:(NSString *)email andPassword:(NSString *)password success:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end

//data encryption method
-(NSString *)encryptionField:(NSString *)password;
//end

//data decryption method
-(NSString *)decryptionField:(NSString *)string;
//end

//business register methods
-(void)getCategoriesForBusinessRegistration:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
-(void)businessRegister: (NSString *)picName name:(NSString *)name businessName:(NSString *)businessName BusinessDescription:(NSString *)BusinessDescription InShop:(bool)InShop Onsite:(bool)Onsite Location:(NSString * )Location PinCode:(NSString *)PinCode PhoneNo:(NSString *)PhoneNo ServiceCategory : (NSString*)ServiceCategory SubCategory :(NSArray *)SubCategory OtherSubcategory:(NSString *)OtherSubcategory Days:(NSMutableArray *)Days cityId:(int)cityId latitude:(NSString *)latitude longitude:(NSString *)longitude success:(void (^)(id))success failure:(void (^)(NSError *))failure;
-(void)GetBusinessRegisterData:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
-(void)getCitiesFromServer:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end

//add and edit service methods
-(void)addService: (NSMutableArray *)images serviceDesc:(NSString *)serviceDescription slotDurationHrs:(NSString *)slotDurationHrs daysAdvanceBooking:(NSString *)daysAdvanceBooking serviceCharges:(NSString * )serviceCharges serviceType:(NSString *)serviceType bookBeforeHrs:(NSString *)bookBeforeHrs name:(NSString *)name success:(void (^)(id))success failure:(void (^)(NSError *))failure;
-(void)editService: (NSMutableArray *)images serviceDesc:(NSString *)serviceDescription slotDurationHrs:(NSString *)slotDurationHrs daysAdvanceBooking:(NSString *)daysAdvanceBooking serviceCharges:(NSString * )serviceCharges serviceType:(NSString *)serviceType bookBeforeHrs:(NSString *)bookBeforeHrs name:(NSString *)name serviceId :(NSString *)serviceId success:(void (^)(id))success failure:(void (^)(NSError *))failure;
-(void)getServiceDetail:(NSString *)serviceId success:(void (^)(id))success failure:(void (^)(NSError *))failure;
-(void)deleteImage:(NSString *)imageName serviceId:(NSString *)serviceId success:(void (^)(id))success failure:(void (^)(NSError *))failure;
-(void)checkDuplicateService:(NSString *)serviceName success:(void (^)(id))success failure:(void (^)(NSError *))failure;
-(void)getServiceType:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end

//Service Management methods
-(void)getServiceList:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
-(void)deleteService:(NSString *)serviceId success:(void (^)(id))success failure:(void (^)(NSError *))failure;
//end

//Business profile methods
-(void)getBusinessProfileFromServer:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end

//Get Comments
-(void)getCommentData:(NSString *)offset success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end

//Get Calender
-(void)getSpCalender:(NSString *)date success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
-(void)getblockedSlot:(NSString *)date startTime:(NSString *)startTime endTime:(NSString *)endTime success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
-(void)deleteBooking:(NSString *)bookingId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end


//Add Manual Booking
-(void)addBookingt:(NSString *)serviceID customerName:(NSString *)customerName customerContact:(NSString *)customerContact bookingDate:(NSString *)bookingDate remarks:(NSString *)remarks address:(NSString *)address startTime:(NSString *)startTime endTime:(NSString *)endTime success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end

//Booking Information
-(void)getBookingInformation:(NSString *)bookingId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end

//Pending confirmation methods
-(void)getPendingConfirmationList:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end

//Booking Request
-(void)acceptBooking:(NSString *)bookingId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
-(void)rejectBooking:(NSString *)bookingId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end

//Device registration method for push notification
-(void)registerDeviceForPushNotification:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end

//list of cancel booking method
-(void)getListOfCancelBooking:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
//end

@end
