//
//  LoginViewController.h
//  SidebarDemoApp
//
//  Created by Ranosys on 11/02/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>


@interface LoginViewController : UIViewController


- (IBAction)loginButtonClicked:(id)sender;

- (IBAction)loginWithFacebookButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *loginFbBtn;
@property (weak, nonatomic) IBOutlet UIView *loginViewFields;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITextField *userEmail;
@property (weak, nonatomic) IBOutlet UITextField *userPassword;
- (IBAction)createAccountButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *backgroundSignUpView;

@property (weak, nonatomic) IBOutlet UIView *signUpView;
- (IBAction)hideRegistrationPopup:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIScrollView *signUpScrollView;
@property (weak, nonatomic) IBOutlet UITextField *signUpEmail;
@property (weak, nonatomic) IBOutlet UITextField *signUpPassword;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
- (IBAction)signUpButtonClicked:(id)sender;
@end
