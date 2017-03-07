//
//  LoginViewController.m
//  SidebarDemoApp
//
//  Created by Ranosys on 11/02/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "LoginViewController.h"
#import "GlobalMethod.h"
#import "UIView+RoundedCorner.h"
#import "UITextField+Padding.h"
#import "UITextField+Validations.h"
#import "BusinessRegisterViewController.h"
#import "NSData+Base64.h"
#import "Constants.h"
#import "BSKeyboardControls.h"
@interface LoginViewController ()<UITextFieldDelegate,BSKeyboardControlsDelegate>
{
    NSArray *textFields;

}
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (strong, nonatomic) NSString *userEmailFb;
-(void)handleFBSessionStateChangeWithNotification:(NSNotification *)notification;
@end

@implementation LoginViewController

@synthesize loginBtn,loginFbBtn,loginViewFields,userEmail,userPassword,scrollView,backgroundImage;
@synthesize signUpEmail,signUpPassword,signUpScrollView,confirmPassword,signUpView,backgroundSignUpView;


#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    backgroundSignUpView.hidden=YES;
    [self addTextFieldPadding];
    [self roundedCorner];
    
    //get image according to device
    backgroundImage.translatesAutoresizingMaskIntoConstraints = YES;
    backgroundImage.frame = CGRectMake(self.scrollView.frame.origin.x, 0, self.view.bounds.size.width+8, self.view.bounds.size.height);
    UIImage * tempImg =[UIImage imageNamed:@"bg"];
    backgroundImage.image = [UIImage imageNamed:[tempImg imageForDeviceWithName:@"bg"]];
    
    userEmail.delegate=self;
    userPassword.delegate=self;
    signUpEmail.delegate=self;
    signUpPassword.delegate=self;
    confirmPassword.delegate=self;
    
    signUpEmail.layer.borderColor=[[UIColor colorWithRed:200.0/255.0 green:196.0/255.0 blue:197.0/255.0 alpha:1.0]CGColor];
    signUpEmail.layer.borderWidth= 1.0f;
    
    signUpPassword.layer.borderColor=[[UIColor colorWithRed:200.0/255.0 green:196.0/255.0 blue:197.0/255.0 alpha:1.0]CGColor];
    signUpPassword.layer.borderWidth= 1.0f;
    
    confirmPassword.layer.borderColor=[[UIColor colorWithRed:200.0/255.0 green:196.0/255.0 blue:197.0/255.0 alpha:1.0]CGColor];
    confirmPassword.layer.borderWidth= 1.0f;
    textFields = @[userEmail,userPassword];
    //Keyboard toolbar action to display toolbar with keyboard to move next,previous
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFields]];
    [self.keyboardControls setDelegate:self];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent]; //facebook
    //facebook
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Observe for the custom notification regarding the session state change.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFBSessionStateChangeWithNotification:)
                                                 name:@"SessionStateChangeNotification"
                                               object:nil];
    // Observe for the custom notification regarding the session state change.
    
}

-(void)addTextFieldPadding
{
    [userEmail addTextFieldPadding:userEmail];
    [userPassword addTextFieldPadding:userPassword];
    [signUpEmail addTextFieldPadding:signUpEmail];
    [signUpPassword addTextFieldPadding:signUpPassword];
    [confirmPassword addTextFieldPadding:confirmPassword];
}

-(void) roundedCorner
{
    [loginViewFields setCornerRadius:2.0f];
    [loginFbBtn setCornerRadius:2.0f];
    [loginBtn setCornerRadius:2.0f];
    [signUpEmail setCornerRadius:2.0f];
    [signUpPassword setCornerRadius:2.0f];
    [confirmPassword setCornerRadius:2.0f];
    [signUpView setCornerRadius:2.0f];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
    statusBarView.backgroundColor = [UIColor colorWithRed:192.0/255.0 green:37.0/255.0 blue:43.0/255.0 alpha:1.0];
    [self.view addSubview:statusBarView];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    if([[UIScreen mainScreen] bounds].size.height>480)
    {
        signUpScrollView.scrollEnabled=NO;
    }
    [myDelegate unrigisterForNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) dealloc
{
    
}
#pragma mark - end
- (IBAction)termsAndConditionAction:(id)sender {
    
    UIViewController * objTerms = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TermsConditionView"];
    [self.navigationController pushViewController:objTerms animated:YES];
}

#pragma mark - Keyboard Controls Delegate
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
    [signUpScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark - end

#pragma mark - Textfield Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    [self.keyboardControls setActiveField:textField];
    
    [scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y+( textField.frame.size.height)) animated:YES];
    
    
    if (backgroundSignUpView.hidden==NO)
    {
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    }
    
    if (textField==signUpEmail)
    {
        signUpEmail.layer.borderColor=[[UIColor colorWithRed:255.0/255.0 green:130.0/255.0 blue:128.0/255.0 alpha:1.0]CGColor];
        signUpEmail.layer.borderWidth= 1.0f;
        [signUpScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    else if (textField==signUpPassword)
    {
        signUpPassword.layer.borderColor=[[UIColor colorWithRed:255.0/255.0 green:130.0/255.0 blue:128.0/255.0 alpha:1.0]CGColor];
        signUpPassword.layer.borderWidth= 1.0f;
        [signUpScrollView setContentOffset:CGPointMake(0, textField.frame.origin.y-35) animated:YES];
    }
    else if (textField==confirmPassword)
    {
        
        confirmPassword.layer.borderColor=[[UIColor colorWithRed:255.0/255.0 green:130.0/255.0 blue:128.0/255.0 alpha:1.0]CGColor];
        confirmPassword.layer.borderWidth= 1.0f;
        [signUpScrollView setContentOffset:CGPointMake(0, textField.frame.origin.y-50) animated:YES];
        
    }
    
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [signUpScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    if (textField==signUpEmail)
    {
        signUpEmail.layer.borderColor=[[UIColor colorWithRed:200.0/255.0 green:196.0/255.0 blue:197.0/255.0 alpha:1.0]CGColor];
        signUpEmail.layer.borderWidth= 1.0f;
    }
    else if (textField==signUpPassword)
    {
        signUpPassword.layer.borderColor=[[UIColor colorWithRed:200.0/255.0 green:196.0/255.0 blue:197.0/255.0 alpha:1.0]CGColor];
        signUpPassword.layer.borderWidth= 1.0f;
    }
    else if (textField==confirmPassword)
    {
        
        confirmPassword.layer.borderColor=[[UIColor colorWithRed:200.0/255.0 green:196.0/255.0 blue:197.0/255.0 alpha:1.0]CGColor];
        confirmPassword.layer.borderWidth= 1.0f;
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - end





/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



#pragma mark - Login view methods

-(void)gotoSidebarMenu : (NSDictionary *)dict
{
    
    //[[NSUserDefaults standardUserDefaults] setObject:@"8800da14-69bb-4980-be3d-ccca44233736" forKey:@"UserId"];
    [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"UserId"] forKey:@"UserId"];
    [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"HasBusinessProfile"] forKey:@"HasBusinessProfile"];
    [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"Name"] forKey:@"Name"];
    [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"ProfileImage"] forKey:@"ProfileImage"];
    [[NSUserDefaults standardUserDefaults] setInteger:[[dict objectForKey:@"ServiceCount"]intValue] forKey:@"ServiceCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [myDelegate registerDeviceForNotification];
      UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
    myDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [myDelegate.window setRootViewController:objReveal];
    [myDelegate.window setBackgroundColor:[UIColor whiteColor]];
    [myDelegate.window makeKeyAndVisible];
    

}

- (BOOL)performValidationsForLogin
{
    UIAlertView *alert;
    if ([userEmail isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please enter the Email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else
    {
        if ([userEmail isValidEmail])
        {
            if ([userPassword isEmpty])
            {
                alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please enter the Password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                return NO;
            }
            else if (userPassword.text.length<6)
            {
                
                alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Your password must be atleast 6 characters long." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                return NO;
                
            }
            else
            {
                return YES;
            }
        }
        else
        {
            alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please enter a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
    }
}

- (IBAction)loginButtonClicked:(id)sender
{
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [userEmail resignFirstResponder];
    [userPassword resignFirstResponder];
  
//    UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController *view1=[sb instantiateViewControllerWithIdentifier:@"BusinessRegisterViewController"];
//    [self.navigationController pushViewController:view1 animated:YES];
    if([self performValidationsForLogin])
    {
        [myDelegate ShowIndicator];
        [self performSelector:@selector(loginUser) withObject:nil afterDelay:.1];

    }
    
}

-(void)loginUser
{
    
    [[WebService sharedManager] userLogin:userEmail.text andPassword:userPassword.text success:^(id responseObject) {
        // 1. can not login as email or password are incorrect
       //
        NSDictionary *dict = (NSDictionary *)responseObject;
        [self gotoSidebarMenu:dict];
        [self getASWKey];
        
    } failure:^(NSError *error) {
        
    }] ;
    
    
    
}

- (IBAction)createAccountButtonClicked:(id)sender
{
    textFields = @[signUpEmail,signUpPassword, confirmPassword];
    //Keyboard toolbar action to display toolbar with keyboard to move next,previous
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFields]];
    [self.keyboardControls setDelegate:self];
    
    backgroundSignUpView.hidden=NO;
    
    
}

-(void) getASWKey
{
    [[WebService sharedManager] getAWSKey:^(id getAWSData)
     {
         NSDictionary *dict = (NSDictionary *)getAWSData;
         [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"AccessKey"] forKey:@"AccessKey"];
         [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"SecretKey"] forKey:@"SecretKey"];
         [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"BucketName"] forKey:@"BucketName"];
         [[NSUserDefaults standardUserDefaults] synchronize];
         [myDelegate AWSInitialization];
         
     }failure:^(NSError *error)
     {
         
     }];
}
#pragma mark - end

#pragma mark - Sign up methods

- (IBAction)hideRegistrationPopup:(id)sender
{
    backgroundSignUpView.hidden=YES;
    textFields = @[userEmail,userPassword];
    //Keyboard toolbar action to display toolbar with keyboard to move next,previous
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textFields]];
    [self.keyboardControls setDelegate:self];
}
- (IBAction)signUpButtonClicked:(id)sender {
    
    if([self performValidationsForSignUp])
    {
        [myDelegate ShowIndicator];
        [self performSelector:@selector(signUpUser) withObject:nil afterDelay:.1];
    }
    
}

- (BOOL)performValidationsForSignUp
{
    UIAlertView *alert;
    if ([signUpEmail isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please enter the Email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else
    {
        if ([signUpEmail isValidEmail])
        {
            if ([signUpPassword isEmpty])
            {
                alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please enter the Password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                return NO;
            }
            else if (signUpPassword.text.length<6)
            {
            
                alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Your password must be atleast 6 characters long." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                return NO;
            
            }
            else if (!([signUpPassword.text isEqualToString:confirmPassword.text]))
            {
            
                alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Password and confirm password must be same." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                return NO;
            }
            else
            {
                return YES;
            }
        }
        else
        {
            alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please enter a valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
    }
}
-(void)signUpUser
{
    
    [[WebService sharedManager] registerUser:signUpEmail.text password:signUpPassword.text success:^(id responseObject) {
        // 1. can not login as email or password are incorrect
        NSDictionary *dict = (NSDictionary *)responseObject;
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"UserId"] forKey:@"UserId"];
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"Name"] forKey:@"Name"];
        [[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"HasBusinessProfile"] forKey:@"HasBusinessProfile"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"ProfileImage"];
        [myDelegate registerDeviceForNotification];
//        [[WebService sharedManager] registerDeviceForPushNotification:^(id responseObject) {
//            
//        } failure:^(NSError *error) {
//            
//        }] ;
         [self getASWKey];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        myDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [myDelegate.window setRootViewController:objReveal];
        [myDelegate.window setBackgroundColor:[UIColor whiteColor]];
        [myDelegate.window makeKeyAndVisible];
        
        
    } failure:^(NSError *error) {
        
    }] ;
 
    
    

}

#pragma mark - end

#pragma mark - Login with facebook

- (IBAction)loginWithFacebookButtonClicked:(id)sender
{
    
        if ([FBSession activeSession].state != FBSessionStateOpen && [FBSession activeSession].state != FBSessionStateOpenTokenExtended)
        {
            [myDelegate openActiveSessionWithPermissions:@[@"email"] allowLoginUI:YES];
            
        }
        else
        {
            // Close an existing session.
            [[FBSession activeSession] closeAndClearTokenInformation];
            
        }
    
}


-(void)handleFBSessionStateChangeWithNotification:(NSNotification *)notification
{
    [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    // Get the session, state and error values from the notification's userInfo dictionary.
    //Internet check to check internet connection is connected or not
    NSDictionary *userInfo = [notification userInfo];
    
    FBSessionState sessionState = (int)[[userInfo objectForKey:@"state"] integerValue];
    NSError *error = [userInfo objectForKey:@"error"];
    
    if (!error) {
        // In case that there's not any error, then check if the session opened or closed.
        if (sessionState == FBSessionStateOpen)
        {
            [myDelegate ShowIndicator];
            [FBRequestConnection startWithGraphPath:@"me"
                                         parameters:@{@"fields": @"email"}
                                         HTTPMethod:@"GET"
                                  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                      if (!error)
                                      {
                                          _userEmailFb=[result objectForKey:@"email"];
                                          [myDelegate ShowIndicator];
                                          [self performSelector:@selector(userLoginFb) withObject:nil afterDelay:.1];
                                      }
                                       
                                  }];
        }
        else if (sessionState == FBSessionStateClosed || sessionState == FBSessionStateClosedLoginFailed)
        {
            [myDelegate StopIndicator];
            
        }
    }
    else{
        
        [myDelegate StopIndicator];
        
    }
}


-(void)userLoginFb
{
    
    [[WebService sharedManager]userLoginFb:_userEmailFb success:^(id responseObject)
    {
        [myDelegate StopIndicator];
         NSDictionary *dict = (NSDictionary *)responseObject;
         [self gotoSidebarMenu:dict];
         [self getASWKey];
        
    } failure:^(NSError *error)
    {
         [myDelegate StopIndicator];
    }] ;
    
    [[FBSession activeSession] closeAndClearTokenInformation];
    
}


@end
