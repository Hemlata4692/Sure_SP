//
//  WebService.m
//  Sure_sp
//
//  Created by Ranosys on 30/03/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "WebService.h"
#import "NSData+Base64.h"
#import "BusinessDataModel.h"
#import "NullValueChecker.h"
#import "serviceDetailModel.h"
#import "CryptLib.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "BusinessProfileDataModel.h"
#import "ServiceDataModel.h"
#import "MyCalenderDataModel.h"
#import "BookingInformationModel.h"
#import "PendingConfirmationModel.h"
//method names
#define kUrlLogin                       @"Login"
#define kUrlSignup                      @"Register"
#define kUrlFbLogin                     @"FbLogin"

#define kUrlServiceCategoty             @"GetSpServiceCategories"
#define kUrlBusinessRegister            @"BusinessRegister"
#define kUrlGetBusiness                 @"GetBusinessRegisterData"
#define kUrlGetCities                   @"GetCities"

#define kUrlGetService                  @"GetServiceDetails"
#define kUrlAddService                  @"AddService"
#define kUrlEditService                 @"UpdateService"
#define kUrlServiceExist                @"IsServiceExist"
#define kUrlServiceType                 @"GetServiceTypes"
#define kUrlDeleteImage                 @"DeleteServiceImage"
#define kUrlServiceList                 @"GetServicesList"
#define kUrlDeleteService               @"DeleteService"
#define kUrlComments                    @"GetComments"
#define kUrlGetProfile                  @"GetBusinessProfile"

#define kUrlGetCalender                 @"GetSPCalendar"
#define kUrlGetBlockedSlot              @"BlockTimeSlot"
#define kUrldeleteBooking               @"DeleteBooking"

#define kUrlAddBooking                  @"AddManualBooking"

#define kUrlBookingInformation          @"GetBookingInformation"

#define kUrlPendingConfirmation         @"PendingConfirmationListOfSP"

#define kUrlAcceptBooking               @"AcceptBookingBySP"
#define kUrlRejectBooking               @"RejectBookingBySP"
#define kUrlRegisterDevice              @"RegisterDevice"
#define kUrlgetCancelBookings           @"GetBookingsCancelledByCustomer"
//end



@implementation WebService
@synthesize manager;
#pragma mark - AFNetworking method
+ (id)sharedManager
{
    static WebService *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}
- (id)init
{
    if (self = [super init])
    {
        manager = [[AFHTTPRequestOperationManager manager] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    }
    return self;
}

- (void)post:(NSString *)path parameters:(NSDictionary *)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager.requestSerializer setValue:@"parse-application-id-removed" forHTTPHeaderField:@"X-Parse-Application-Id"];
    [manager.requestSerializer setValue:@"parse-rest-api-key-removed" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    manager.securityPolicy.allowInvalidCertificates = YES;
    [manager POST:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [myDelegate StopIndicator];
        failure(error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }];
    
}

- (BOOL)isStatusOK:(id)responseObject
{
    NSNumber *number = responseObject[@"IsSuccess"];
    
    switch (number.integerValue)
    {
        case 1:
            return YES;
            break;
        case 0: {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:responseObject[@"Message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [myDelegate StopIndicator];
            [alert show];
            
        }
            return NO;
            break;
        default: {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:responseObject[@"Message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [myDelegate StopIndicator];
            [alert show];
            
        }
            return NO;
            break;
    }
}
#pragma mark - end
#pragma mark - AES encryption
-(NSString *)encryptionField:(NSString *)string
{
    
    StringEncryption *EncObj=[[StringEncryption alloc]init];
    
    NSString * encryptionKey= @"my secret key";    // key = [[StringEncryption alloc] sha256:key length:32];
    NSString* key1=[EncObj sha256:encryptionKey length:32];
    NSString * iv1 = @"263a2e31f23bbaaa";
    NSData* plainText = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData* encData= [EncObj encrypt:plainText key:key1 iv:iv1];
    NSString * encryptedString= [NSString stringWithFormat:@"%@",[encData  base64EncodingWithLineLength:0] ];
    return encryptedString;
    
}
#pragma mark - end

#pragma mark - AES decryption
-(NSString *)decryptionField:(NSString *)string
{
    StringEncryption *decObj=[[StringEncryption alloc]init];
    
    NSString * decryptionKey= @"my secret key";    // key = [[StringEncryption alloc] sha256:key length:32];
    NSString* key1=[decObj sha256:decryptionKey length:32];
    NSString * iv1 = @"263a2e31f23bbaaa";
    NSData* encryptedText = [[NSData alloc] initWithBase64EncodedString:string options:0];
    encryptedText= [decObj decrypt:encryptedText key:key1 iv:iv1];
    NSString * decryptedString= [[NSString alloc] initWithData:encryptedText encoding:NSUTF8StringEncoding];
    return decryptedString;
    
}

#pragma mark - end


#pragma mark- Get AWS key

-(void)getAWSKey:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"]};
    NSString *URLString = [NSString stringWithFormat:@"%@/GetAWSKeys", BASE_URL];
    [self post:URLString parameters:requestDict success:^(id responseObject) {
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject])
        {
            NSMutableDictionary *getAWSData=[[NSMutableDictionary alloc]init];
            getAWSData=[responseObject mutableCopy];
            NSString *AccessKey=[self decryptionField:[responseObject objectForKey:@"AccessKey"]];
            NSString *BucketName=[self decryptionField:[responseObject objectForKey:@"BucketName"]];
            NSString *SecretKey=[self decryptionField:[responseObject objectForKey:@"SecretKey"]];
            [getAWSData setObject:AccessKey forKey:@"AccessKey"];
            [getAWSData setObject:BucketName forKey:@"BucketName"];
            [getAWSData setObject:SecretKey forKey:@"SecretKey"];
            
            success(getAWSData);
        } else {
            failure(nil);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}


#pragma mark - end

#pragma mark- Login module methods
- (void)userLogin:(NSString *)email andPassword:(NSString *)password success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    password= [self encryptionField:password];
    NSDictionary *requestDict = @{ @"Username" : email,@"Password" : password,@"Role":@"ServiceProvider"};
    
    
    //NSString *URLString =@"Login"; //[NSString stringWithFormat:@"%@/Login", BASE_URL];
    [self post:kUrlLogin parameters:requestDict success:^(id responseObject) {
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject]) {
            [myDelegate StopIndicator];
            success(responseObject);
        } else
        {
            [myDelegate StopIndicator];
            failure(nil);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}
-(void)registerUser:(NSString *)mailId password:(NSString *)password success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    
    password= [self encryptionField:password];
    
    NSDictionary *requestDict = @{ @"Email" : mailId,@"Password" : password,@"Role":@"ServiceProvider"};
    //NSString *URLString = [NSString stringWithFormat:@"%@/Register", BASE_URL];
    [self post:kUrlSignup parameters:requestDict success:^(id responseObject) {
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject]) {
            [myDelegate StopIndicator];
            success(responseObject);
        } else {
            [myDelegate StopIndicator];
            failure(nil);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

-(void)userLoginFb:(NSString *)mailId success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    
    
    NSDictionary *requestDict = @{ @"Email" : mailId,@"Role":@"ServiceProvider"};
    //NSString *URLString = [NSString stringWithFormat:@"%@/FbLogin", BASE_URL];
    [self post:kUrlFbLogin parameters:requestDict success:^(id responseObject) {
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject])
        {
            [myDelegate StopIndicator];
            success(responseObject);
        }
        else
        {
            [myDelegate StopIndicator];
            failure(nil);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    
}

#pragma mark - end

#pragma mark- business register methods

-(void)getCitiesFromServer:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"]};
    [self post:kUrlGetCities parameters:requestDict success:^(id responseObject) {
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject]) {
            success(responseObject);
        } else {
            failure(nil);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    
}


-(void)getCategoriesForBusinessRegistration:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"]};
    //NSString *URLString = [NSString stringWithFormat:@"%@/GetSpServiceCategories", BASE_URL];
    [self post:kUrlServiceCategoty parameters:requestDict success:^(id responseObject) {
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject]) {
            success(responseObject);
        } else {
            failure(nil);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

-(void)GetBusinessRegisterData:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"]};
    //NSString *URLString = [NSString stringWithFormat:@"%@/GetBusinessRegisterData", BASE_URL];
    [self post:kUrlGetBusiness parameters:requestDict success:^(id responseObject) {
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject])
        {
            NSMutableArray *getBusinessRegisterData=[[NSMutableArray alloc]init];
            BusinessDataModel *fetchData=[[BusinessDataModel alloc]init];
            fetchData.Address=[responseObject objectForKey:@"Address"];
            fetchData.businessDescription=[responseObject objectForKey:@"BusinessDescription"];
            fetchData.businessName=[responseObject objectForKey:@"BusinessName"];
            fetchData.businessHours=[responseObject objectForKey:@"BussinessHours"];
            fetchData.Name=[responseObject objectForKey:@"Name"];
            fetchData.Contact=[responseObject objectForKey:@"Contact"];
            fetchData.inShop=[responseObject objectForKey:@"InShop"];
            fetchData.onSite=[responseObject objectForKey:@"OnSite"];
            fetchData.pinCode=[responseObject objectForKey:@"PinCode"];
            fetchData.otherSubCategory=[responseObject objectForKey:@"OtherSubCategory"];
            fetchData.serviceCategory=[responseObject objectForKey:@"ServiceCategory"];
            fetchData.subCategory=[responseObject objectForKey:@"SubCategory"];
            fetchData.profileImage=[responseObject objectForKey:@"ProfileImage"];
            fetchData.cityId =[responseObject objectForKey:@"City"];
            [getBusinessRegisterData addObject:fetchData];
            
            success(getBusinessRegisterData);
        } else {
            failure(nil);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];;
    
}


-(void)businessRegister: (NSString *)picName name:(NSString *)name businessName:(NSString *)businessName BusinessDescription:(NSString *)BusinessDescription InShop:(bool)InShop Onsite:(bool)Onsite Location:(NSString * )Location PinCode:(NSString *)PinCode PhoneNo:(NSString *)PhoneNo ServiceCategory : (NSString*)ServiceCategory SubCategory :(NSArray *)SubCategory OtherSubcategory:(NSString *)OtherSubcategory Days:(NSMutableArray *)Days cityId:(int )cityId latitude:(NSString *)latitude longitude:(NSString *)longitude success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"],@"ProfileImage":picName,@"Name":name,@"BusinessName":businessName,@"BusinessDescription":BusinessDescription,@"InShop":[NSNumber numberWithBool:InShop],@"OnSite":[NSNumber numberWithBool:Onsite],@"Address":[self encryptionField:Location],@"PinCode":PinCode,@"Contact":[self encryptionField:PhoneNo],@"ServiceCategory":ServiceCategory,@"SubCategory":SubCategory,@"OtherSubCategory":OtherSubcategory,@"BussinessHours":Days,@"City":[NSNumber numberWithInt:cityId],@"Latitude":latitude,@"Longitude":longitude};
    
    //NSString *URLString = [NSString stringWithFormat:@"%@/BusinessRegister", BASE_URL];
    [self post:kUrlBusinessRegister parameters:requestDict success:^(id responseObject) {
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject]) {
            [myDelegate StopIndicator];
            success(responseObject);
        } else {
            [myDelegate StopIndicator];
            failure(nil);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];;
    
    
}
#pragma mark - end

#pragma mark- Add and edit service methods

-(void)deleteImage:(NSString *)imageName serviceId:(NSString *)serviceId success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"],@"ServiceId" : serviceId,@"ImageName" : imageName};
    //NSString *URLString = [NSString stringWithFormat:@"%@/DeleteServiceImage", BASE_URL];
    [self post:kUrlDeleteImage parameters:requestDict success:^(id responseObject) {
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject]) {
            [myDelegate StopIndicator];
            success(responseObject);
        } else {
            [myDelegate StopIndicator];
            failure(nil);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];;
    
}

-(void)getServiceDetail:(NSString *)serviceId success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"],@"ServiceId" : serviceId};
    //NSString *URLString = [NSString stringWithFormat:@"%@/GetServiceDetails", BASE_URL];
    [self post:kUrlGetService parameters:requestDict success:^(id responseObject) {
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject])
        {
            serviceDetailModel * dataModel = [[serviceDetailModel alloc]init];
            dataModel.serviceName = [responseObject objectForKey:@"Name"];
            dataModel.imageNameArray = [responseObject objectForKey:@"ServiceImages"];
            dataModel.serviceDescription = [responseObject objectForKey:@"ServiceDescription"];
            dataModel.serviceCharges = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"ServiceCharges"]];
            dataModel.slotDurationHours = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"SlotDurationHrs"]];
            dataModel.bookBeforeHours =[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"BookBeforeHrs"]];
            dataModel.advanceBookingDays =[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"DaysAdvanceBooking"]];
            dataModel.serviceType=[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"ServiceType"]];
            [myDelegate StopIndicator];
            success(dataModel);
        } else {
            failure(nil);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];;
    
    
}
-(void)addService: (NSMutableArray *)images serviceDesc:(NSString *)serviceDescription slotDurationHrs:(NSString *)slotDurationHrs daysAdvanceBooking:(NSString *)daysAdvanceBooking serviceCharges:(NSString * )serviceCharges serviceType:(NSString *)serviceType bookBeforeHrs:(NSString *)bookBeforeHrs name:(NSString *)name success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict;
    
    
    if (images.count>0)
    {
        requestDict=@{@"ServiceImages":images,@"ServiceDescription":serviceDescription,@"SlotDurationHrs":slotDurationHrs,@"DaysAdvanceBooking":daysAdvanceBooking,@"ServiceCharges":serviceCharges,@"ServiceType":serviceType,@"BookBeforeHrs":bookBeforeHrs,@"UserId" :[[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"],@"Name":name};
    }
    else
    {
        requestDict=@{@"ServiceDescription":serviceDescription,@"SlotDurationHrs":slotDurationHrs,@"DaysAdvanceBooking":daysAdvanceBooking,@"ServiceCharges":serviceCharges,@"ServiceType":serviceType,@"BookBeforeHrs":bookBeforeHrs,@"UserId" :[[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"],@"Name":name};
        
    }
    [self post:kUrlAddService parameters:requestDict success:^(id responseObject) {
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject]) {
            [myDelegate StopIndicator];
            success(responseObject);
        } else {
            failure(nil);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}
-(void)editService: (NSMutableArray *)images serviceDesc:(NSString *)serviceDescription slotDurationHrs:(NSString *)slotDurationHrs daysAdvanceBooking:(NSString *)daysAdvanceBooking serviceCharges:(NSString * )serviceCharges serviceType:(NSString *)serviceType bookBeforeHrs:(NSString *)bookBeforeHrs name:(NSString *)name serviceId :(NSString *)serviceId success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict;
    
    
    if (images.count>0)
    {
        requestDict=@{@"ServiceImages":images,@"ServiceDescription":serviceDescription,@"SlotDurationHrs":slotDurationHrs,@"DaysAdvanceBooking":daysAdvanceBooking,@"ServiceCharges":serviceCharges,@"ServiceType":serviceType,@"BookBeforeHrs":bookBeforeHrs,@"UserId" :[[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"],@"Name":name,@"ServiceId":serviceId};
    }
    else
    {
        requestDict=@{@"ServiceDescription":serviceDescription,@"SlotDurationHrs":slotDurationHrs,@"DaysAdvanceBooking":daysAdvanceBooking,@"ServiceCharges":serviceCharges,@"ServiceType":serviceType,@"BookBeforeHrs":bookBeforeHrs,@"UserId" :[[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"],@"Name":name,@"ServiceId":serviceId};
        
    }
    
    
    
    //NSString *URLString = [NSString stringWithFormat:@"%@/UpdateService", BASE_URL];
    [self post:kUrlEditService parameters:requestDict success:^(id responseObject) {
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject]) {
            [myDelegate StopIndicator];
            success(responseObject);
        } else {
            failure(nil);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    
}

-(void)checkDuplicateService:(NSString *)serviceName success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"],@"Name" : serviceName};
    //NSString *URLString = [NSString stringWithFormat:@"%@/IsServiceExist", BASE_URL];
    [self post:kUrlServiceExist parameters:requestDict success:^(id responseObject) {
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject]) {
            [myDelegate StopIndicator];
            success(responseObject);
        } else {
            failure(nil);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];;
    
    
}
-(void)getServiceType:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"]};
    //NSString *URLString = [NSString stringWithFormat:@"%@/GetServiceTypes", BASE_URL];
    [self post:kUrlServiceType parameters:requestDict success:^(id responseObject) {
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject]) {
            [myDelegate StopIndicator];
            success(responseObject);
        } else {
            failure(nil);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];;
    
}
#pragma mark - end

#pragma mark - Service management methods
-(void)getServiceList:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"]};
    //NSString *URLString = [NSString stringWithFormat:@"%@/GetServicesList", BASE_URL];
    [self post:kUrlServiceList parameters:requestDict success:^(id responseObject) {
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject]) {
            [myDelegate StopIndicator];
            success(responseObject);
        } else {
            failure(nil);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
}

-(void)deleteService:(NSString *)serviceId success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"],@"ServiceId" : serviceId};
    //NSString *URLString = [NSString stringWithFormat:@"%@/DeleteService", BASE_URL];
    [self post:kUrlDeleteService parameters:requestDict success:^(id responseObject) {
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject]) {
            [myDelegate StopIndicator];
            success(responseObject);
        } else {
            [myDelegate StopIndicator];
            failure(nil);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];;
    
    
}
#pragma mark - end

#pragma mark - business profile method
-(void)getBusinessProfileFromServer:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"],@"ServiceProviderId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"]};
    //NSString *URLString = [NSString stringWithFormat:@"%@/DeleteService", BASE_URL];
    [self post:kUrlGetProfile parameters:requestDict success:^(id responseObject) {
        responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
        if([self isStatusOK:responseObject]) {
            NSMutableDictionary * dataDict = [NSMutableDictionary new];
            BusinessProfileDataModel *profileModel = [[BusinessProfileDataModel alloc]init];
            profileModel.serviceDataArray = [[NSMutableArray alloc]init];
            profileModel.address = [responseObject objectForKey:@"Address"];
            profileModel.bookings = [responseObject objectForKey:@"Bookings"];
            profileModel.businessDescription = [responseObject objectForKey:@"BusinessDescription"];
            profileModel.businessName = [responseObject objectForKey:@"BusinessName"];
            profileModel.contact = [responseObject objectForKey:@"Contact"];
            profileModel.latitude = [responseObject objectForKey:@"Latitude"];
            profileModel.longitude = [responseObject objectForKey:@"Longitude"];
            profileModel.name = [responseObject objectForKey:@"Name"];
            profileModel.overallRating = [responseObject objectForKey:@"OverallRating"];
            profileModel.pinCode = [responseObject objectForKey:@"PinCode"];
            profileModel.profileImage = [responseObject objectForKey:@"ProfileImage"];
            profileModel.comments = [responseObject objectForKey:@"Comments"];
            profileModel.inShop =[responseObject objectForKey:@"InShop"];
            [dataDict setObject:profileModel forKey:@"BusinessData"];
            NSArray * tmpAry = [responseObject objectForKey:@"ServiceResponse"];
            for (int i = 0; i<tmpAry.count; i++)
            {
                NSDictionary * tmpServiceDict = [tmpAry objectAtIndex:i];
                ServiceDataModel * serviceModel = [[ServiceDataModel alloc]init];
                serviceModel.name = [tmpServiceDict objectForKey:@"Name"];
                serviceModel.serviceCharges = [tmpServiceDict objectForKey:@"ServiceCharges"];
                serviceModel.serviceDescription = [tmpServiceDict objectForKey:@"ServiceDescription"];
                serviceModel.serviceType = [tmpServiceDict objectForKey:@"ServiceType"];
                serviceModel.serviceImages = [tmpServiceDict objectForKey:@"ServiceImages"];
                [profileModel.serviceDataArray addObject:serviceModel];
            }
            [dataDict setObject:profileModel forKey:@"BusinessProfileData"];
            [myDelegate StopIndicator];
            success(dataDict);
        } else {
            [myDelegate StopIndicator];
            failure(nil);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];;
    
}
#pragma mark - end

#pragma mark - Comments List
-(void)getCommentData:(NSString *)offset success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"ServiceProviderId":[[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"Offset":offset};
    
    [self post:kUrlComments parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject]) {
             [myDelegate StopIndicator];
             success(responseObject);
         } else {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error) {
         failure(error);
     }];;
    
}

#pragma mark - end

#pragma mark - Calender
-(void)getSpCalender:(NSString *)date success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"Date":date};
    [self post:kUrlGetCalender parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             MyCalenderDataModel *calenderModel = [[MyCalenderDataModel alloc]init];
             calenderModel.bookingsList = [responseObject objectForKey:@"BookingsList"];
             calenderModel.businessStartHours = [responseObject objectForKey:@"BusinessStartHours"];
             calenderModel.businessEndHours = [responseObject objectForKey:@"BusinessEndHours"];
             [myDelegate StopIndicator];
             success(calenderModel);
         } else {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error) {
         failure(error);
     }];;
    
}

-(void)deleteBooking:(NSString *)bookingId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"BookingId":bookingId};
    [self post:kUrldeleteBooking parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             [myDelegate StopIndicator];
             success(responseObject);
         } else {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error) {
         failure(error);
     }];
    
    
}

-(void)getblockedSlot:(NSString *)date startTime:(NSString *)startTime endTime:(NSString *)endTime success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"Date":date, @"StartTime":startTime, @"EndTime":endTime};
    [self post:kUrlGetBlockedSlot parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             [myDelegate StopIndicator];
             success(responseObject);
         } else {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error) {
         failure(error);
     }];;
    
}
#pragma mark - end
//{UserId:"1", ServiceId:"1", CustomerName:"Customer 1", CustomerContact:"12345678", BookingDate:"12 May 2015", Remarks:" ", CustomerAddress:" ", StartTime:"", EndTime:""}

#pragma mark - Add Booking
-(void)addBookingt:(NSString *)serviceID customerName:(NSString *)customerName customerContact:(NSString *)customerContact bookingDate:(NSString *)bookingDate remarks:(NSString *)remarks address:(NSString *)address startTime:(NSString *)startTime endTime:(NSString *)endTime success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{@"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"ServiceId":serviceID, @"CustomerName":customerName, @"CustomerContact":customerContact, @"BookingDate":bookingDate, @"CustomerAddress":address, @"Remarks":remarks, @"StartTime":startTime, @"EndTime":endTime};
    [self post:kUrlAddBooking parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             [myDelegate StopIndicator];
             success(responseObject);
         } else {
             failure(nil);
         }
     } failure:^(NSError *error) {
         failure(error);
     }];
    
    
}
#pragma mark - end

#pragma mark - booking information method
-(void)getBookingInformation:(NSString *)bookingId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"BookingId":bookingId};
    
    [self post:kUrlBookingInformation parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             NSMutableArray *getBookingInformation=[[NSMutableArray alloc]init];
             
             BookingInformationModel *getBookingInfo=[[BookingInformationModel alloc]init];
             
             getBookingInfo.bookingDate=[responseObject objectForKey:@"BookingDate"];
             getBookingInfo.customerAddress=[responseObject objectForKey:@"CustomerAddress"];
             getBookingInfo.customerContact=[responseObject objectForKey:@"CustomerContact"];
             getBookingInfo.customerName=[responseObject objectForKey:@"CustomerName"];
             getBookingInfo.endTime=[responseObject objectForKey:@"EndTime"];
             getBookingInfo.latitude=[responseObject objectForKey:@"Latitude"];
             getBookingInfo.longitude=[responseObject objectForKey:@"Longitude"];
             getBookingInfo.serviceCharges=[responseObject objectForKey:@"ServiceCharges"];
             getBookingInfo.serviceName=[responseObject objectForKey:@"ServiceName"];
             getBookingInfo.startTime=[responseObject objectForKey:@"StartTime"];
             getBookingInfo.remarks=[responseObject objectForKey:@"Remarks"];
             getBookingInfo.serviceType=[responseObject objectForKey:@"ServiceType"];
             [getBookingInformation addObject:getBookingInfo];

             
             
             success(getBookingInformation);
         } else {
             [myDelegate StopIndicator];
             failure(nil);
         }
     } failure:^(NSError *error) {
         [myDelegate StopIndicator];
         failure(error);
     }];
    
}
#pragma mark - end

#pragma mark - Pending confirmation method

-(void)getPendingConfirmationList:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"]};
    //NSString *URLString = [NSString stringWithFormat:@"%@/GetBusinessRegisterData", BASE_URL];
    [self post:kUrlPendingConfirmation parameters:requestDict success:^(id responseObject)
     {
         
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             id array =[responseObject objectForKey:@"PendingConfirmationServiceList"];
             if (([array isKindOfClass:[NSArray class]]))
             {
             NSMutableArray * pendingListArray = [[NSMutableArray alloc]init];
             NSArray *pendingList = [responseObject objectForKey:@"PendingConfirmationServiceList"];
             for (int i =0; i<pendingList.count; i++)
             {
                 NSDictionary * pendingDataDict = [pendingList objectAtIndex:i];
                 PendingConfirmationModel *objPendindConfirmation =[[PendingConfirmationModel alloc]init];
                 objPendindConfirmation.bookingDate = [pendingDataDict objectForKey:@"BookingDate"];
                 objPendindConfirmation.endTime =  [pendingDataDict objectForKey:@"EndTime"];
                 objPendindConfirmation.name = [pendingDataDict objectForKey:@"Name"];
                 objPendindConfirmation.serviceCharges = [pendingDataDict objectForKey:@"ServiceCharges"];
                 objPendindConfirmation.serviceId = [pendingDataDict objectForKey:@"ServiceId"];
                 objPendindConfirmation.serviceName = [pendingDataDict objectForKey:@"ServiceName"];
                 objPendindConfirmation.startTime = [pendingDataDict objectForKey:@"StartTime"];
                 objPendindConfirmation.userId = [pendingDataDict objectForKey:@"UserId"];
                 objPendindConfirmation.bookingId=[pendingDataDict objectForKey:@"BookingId"] ;
                 [pendingListArray addObject:objPendindConfirmation];
             }
             success(pendingListArray);
             }
             else
             {
                 PendingConfirmationModel *objSpList = [[PendingConfirmationModel alloc]init];
                 objSpList.message =[responseObject objectForKey:@"Message"];
                 success(objSpList);
             }

            
         }
         else {
             failure(nil);
         }
     } failure:^(NSError *error)
    {
         failure(error);
     }];;
}
#pragma mark - end

#pragma mark - Booking Request

-(void)acceptBooking:(NSString *)bookingId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId" : [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"BookingId":bookingId};
    
    [self post:kUrlAcceptBooking parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             [myDelegate StopIndicator];
             success(responseObject);
         }
         else
         {
             [myDelegate StopIndicator];
             failure(nil);
         }
     }
       failure:^(NSError *error)
    {
         [myDelegate StopIndicator];
         failure(error);
     }];

}

-(void)rejectBooking:(NSString *)bookingId success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId":[[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"BookingId":bookingId};
    
    [self post:kUrlRejectBooking parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             [myDelegate StopIndicator];
             success(responseObject);
         }
         else
         {
             [myDelegate StopIndicator];
             failure(nil);
         }
     }
       failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];

}
#pragma mark - end
#pragma mark - Device register for push notification
-(void)registerDeviceForPushNotification:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
  //{UserId:"1",DeviceId:'4324324324',DeviceType:'1/2(1-iOS, 2- Android)',UserType:'1/2(1-SP, 2 Customer App)'}

  NSDictionary *requestDict = @{ @"UserId":[[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"], @"DeviceId":myDelegate.deviceToken,@"DeviceType":[NSNumber numberWithInt:1] ,@"UserType":[NSNumber numberWithInt:1]};
    [self post:kUrlRegisterDevice parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         if([self isStatusOK:responseObject])
         {
             [myDelegate StopIndicator];
             success(responseObject);
         }
         else
         {
             [myDelegate StopIndicator];
             failure(nil);
         }
     }
       failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];
}
#pragma mark - end
#pragma mark - get cancelled booking list
-(void)getListOfCancelBooking:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    NSDictionary *requestDict = @{ @"UserId":[[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"]};
    [self post:kUrlgetCancelBookings parameters:requestDict success:^(id responseObject)
     {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[responseObject mutableCopy]];
         id array =[responseObject objectForKey:@"PendingConfirmationServiceList"];
         if (([array isKindOfClass:[NSArray class]]))
         {
         
         
             [myDelegate StopIndicator];
             success(array);
         }
         else
         {
             PendingConfirmationModel *objSpList = [[PendingConfirmationModel alloc]init];
             objSpList.message =[responseObject objectForKey:@"Message"];
             success(objSpList);
         }
         
     }
       failure:^(NSError *error)
     {
         [myDelegate StopIndicator];
         failure(error);
     }];

}
#pragma mark - end


@end
