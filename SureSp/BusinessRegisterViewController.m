//
//  MainViewController.m
//  SidebarDemoApp
//
//  Created by Ranosys on 06/02/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "BusinessRegisterViewController.h"
#import "SWRevealViewController.h"
#import "UITextField+Padding.h"
#import "UIView+RoundedCorner.h"
#import "UIPlaceHolderTextView.h"
#import "MyButton.h"
#import "Constants.h"
#import "UITextField+Validations.h"
#import "UITextView+Validations.h"
#import "BFTask.h"
#import <AWSS3/AWSS3.h>
#import "BusinessDataModel.h"
#import "AWSDownload.h"
#import "STKSpinnerView.h"
#import "slider.h"
#import "BSKeyboardControls.h"
#import "ALPickerView.h"
#import "CYCustomMultiSelectPickerView.h"
#import "UIPlaceHolderTextView.h"
#import "UIImage+UIImage_fixOrientation.h"
#import <CoreLocation/CoreLocation.h>
#import "MJGeocodingServices.h"
#import "AppDelegate.h"
#import <UIImageView+AFNetworking.h>
#define SLIDER_VIEW_TAG     1234
@interface BusinessRegisterViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,CYCustomMultiSelectPickerViewDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,BSKeyboardControlsDelegate,MJGeocoderDelegate>
{
    int button_tag;
    NSString * subCategoryId;
    NSString * categoryId;
    int cityId;
    NSDictionary * subCategoryDict;
    bool onSite;
    bool inShop;
    AWSDownload *download;
    MJGeocoder *forwardGeocoder;
    NSMutableArray *awsImageArray;
    NSMutableArray * workingHoursArray;
    __weak IBOutlet UICollectionView * collectionView;
    STKSpinnerView *progress;
    UILabel *leftLabel;
    UILabel *rightLabel;
    __weak IBOutlet UIView *sliderContainer;
    __weak IBOutlet UIButton *closeSliderBtn;
    __weak IBOutlet UIButton *doneSliderBtn;
    __weak IBOutlet UIButton *uploadImageBtn;
    slider *slider1;
    __weak IBOutlet UILabel *selectDaysLbl;
    CYCustomMultiSelectPickerView *multiPickerView;
    NSString * imageName;
    UIImagePickerController *ImgPicker;
    __weak IBOutlet UIBarButtonItem *saveButton;
    __weak IBOutlet UISwitch *inShopSwitch;
    __weak IBOutlet UISwitch *onSiteSwitch;
    __weak IBOutlet UITextField *cityField;
    __weak IBOutlet UIActivityIndicatorView *uploadImageIndicator;
    double latitude;
    double longitude;
    bool isCityPicker;
    AppDelegate *appdelegate;
}
- (void)valueChangedForDoubleSlider:(slider *)slider;
@property(nonatomic, retain) MJGeocoder *forwardGeocoder;
@property (weak, nonatomic) IBOutlet UILabel *businessHourLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *setHourCollectionView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *uploadProfilePicLabel;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *companyName;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *shopLocationTextView;
@property (weak, nonatomic) IBOutlet UIView *postalView;
@property (weak, nonatomic) IBOutlet UITextField *postalTextField;
@property (weak, nonatomic) IBOutlet UITextField *contactField;
@property (weak, nonatomic) IBOutlet UITextField *selectCategoryField;
@property (weak, nonatomic) IBOutlet UITextField *selectSubCategoryField;
@property (weak, nonatomic) IBOutlet UITextField *otherSubCategory;
@property (weak, nonatomic) IBOutlet UIToolbar *pickerToolbar;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
@property(nonatomic,retain)NSMutableArray * categoryPickerArray;
@property(nonatomic,retain)NSMutableArray * subCategoryPickerArray;
@property(nonatomic,retain)NSMutableArray * selectedSubcategoryArray;
@property(nonatomic,retain)NSDictionary * dataDict;
@property(nonatomic,retain)NSString * subCatStr;
@property (strong,nonatomic) NSArray *hourArray;
@property (strong,nonatomic) NSArray *minutesArray;
@property (strong,nonatomic) NSArray *weekArray;
@property (weak, nonatomic) IBOutlet UIView *hourSelectionView;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (strong,nonatomic) NSMutableArray *businessRegisterData;
@property (strong,nonatomic) NSMutableArray *cityArray;
@property (strong,nonatomic) NSDictionary *cityDict;

- (IBAction)closeHourView:(id)sender;
- (IBAction)saveHourSelection:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)toolBarDoneClicked:(id)sender;
- (IBAction)selectSubCategoryDropdownAction:(id)sender;
- (IBAction)selectCategoryDropdownAction:(id)sender;

@end

@implementation BusinessRegisterViewController
@synthesize nameView,nameField,companyName,postalTextField,contactField,selectCategoryField,selectSubCategoryField,descriptionTextView,shopLocationTextView,postalView,uploadProfilePicLabel,categoryPickerArray,otherSubCategory,subCatStr;
@synthesize dataDict,selectedSubcategoryArray,subCategoryPickerArray,businessHourLabel,setHourCollectionView,profileImage;
@synthesize hourSelectionView,businessRegisterData,cityArray,cityDict,forwardGeocoder;
//@synthesize s3 = _s3;

#pragma mark - View life cycle

-(void)layoutCustomSlider
{
    [slider1 removeFromSuperview];
    [leftLabel removeFromSuperview];
    [rightLabel removeFromSuperview];
    slider1 = [slider doubleSlider];
    //sliderContainer.translatesAutoresizingMaskIntoConstraints=YES;
    //sliderContainer.frame=CGRectMake(10, sliderContainer.frame.origin.y, self.view.frame.size.width- 0, sliderContainer.frame.size.height);
    [slider1 addTarget:self action:@selector(valueChangedForDoubleSlider:) forControlEvents:UIControlEventValueChanged];
    //    slider1.center = hourSelectionView.center;
    slider1.frame=CGRectMake((sliderContainer.frame.size.width/2)-127, closeSliderBtn.frame.origin.y-40, slider1.frame.size.width, slider1.frame.size.height);
    slider1.tag = SLIDER_VIEW_TAG; //for testing purposes only
    [sliderContainer addSubview:slider1];
    
    leftLabel = [[UILabel alloc] initWithFrame:CGRectOffset(slider1.frame, 0, -slider1.frame.size.height)];
    leftLabel.textAlignment =NSTextAlignmentCenter;
    leftLabel.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    leftLabel.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    leftLabel.layer.shadowOffset = CGSizeMake(2, 2);
    leftLabel.layer.shadowOpacity = 1.0;
    leftLabel.frame = CGRectMake(80, slider1.frame.origin.y-45, 50, 30);
    leftLabel.font=[UIFont fontWithName:@"HelveticaNeue" size:14];
    leftLabel.textColor = [UIColor colorWithRed:106.0/255.0 green:106.0/255.0 blue:106.0/255.0 alpha:1.0];
    leftLabel.layer.masksToBounds = NO;
    [sliderContainer addSubview:leftLabel];
    rightLabel = [[UILabel alloc] initWithFrame:CGRectOffset(slider1.frame, 0, -slider1.frame.size.height)];
    rightLabel.textAlignment =NSTextAlignmentCenter;
    rightLabel.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    rightLabel.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    rightLabel.layer.shadowOffset =  CGSizeMake(2, 2);
    rightLabel.layer.shadowOpacity = 1.0;
    rightLabel.frame = CGRectMake(160, slider1.frame.origin.y-45, 50, 30);
    rightLabel.textColor = [UIColor colorWithRed:106.0/255.0 green:106.0/255.0 blue:106.0/255.0 alpha:1.0];
    rightLabel.layer.masksToBounds = NO;
    rightLabel.font=[UIFont fontWithName:@"HelveticaNeue" size:14];
    [sliderContainer addSubview:rightLabel];
    
    doneSliderBtn.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    doneSliderBtn.layer.shadowOffset = CGSizeMake(2, 2);
    doneSliderBtn.layer.shadowOpacity = 0.5;
    
    closeSliderBtn.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    closeSliderBtn.layer.shadowOffset = CGSizeMake(2, 2);
    closeSliderBtn.layer.shadowOpacity = 0.5;
    
    [self valueChangedForDoubleSlider:slider1];
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    uploadImageIndicator.hidden=YES;
    [uploadImageIndicator stopAnimating];
    appdelegate=(AppDelegate*)[UIApplication sharedApplication].delegate;
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
    //[self layoutCustomSlider];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    // Do any additional setup after loading the view.
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
    }
    //    progress=(STKSpinnerView *)[self.view viewWithTag:30];
    //    progress.hidden=YES;
    //    progress.progress=0.0f;
    progress.hidden = YES;
    
    [self addTextFieldPadding];
    [self roundedCorner];
    
    [descriptionTextView setPlaceholder:@"Professional experience"];
    [shopLocationTextView setPlaceholder:@"Shop Location"];
    
    categoryPickerArray = [[NSMutableArray alloc]init];
    subCategoryPickerArray=[[NSMutableArray alloc]init];
    selectedSubcategoryArray = [[NSMutableArray alloc]init];
    businessRegisterData=[[NSMutableArray alloc]init];
    subCatStr = [[NSString alloc]init];
    cityArray = [[NSMutableArray alloc]init];
    _categoryPicker.translatesAutoresizingMaskIntoConstraints = YES;
    _pickerToolbar.translatesAutoresizingMaskIntoConstraints = YES;
    
    
    self.hourArray = @[@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23"];
    self.minutesArray = @[@"00",@"30"];
    self.weekArray  = [[NSArray alloc]initWithObjects:@"Mon",@"Tue",@"Wed",@"Thur",@"Fri",@"Sat",@"Sun", nil];
    [self setValueForTimeArray];
    otherSubCategory.hidden=YES;
    hourSelectionView.hidden=YES;
    subCategoryId = @"";
    categoryId=@"";
    ImgPicker = [[UIImagePickerController alloc] init];
    imageName = [[NSString alloc]init];
    imageName = @"";
    [self roundCornersOfObjects];
    
    NSArray * fieldArray = @[nameField,companyName,descriptionTextView,shopLocationTextView,postalTextField,contactField];
    //Keyboard toolbar action to display toolbar with keyboard to move next,previous
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fieldArray]];
    [self.keyboardControls setDelegate:self];
    
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getCategoryAndSubcategoryFromServer) withObject:nil afterDelay:.3];
    
    [descriptionTextView setTextContainerInset:UIEdgeInsetsMake(9, 5, 0,0)];
    [shopLocationTextView setTextContainerInset:UIEdgeInsetsMake(9, 5, 0,0)];
    [inShopSwitch addTarget:self action:@selector(inShopSwitchAction:) forControlEvents:UIControlEventValueChanged];
    [onSiteSwitch addTarget:self action:@selector(onSiteSwitchAction:) forControlEvents:UIControlEventValueChanged];
}

-(void)roundCornersOfObjects
{
    profileImage.layer.cornerRadius=50.0f;
    profileImage.clipsToBounds=YES;
    inShopSwitch.layer.cornerRadius = 16.0;
    onSiteSwitch.layer.cornerRadius = 16.0;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc
{
    categoryPickerArray = nil;
    subCategoryPickerArray=nil;
    selectedSubcategoryArray = nil;
    businessRegisterData=nil;
    subCatStr = nil;
    cityArray = nil;
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"HasBusinessProfile"]==1)
    {
        self.title=@"Edit Business";
    }
    else
    {
        self.title=@"Business Registration";
    }
}

-(void)addTextFieldPadding
{
    nameField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [nameField addTextFieldPaddingWithoutImages:nameField];
    [companyName addTextFieldPaddingWithoutImages:companyName];
    [postalTextField addTextFieldPaddingWithoutImages:postalTextField];
    [contactField addTextFieldPaddingWithoutImages:contactField];
    [cityField addTextFieldPaddingWithoutImages:cityField];
    [selectCategoryField addTextFieldPaddingWithoutImages:selectCategoryField];
    [selectSubCategoryField addTextFieldPaddingWithoutImages:selectSubCategoryField];
    [otherSubCategory addTextFieldPaddingWithoutImages:otherSubCategory];
}

-(void) roundedCorner
{
    [nameView setCornerRadius:4.0f];
    [descriptionTextView setCornerRadius:1.0f];
    [shopLocationTextView setCornerRadius:1.0f];
    [postalView setCornerRadius:2.0f];
    [postalTextField setCornerRadius:2.0f];
    [contactField setCornerRadius:2.0f];
    [selectCategoryField setCornerRadius:2.0f];
    [selectSubCategoryField setCornerRadius:2.0f];
    inShopSwitch.layer.cornerRadius = 16.0;
    onSiteSwitch.layer.cornerRadius = 16.0;
    [inShopSwitch setThumbTintColor:[UIColor whiteColor]];
    [inShopSwitch setOnTintColor:[UIColor colorWithRed:178.0/256.0 green:178.0/256.0 blue:178.0/256.0 alpha:1]];
    [inShopSwitch setBackgroundColor:[UIColor colorWithRed:178.0/256.0 green:178.0/256.0 blue:178.0/256.0 alpha:1]];
    [onSiteSwitch setThumbTintColor:[UIColor whiteColor]];
    [onSiteSwitch setOnTintColor:[UIColor colorWithRed:178.0/256.0 green:178.0/256.0 blue:178.0/256.0 alpha:1]];
    [onSiteSwitch setBackgroundColor:[UIColor colorWithRed:178.0/256.0 green:178.0/256.0 blue:178.0/256.0 alpha:1]];
    inShopSwitch.on = NO;
    onSiteSwitch.on = NO;
    
}


- (IBAction)uploadImageAction:(id)sender {
    
    UIActionSheet * share=[[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Choose Existing Photo", nil];
    [share showInView:[UIApplication sharedApplication].keyWindow];
}

#pragma mark - end


#pragma mark Control Event Handlers

- (void)valueChangedForDoubleSlider:(slider *)slider
{
    
    leftLabel.text = [NSString stringWithFormat:@"0%0.1f", (slider.minSelectedValue/2)-0.5];
    NSArray *items = [leftLabel.text componentsSeparatedByString:@"."];
    if ([[items objectAtIndex:1] isEqualToString:@"5"])
    {
        leftLabel.text=[NSString stringWithFormat:@"%@:30",[items objectAtIndex:0]];
    }
    else
    {
        leftLabel.text=[NSString stringWithFormat:@"%@:00",[items objectAtIndex:0]];
    }
    rightLabel.text = [NSString stringWithFormat:@"%0.1f", (slider.maxSelectedValue/2)-0.5];
    items = [rightLabel.text componentsSeparatedByString:@"."];
    if ([[items objectAtIndex:1] isEqualToString:@"5"])
    {
        rightLabel.text=[NSString stringWithFormat:@"%@:30",[items objectAtIndex:0]];
    }
    else
    {
        if ([[items objectAtIndex:0] isEqualToString:@"24"])
        {
            rightLabel.text=[NSString stringWithFormat:@"24:00"];
        }
        else
            rightLabel.text=[NSString stringWithFormat:@"%@:00",[items objectAtIndex:0]];
    }
}


#pragma mark - switch action



- (void)inShopSwitchAction:(id)sender
{
    BOOL state = [sender isOn];
    if (state)
    {
        [inShopSwitch setThumbTintColor:[UIColor colorWithRed:248.0/256.0 green:80.0/256.0 blue:84.0/256.0 alpha:1]];
        [inShopSwitch setBackgroundColor:[UIColor colorWithRed:178.0/256.0 green:178.0/256.0 blue:178.0/256.0 alpha:1]];
        [inShopSwitch setOnTintColor:[UIColor colorWithRed:178.0/256.0 green:178.0/256.0 blue:178.0/256.0 alpha:1]];
        inShop = true;
    }
    else
    {
        [inShopSwitch setThumbTintColor:[UIColor whiteColor]];
        [inShopSwitch setOnTintColor:[UIColor colorWithRed:178.0/256.0 green:178.0/256.0 blue:178.0/256.0 alpha:1]];
        [inShopSwitch setBackgroundColor:[UIColor colorWithRed:178.0/256.0 green:178.0/256.0 blue:178.0/256.0 alpha:1]];
        inShop = false;
    }
}

- (void)onSiteSwitchAction:(id)sender
{
    BOOL state = [sender isOn];
    if (state)
    {
        [onSiteSwitch setThumbTintColor:[UIColor colorWithRed:248.0/256.0 green:80.0/256.0 blue:84.0/256.0 alpha:1]];
        [onSiteSwitch setBackgroundColor:[UIColor colorWithRed:178.0/256.0 green:178.0/256.0 blue:178.0/256.0 alpha:1]];
        [onSiteSwitch setOnTintColor:[UIColor colorWithRed:178.0/256.0 green:178.0/256.0 blue:178.0/256.0 alpha:1]];
        onSite = true;
    }
    else
    {
        [onSiteSwitch setThumbTintColor:[UIColor whiteColor]];
        [onSiteSwitch setOnTintColor:[UIColor colorWithRed:178.0/256.0 green:178.0/256.0 blue:178.0/256.0 alpha:1]];
        [onSiteSwitch setBackgroundColor:[UIColor colorWithRed:178.0/256.0 green:178.0/256.0 blue:178.0/256.0 alpha:1]];
        onSite = false;
    }
}

#pragma mark - end
#pragma mark - Actionsheet
//Action sheet for setting image from camera or gallery
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex==0)
    {
        //Setting image from camera
        [ImgPicker setAllowsEditing:YES];
        ImgPicker = [[UIImagePickerController alloc] init];
        ImgPicker.delegate = self;
        ImgPicker.allowsEditing = YES;
        ImgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
        [self presentViewController:ImgPicker animated:YES completion:NULL];
    }
    else if(buttonIndex==1)
    {
        //Setting image from gallery
        [ImgPicker setAllowsEditing:YES];
        ImgPicker.delegate = self;
        ImgPicker.allowsEditing = YES;
        ImgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:ImgPicker animated:YES completion:NULL];
    }
    
}
#pragma mark - end

#pragma mark - Web service methods
-(void)removeKeyboardFromScreen
{
    [_keyboardControls.activeField resignFirstResponder];
    [otherSubCategory resignFirstResponder];
}
- (BOOL)performValidations
{
    UIAlertView *alert;
    if ([nameField isEmpty] || [companyName isEmpty] || [descriptionTextView isEmpty] || [shopLocationTextView isEmpty] || [postalTextField isEmpty] || [contactField isEmpty] || [selectCategoryField isEmpty] || [selectSubCategoryField isEmpty] || [cityField isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please fill in all fields." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if (otherSubCategory.hidden == NO && [otherSubCategory isEmpty])
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please fill other category." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if (!(onSiteSwitch.isOn || inShopSwitch.isOn))
    {
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please select either in shop service or on site service." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    else
    {
        BOOL hasData = false;
        for (int i = 0; i<workingHoursArray.count; i++)
        {
            NSDictionary * tempDict = [workingHoursArray objectAtIndex:i];
            if (!(([[tempDict objectForKey:@"StartTime"] isEqualToString:@"00:00"]||[[tempDict objectForKey:@"StartTime"] isEqualToString:@"00:00:00"]) & ([[tempDict objectForKey:@"EndTime"] isEqualToString:@"00:00"]||[[tempDict objectForKey:@"EndTime"] isEqualToString:@"00:00:00"])))
            {
                hasData = true;
            }
            
        }
        if (!hasData)
        {
            alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please select working hours." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
        
    }
    return YES;
}

-(void)businessRegister
{
    
    [[WebService sharedManager]businessRegister:imageName name:nameField.text businessName:companyName.text BusinessDescription:descriptionTextView.text InShop:inShop Onsite:onSite Location:shopLocationTextView.text PinCode:postalTextField.text PhoneNo:contactField.text ServiceCategory:categoryId SubCategory:selectedSubcategoryArray OtherSubcategory:otherSubCategory.text Days:workingHoursArray cityId:cityId latitude:[NSString stringWithFormat:@"%f",latitude] longitude:[NSString stringWithFormat:@"%f",longitude] success:^(id responseObject)
     {
         // 1. can not login as email or password are incorrect
         NSDictionary *dict = (NSDictionary *)responseObject;
         [[NSUserDefaults standardUserDefaults] setObject:nameField.text forKey:@"Name"];
         [[NSUserDefaults standardUserDefaults]setObject:imageName forKey:@"ProfileImage"];
         //[[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"ServiceCount"] forKey:@"ServiceCount"];
         [[NSUserDefaults standardUserDefaults] setInteger:[[dict objectForKey:@"ServiceCount"]intValue] forKey:@"ServiceCount"];
         [[NSUserDefaults standardUserDefaults]synchronize];
         if(![[[NSUserDefaults standardUserDefaults]objectForKey:@"ProfileImage"] isEqualToString:@""])
         {
             myDelegate.sideBarImage = nil;
             [myDelegate startImageDownloading:imageName];
         }
         [[NSUserDefaults standardUserDefaults]synchronize];
         UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:[dict objectForKey:@"Message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
         alert.tag =07;
         [alert show];
         
     } failure:^(NSError *error)
     {
         if ([[NSUserDefaults standardUserDefaults] integerForKey:@"HasBusinessProfile"]==1) {
             
             [self performSelectorOnMainThread:@selector(refreshServiceData) withObject:nil waitUntilDone:YES];
         }
         
     }] ;
    
    
}

-(void)refreshServiceData
{
    [myDelegate ShowIndicator];
    [self performSelector:@selector(GetBusinessRegisterDataFromServer) withObject:nil afterDelay:.1];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag==07)
    {
        self.navigationController.navigationBar.hidden = YES;
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"HasBusinessProfile"];
        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *view1=[sb instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        [self.navigationController pushViewController:view1 animated:YES];
    }
    
    
}

-(void)getCitiesFromServer
{
    [[WebService sharedManager]getCitiesFromServer:^(id responseObject) {
        [myDelegate StopIndicator];
        cityDict = (NSDictionary *)responseObject ;
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"HasBusinessProfile"]==1)
        {
            [myDelegate ShowIndicator];
            [self performSelector:@selector(GetBusinessRegisterDataFromServer) withObject:nil afterDelay:0];
        }
        
    } failure:^(NSError *error) {
        
    }] ;
    
}

-(void)getCategoryAndSubcategoryFromServer
{
    
    [[WebService sharedManager]getCategoriesForBusinessRegistration:^(id responseObject) {
        
        dataDict = (NSDictionary *)responseObject;
        //[myDelegate ShowIndicator];
        [self performSelector:@selector(getCitiesFromServer) withObject:nil afterDelay:.1];
        
    } failure:^(NSError *error) {
        
    }] ;
    
}


-(void)GetBusinessRegisterDataFromServer
{
    [[WebService sharedManager] GetBusinessRegisterData:^(id getBusinessRegisterData) {
        [myDelegate StopIndicator];
        [businessRegisterData removeAllObjects];
        businessRegisterData=[getBusinessRegisterData mutableCopy];
        
        [self displayBusinessRegisterData];
        
    } failure:^(NSError *error)
    {
        
    }] ;
    
}

#pragma mark - end

#pragma mark - Fetch business register data


-(NSDictionary *)getCategoryvalues : (NSString *)catId
{
    NSArray * tmpAry = [dataDict objectForKey:@"CategoryList"];
    NSDictionary * tmpDict;
    for (int i =0; i<tmpAry.count; i++)
    {
        tmpDict = [tmpAry objectAtIndex:i];
        
        if ([catId intValue] ==[[tmpDict objectForKey:@"Id"]intValue])
        {
            break;
        }
    }
    return tmpDict;
}
-(void) displayBusinessRegisterData
{
    
    BusinessDataModel *data=[businessRegisterData objectAtIndex:0];
    
    
    awsImageArray=[NSMutableArray new];
    if (![data.profileImage isEqual:@""])
    {
        uploadImageBtn.enabled = NO;
        uploadProfilePicLabel.hidden=YES;
        profileImage.image=[UIImage imageNamed:@"download"];
        download = [[AWSDownload alloc]init];
        download.delegate = self;
        //progress.hidden=NO;
        [awsImageArray addObject:data.profileImage];
        imageName=data.profileImage;
        [myDelegate StopIndicator];
        //uploadImageIndicator.hidden=NO;
        //[uploadImageIndicator startAnimating];
        [self displayProfilePicture:data.profileImage];
        //[download listObjects:self ImageName:awsImageArray folderName:@"businessprofileimages"];
    }
    else
    {
        
        [myDelegate StopIndicator];
    }
    
    nameField.text=data.Name;
    descriptionTextView.text=data.businessDescription;
    companyName.text=data.businessName;
    postalTextField.text=[NSString stringWithFormat:@"%@",data.pinCode];
    contactField.text=[NSString stringWithFormat:@"%@",data.Contact];
    shopLocationTextView.text=data.Address;
    NSDictionary * displayDict =[self getCategoryvalues:data.serviceCategory];
    categoryId =  [displayDict objectForKey:@"Id"];
    selectCategoryField.text =[displayDict objectForKey:@"Name"];
    //[self setInitialValueToPicker];
//    NSInteger index = [_categoryPicker selectedRowInComponent:0];
//    NSString *title = [[_categoryPicker delegate] pickerView:_categoryPicker titleForRow:index forComponent:0];
    [_categoryPicker reloadAllComponents];
    NSArray * tempAry =[displayDict objectForKey:@"SubCategory"];
    for (int i=0; i<tempAry.count; i++)
    {
        NSDictionary * subCategory =[tempAry objectAtIndex:i];
        
        [appdelegate.multiplePickerDic setObject:[NSNumber numberWithBool:NO] forKey:[subCategory objectForKey:@"Name"]];
        if (i==tempAry.count-1)
        {
            [appdelegate.multiplePickerDic setObject:[NSNumber numberWithBool:NO] forKey:@"Other"];
        }
        
    }
    
    
    [self getSubCategoryData:displayDict data:data.subCategory];
    selectSubCategoryField.text = subCatStr;
    selectedSubcategoryArray = [data.subCategory mutableCopy];
    subCategoryDict = displayDict;
    cityId = [data.cityId intValue];
    [self setCityfromArray];
    [workingHoursArray removeAllObjects];
    
    for (int i =0; i<data.businessHours.count; i++)
    {
        NSDictionary * hoursDict = [data.businessHours objectAtIndex:i];
        NSDictionary * tmpDict = [hoursDict mutableCopy];
        [workingHoursArray addObject:tmpDict];
        if((![[hoursDict objectForKey:@"StartTime"]isEqualToString:@"00:00:00"]) || (![[hoursDict objectForKey:@"EndTime"]isEqualToString:@"00:00:00"]))
        {
            
                NSIndexPath * index = [NSIndexPath indexPathForItem:[[tmpDict objectForKey:@"BussinessDay"]intValue]-1 inSection:0];
                UICollectionViewCell *tmpCell = [collectionView cellForItemAtIndexPath:index];
                MyButton * btn =(MyButton *)[tmpCell.contentView viewWithTag:2];
                [btn setSelected:YES];
            
            
        }
    }
    
    if ([data.inShop boolValue])
    {
        inShop = true;
        inShopSwitch.on = YES;
        [inShopSwitch setThumbTintColor:[UIColor colorWithRed:248.0/256.0 green:80.0/256.0 blue:84.0/256.0 alpha:1]];
        [inShopSwitch setBackgroundColor:[UIColor colorWithRed:178.0/256.0 green:178.0/256.0 blue:178.0/256.0 alpha:1]];
        [inShopSwitch setOnTintColor:[UIColor colorWithRed:178.0/256.0 green:178.0/256.0 blue:178.0/256.0 alpha:1]];
    }
    else
    {
      inShopSwitch.on = NO;
        inShop = false;
        [inShopSwitch setThumbTintColor:[UIColor whiteColor]];
        [inShopSwitch setOnTintColor:[UIColor colorWithRed:178.0/256.0 green:178.0/256.0 blue:178.0/256.0 alpha:1]];
        [inShopSwitch setBackgroundColor:[UIColor colorWithRed:178.0/256.0 green:178.0/256.0 blue:178.0/256.0 alpha:1]];
    
    }
    if ([data.onSite boolValue])
    {
        onSite = true;
        onSiteSwitch.on = YES;
        [onSiteSwitch setThumbTintColor:[UIColor colorWithRed:248.0/256.0 green:80.0/256.0 blue:84.0/256.0 alpha:1]];
        [onSiteSwitch setBackgroundColor:[UIColor colorWithRed:178.0/256.0 green:178.0/256.0 blue:178.0/256.0 alpha:1]];
        [onSiteSwitch setOnTintColor:[UIColor colorWithRed:178.0/256.0 green:178.0/256.0 blue:178.0/256.0 alpha:1]];
    }
    else
    {
        onSite = false;
        onSiteSwitch.on = NO;
        [onSiteSwitch setThumbTintColor:[UIColor whiteColor]];
        [onSiteSwitch setOnTintColor:[UIColor colorWithRed:178.0/256.0 green:178.0/256.0 blue:178.0/256.0 alpha:1]];
        [onSiteSwitch setBackgroundColor:[UIColor colorWithRed:178.0/256.0 green:178.0/256.0 blue:178.0/256.0 alpha:1]];
    }
    if (![data.otherSubCategory isEqualToString:@""])
    {
        otherSubCategory.hidden=NO;
        otherSubCategory.text = data.otherSubCategory;
        businessHourLabel.translatesAutoresizingMaskIntoConstraints = YES;
        setHourCollectionView.translatesAutoresizingMaskIntoConstraints=YES;
        otherSubCategory.translatesAutoresizingMaskIntoConstraints=YES;
        selectSubCategoryField.translatesAutoresizingMaskIntoConstraints=YES;
      
        otherSubCategory.frame=CGRectMake(self.view.frame.origin.x+13, selectSubCategoryField.frame.origin.y+68, selectSubCategoryField.frame.size.width, selectSubCategoryField.frame.size.height);
        businessHourLabel.frame=CGRectMake(self.view.frame.origin.x+13, otherSubCategory.frame.origin.y+60, businessHourLabel.frame.size.width, businessHourLabel.frame.size.height);
        setHourCollectionView.frame=CGRectMake(self.view.frame.origin.x, businessHourLabel.frame.origin.y+25, self.view.frame.size.width, setHourCollectionView.frame.size.height);
    }
    
    
    
}

-(void)setInitialValueToPicker
{
   NSArray * catArray = [dataDict objectForKey:@"CategoryList"];
    int index = 0;
    [categoryPickerArray removeAllObjects];
    for (int i =0; i<catArray.count; i++)
    {
        NSDictionary * tempDict = [catArray objectAtIndex:i];
        [ categoryPickerArray addObject:[tempDict objectForKey:@"Name"]];
        if ([categoryId intValue]==[[tempDict objectForKey:@"Id"]intValue])
        {
            index = i;
            
        }
    }
    [_categoryPicker selectRow:index inComponent:0 animated:NO];
    [_categoryPicker reloadAllComponents];
}

-(void)displayProfilePicture:(NSString * )imgName
{
    
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:50 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://s3-ap-southeast-1.amazonaws.com/%@/businessprofileimages/%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"BucketName"],imgName]] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0f];
   // NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://s3-ap-southeast-1.amazonaws.com/ranosystesting/businessprofileimages/%@",imgName]] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0f];
    UIImage *image = [[UIImageView sharedImageCache] cachedImageForRequest:urlRequest];
    if (image != nil) {
        profileImage.image = image;
        uploadImageBtn.enabled = YES;
        return;
    }
    else
    {
        AFHTTPRequestOperation *postOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        postOperation.responseSerializer = [AFImageResponseSerializer serializer];
        [postOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            UIImage *image = responseObject;
            profileImage.image = image;
            uploadImageBtn.enabled = YES;
            [[UIImageView sharedImageCache] cacheImage:image forRequest:urlRequest];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             uploadImageBtn.enabled = YES;
         }];
        [postOperation start];
    }
}

-(void)setCityfromArray
{
    NSArray * tmpAry = [cityDict objectForKey:@"CityList"];
    
    for (int i = 0; i<tmpAry.count; i++)
    {
        NSDictionary * tmpDict = [tmpAry objectAtIndex:i];
        if (cityId==[[tmpDict objectForKey:@"Id"] intValue])
        {
            cityField.text = [tmpDict objectForKey:@"Name"];
        }
    }
    
}


-(NSString *)getSubCategoryData : (NSDictionary *)catData  data:(NSArray *)data
{
    
    NSArray * tmpAry = [catData objectForKey:@"SubCategory"];
    NSMutableArray * tmpMutableAry = [[NSMutableArray alloc]init];
    for (int i = 0; i<data.count; i++)
    {
        NSDictionary * selectedSubCat = [data objectAtIndex:i];
        
        for (int k =0; k<tmpAry.count; k++)
        {
            NSDictionary * allSubCat = [tmpAry objectAtIndex:k];
            if ([[selectedSubCat objectForKey:@"Id"]intValue]==[[allSubCat objectForKey:@"Id"]intValue])
            {
                [tmpMutableAry addObject:[allSubCat objectForKey:@"Name"]];
                [appdelegate.multiplePickerDic setObject:[NSNumber numberWithBool:YES] forKey:[allSubCat objectForKey:@"Name"]];
                subCatStr = [tmpMutableAry componentsJoinedByString:@","];;
            }
            
        }
        
    }
    return subCatStr;
    
}
#pragma mark - end

#pragma mark - Collection view methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return 7;
    
}
-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView1 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *myCell = [collectionView1
                                    dequeueReusableCellWithReuseIdentifier:@"daysCell"
                                    forIndexPath:indexPath];
    
    UILabel *weekLabel=(UILabel *)[myCell viewWithTag:1];
    weekLabel.text=[self.weekArray objectAtIndex:indexPath.row];
    
    MyButton *button=(MyButton *)[myCell viewWithTag:2];
    button.Tag = (int)indexPath.row;
    [button addTarget:self action:@selector(businessHourSelectionAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return myCell;
    
    
}

-(IBAction)businessHourSelectionAction:(id)sender
{
    [self layoutCustomSlider];
    button_tag=[sender Tag];
    NSMutableDictionary * tempDict = [workingHoursArray objectAtIndex:button_tag];
    NSArray  * tempAry  = [[NSArray alloc]initWithObjects:@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday",@"Sunday", nil];
    selectDaysLbl.text = [NSString stringWithFormat:@"Select business hours for %@",[tempAry objectAtIndex:[sender Tag]]];
    if([sender isSelected])
    {
        [sender setSelected:NO];
        [tempDict setObject:@"00:00" forKey:@"StartTime"];
        [tempDict setObject:@"00:00" forKey:@"EndTime"];
        //[tempDict setObject:@"NO" forKey:@"iSSelectedBefore"];
        [workingHoursArray replaceObjectAtIndex:button_tag withObject:tempDict];
        return;
    }
    hourSelectionView.hidden=NO;
    
}

-(void)setValueForTimeArray
{
    workingHoursArray = [[NSMutableArray alloc]init];
    
    // [{"BussinessDay":"1", "StartTime":"8",  "EndTime":"16"},....]}
    
    for (int i = 0; i<self.weekArray.count; i++)
    {
        NSMutableDictionary * tempDict = [NSMutableDictionary new];
        [tempDict setObject:[NSNumber numberWithInt:i+1] forKey:@"BussinessDay"];
        [tempDict setObject:@"00:00" forKey:@"StartTime"];
        [tempDict setObject:@"00:00" forKey:@"EndTime"];
        //[tempDict setObject:@"NO" forKey:@"iSSelectedBefore"];
        [workingHoursArray addObject:tempDict];
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    //You may want to create a divider to scale the size by the way..
    return CGSizeMake(90, 35);
}

#pragma mark - end

#pragma mark - IBAction
-(void)getLatLongFromAddress
{
    
    
    if(!forwardGeocoder){
        forwardGeocoder = [[MJGeocoder alloc] init];
        forwardGeocoder.delegate = self;
    }
    
    //show network indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *string=[NSString stringWithFormat:@"%@, %@, %@",shopLocationTextView.text,postalTextField.text,cityField.text];
    
    [forwardGeocoder findLocationsWithAddress:string title:nil];
    
}
- (IBAction)save:(id)sender
{
    
    if([self performValidations])
    {
        [myDelegate ShowIndicator];
        [self performSelector:@selector(getLatLongFromAddress) withObject:nil afterDelay:.1];
    }
    
}
- (IBAction)selectCityBtnClicked:(id)sender
{
    [_keyboardControls.activeField resignFirstResponder];
    [otherSubCategory resignFirstResponder];
    isCityPicker=true;
    [cityArray removeAllObjects];
    NSArray * tempAry  = [cityDict objectForKey:@"CityList"];
    for (int i = 0; i<tempAry.count; i++)
    {
        NSDictionary * tempDict =[tempAry objectAtIndex:i];
        [cityArray addObject:[tempDict objectForKey:@"Name"]];
    }
    [_categoryPicker reloadAllComponents];
    [_scrollView setContentOffset:CGPointMake(0, selectCategoryField.frame.origin.y-150) animated:YES];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _categoryPicker.frame = CGRectMake(_categoryPicker.frame.origin.x, self.view.bounds.size.height-_categoryPicker.frame.size.height , self.view.bounds.size.width, _categoryPicker.frame.size.height);
    _pickerToolbar.frame = CGRectMake(_pickerToolbar.frame.origin.x, _categoryPicker.frame.origin.y-44, self.view.bounds.size.width, _pickerToolbar.frame.size.height);
    [UIView commitAnimations];
}


- (IBAction)selectSubCategoryDropdownAction:(id)sender
{
    [_keyboardControls.activeField resignFirstResponder];
    [otherSubCategory resignFirstResponder];
    [self hidePickerWithAnimation];
    [subCategoryPickerArray removeAllObjects];
    _scrollView.scrollEnabled = NO;
    [_scrollView setContentOffset:CGPointMake(0, selectSubCategoryField.frame.origin.y-90) animated:YES];
    NSArray * tempAry =[subCategoryDict objectForKey:@"SubCategory"];
    for (int i=0; i<tempAry.count; i++)
    {
        NSDictionary * subCategory =[tempAry objectAtIndex:i];
        [subCategoryPickerArray addObject:[subCategory objectForKey:@"Name"]];
        
        if (i==tempAry.count-1)
        {
            [subCategoryPickerArray addObject:@"Other"];
        }
        
    }
    
    for (UIView *view in self.view.subviews)
    {
        if ([view isKindOfClass:[CYCustomMultiSelectPickerView class]])
        {
            [view removeFromSuperview];
        }
    }
    
    multiPickerView = [[CYCustomMultiSelectPickerView alloc] initWithFrame:CGRectMake(0,[UIScreen mainScreen].bounds.size.height - 260-33, self.view.bounds.size.width, 260+22)];
    
    multiPickerView.entriesArray = subCategoryPickerArray;
    multiPickerView.entriesSelectedArray = selectedSubcategoryArray;
    multiPickerView.multiPickerDelegate = self;
    
    [self.view addSubview:multiPickerView];
    [multiPickerView pickerShow];
    
    
}


- (IBAction)selectCategoryDropdownAction:(id)sender
{
    [_keyboardControls.activeField resignFirstResponder];
    [otherSubCategory resignFirstResponder];
    isCityPicker = false;
    [multiPickerView removeFromSuperview];
    _scrollView.scrollEnabled = NO;
    
    
    [categoryPickerArray removeAllObjects];
    NSArray * tempAry  = [dataDict objectForKey:@"CategoryList"];
    
    for (int i = 0; i<tempAry.count; i++)
    {
        NSDictionary * tempDict =[tempAry objectAtIndex:i];
        [ categoryPickerArray addObject:[tempDict objectForKey:@"Name"]];
    }
    
    [_categoryPicker reloadAllComponents];
    [_scrollView setContentOffset:CGPointMake(0, selectCategoryField.frame.origin.y-150) animated:YES];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _categoryPicker.frame = CGRectMake(_categoryPicker.frame.origin.x, self.view.bounds.size.height-_categoryPicker.frame.size.height , self.view.bounds.size.width, _categoryPicker.frame.size.height);
    _pickerToolbar.frame = CGRectMake(_pickerToolbar.frame.origin.x, _categoryPicker.frame.origin.y-44, self.view.bounds.size.width, _pickerToolbar.frame.size.height);
    [UIView commitAnimations];
}

- (IBAction)toolBarDoneClicked:(id)sender
{
    if (isCityPicker)
    {
        NSInteger index = [_categoryPicker selectedRowInComponent:0];
        NSArray * tmpAry =[cityDict objectForKey:@"CityList"];
        NSDictionary * tmpDict = [tmpAry objectAtIndex:index];
        cityField.text=[cityArray objectAtIndex:index];
        cityId=[[tmpDict objectForKey:@"Id"]intValue];
    }
    else
    {
        NSInteger index = [_categoryPicker selectedRowInComponent:0];
        selectCategoryField.text=[categoryPickerArray objectAtIndex:index];
        NSArray * tmpary = [dataDict objectForKey:@"CategoryList"];
        subCategoryDict =[tmpary objectAtIndex:index];
        
        if ([categoryId intValue]!=[[subCategoryDict objectForKey:@"Id"]intValue])
        {
            subCatStr = @"";
           selectSubCategoryField.text = @"";
            otherSubCategory.text = @"";
        [self reframeOthersField];
            NSArray * tempAry =[subCategoryDict objectForKey:@"SubCategory"];
            for (int i=0; i<tempAry.count; i++)
            {
                NSDictionary * subCategory =[tempAry objectAtIndex:i];
                
                [appdelegate.multiplePickerDic setObject:[NSNumber numberWithBool:NO] forKey:[subCategory objectForKey:@"Name"]];
                if (i==tempAry.count-1)
                {
                    [appdelegate.multiplePickerDic setObject:[NSNumber numberWithBool:NO] forKey:@"Other"];
                }
                
            }
        }
        categoryId=[subCategoryDict objectForKey:@"Id"];
    }
    [self hidePickerWithAnimation];
    
}

-(void)hidePickerWithAnimation
{
    //[_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    _scrollView.scrollEnabled = YES;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _categoryPicker.frame = CGRectMake(_categoryPicker.frame.origin.x, 1000, self.view.bounds.size.width, _categoryPicker.frame.size.height);
    _pickerToolbar.frame = CGRectMake(_pickerToolbar.frame.origin.x, 1000, self.view.bounds.size.width, _pickerToolbar.frame.size.height);
    [UIView commitAnimations];
}
#pragma mark - end

#pragma mark - ALPicker Delegate
-(void)returnChoosedPickerString:(NSMutableArray *)selectedEntriesArr
{
    _scrollView.scrollEnabled = YES;
    //[_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    NSString *dataStr = [selectedEntriesArr componentsJoinedByString:@","];
    
    
    NSMutableArray * subCategoryIdArray = [[NSMutableArray alloc]init];
    NSArray * TempSecArray =[subCategoryDict objectForKey:@"SubCategory"];
    
    for (int i = 0; i<selectedEntriesArr.count; i++)
    {
        
        for (int j = 0; j<TempSecArray.count; j++)
        {
            NSDictionary * tempDict = [TempSecArray objectAtIndex:j];
            if([[selectedEntriesArr objectAtIndex:i] isEqualToString:[tempDict objectForKey:@"Name"]])
            {
                NSMutableDictionary *dict = [NSMutableDictionary new];
                [dict setObject:[tempDict objectForKey:@"Id"] forKey:@"Id"];
                
                
                [subCategoryIdArray addObject:dict];
                break;
                
            }
        }
    }
    subCategoryId = [subCategoryIdArray componentsJoinedByString:@","];
    selectedSubcategoryArray = subCategoryIdArray;
    selectSubCategoryField.text = dataStr;
    if ([selectSubCategoryField.text isEqualToString:@"Other"] || [selectedEntriesArr containsObject:@"Other"])
    {
        otherSubCategory.hidden=NO;
        businessHourLabel.translatesAutoresizingMaskIntoConstraints = YES;
        setHourCollectionView.translatesAutoresizingMaskIntoConstraints=YES;
        otherSubCategory.translatesAutoresizingMaskIntoConstraints=YES;
        selectSubCategoryField.translatesAutoresizingMaskIntoConstraints=YES;
        otherSubCategory.frame=CGRectMake(self.view.frame.origin.x+13, selectSubCategoryField.frame.origin.y+68, selectSubCategoryField.frame.size.width, selectSubCategoryField.frame.size.height);
        businessHourLabel.frame=CGRectMake(self.view.frame.origin.x+13, otherSubCategory.frame.origin.y+60, businessHourLabel.frame.size.width, businessHourLabel.frame.size.height);
        setHourCollectionView.frame=CGRectMake(self.view.frame.origin.x, businessHourLabel.frame.origin.y+25, self.view.frame.size.width, setHourCollectionView.frame.size.height);
    }
    
    else
    {
        otherSubCategory.hidden=YES;
        
        businessHourLabel.translatesAutoresizingMaskIntoConstraints = YES;
        setHourCollectionView.translatesAutoresizingMaskIntoConstraints=YES;
        otherSubCategory.translatesAutoresizingMaskIntoConstraints=YES;
        selectSubCategoryField.translatesAutoresizingMaskIntoConstraints=YES;
        
        businessHourLabel.frame=CGRectMake(self.view.frame.origin.x+13, selectSubCategoryField.frame.origin.y+selectSubCategoryField.frame.size.height+10, businessHourLabel.frame.size.width, businessHourLabel.frame.size.height);
        
        setHourCollectionView.frame=CGRectMake(self.view.frame.origin.x, businessHourLabel.frame.origin.y+21, self.view.frame.size.width, setHourCollectionView.frame.size.height);
    }
    
    
}

-(void)reframeOthersField
{
    if ([selectSubCategoryField.text isEqualToString:@"Other"])
    {
        otherSubCategory.hidden=NO;
        
        businessHourLabel.translatesAutoresizingMaskIntoConstraints = YES;
        setHourCollectionView.translatesAutoresizingMaskIntoConstraints=YES;
        otherSubCategory.translatesAutoresizingMaskIntoConstraints=YES;
        selectSubCategoryField.translatesAutoresizingMaskIntoConstraints=YES;
        
        
        otherSubCategory.frame=CGRectMake(self.view.frame.origin.x+13, selectSubCategoryField.frame.origin.y+68, selectSubCategoryField.frame.size.width, selectSubCategoryField.frame.size.height);
        
        businessHourLabel.frame=CGRectMake(self.view.frame.origin.x+13, otherSubCategory.frame.origin.y+60, businessHourLabel.frame.size.width, businessHourLabel.frame.size.height);
        
        setHourCollectionView.frame=CGRectMake(self.view.frame.origin.x, businessHourLabel.frame.origin.y+25, self.view.frame.size.width, setHourCollectionView.frame.size.height);
    }
    
    else
    {
        otherSubCategory.hidden=YES;
        
        businessHourLabel.translatesAutoresizingMaskIntoConstraints = YES;
        setHourCollectionView.translatesAutoresizingMaskIntoConstraints=YES;
        otherSubCategory.translatesAutoresizingMaskIntoConstraints=YES;
        selectSubCategoryField.translatesAutoresizingMaskIntoConstraints=YES;
        
        businessHourLabel.frame=CGRectMake(self.view.frame.origin.x+13, selectSubCategoryField.frame.origin.y+selectSubCategoryField.frame.size.height+10, businessHourLabel.frame.size.width, businessHourLabel.frame.size.height);
        
        setHourCollectionView.frame=CGRectMake(self.view.frame.origin.x, businessHourLabel.frame.origin.y+21, self.view.frame.size.width, setHourCollectionView.frame.size.height);
    }

}
#pragma mark - end

#pragma mark - Picker View methods
-(void)hidePicker
{
    _scrollView.scrollEnabled = YES;
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)info
{
    uploadProfilePicLabel.hidden = YES;
    //UIImage * img = [info objectForKey:UIImagePickerControllerOriginalImage];
    profileImage.image = image;
    [ImgPicker dismissViewControllerAnimated:YES completion:NULL];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
    
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (isCityPicker)
    {
        return cityArray.count;
    }
    else
    {
        return [categoryPickerArray count];
    }
}



-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (isCityPicker)
    {
        return [cityArray objectAtIndex:row];
    }
    else
    {
        return [categoryPickerArray objectAtIndex:row];
    }
    
}
#pragma mark - end

#pragma mark - AWS image upload methods
-(void)callUploadImageMethod
{
    [self removeKeyboardFromScreen];
    
    UIImage* downloadImage = [UIImage imageNamed:@"download.png"];
    NSData *downloadImageData = UIImagePNGRepresentation(downloadImage);
    UIImage* uploadImage = [UIImage imageNamed:@"upload_image.png"];
    NSData *uploadImageData = UIImagePNGRepresentation(uploadImage);
    
    NSData *profileImageData = UIImagePNGRepresentation(profileImage.image);
    
    if ([profileImageData isEqualToData:downloadImageData ] || [profileImageData isEqualToData: uploadImageData])
    {
        
        [self businessRegister];
        
    }
    else
    {
        UIImage *image = [profileImage.image fixOrientation];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"ddMMYYhhmmss"];
        NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
        imageName= [NSString stringWithFormat:@"Sure_Sp%@.jpeg",datestr];
        NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"] stringByAppendingPathComponent:imageName];
        NSData * imageData = UIImageJPEGRepresentation(image, 0.1);
        [imageData writeToFile:filePath atomically:YES];
        AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
        uploadRequest.ACL = AWSS3ObjectCannedACLPublicReadWrite;
        uploadRequest.body = [NSURL fileURLWithPath:filePath];
        uploadRequest.contentType = @"image";
        uploadRequest.key = imageName;
        uploadRequest.bucket = [NSString stringWithFormat:@"%@/businessprofileimages",S3BucketName];
        [self upload:uploadRequest index:0];
    }
}

- (void)upload:(AWSS3TransferManagerUploadRequest *)uploadRequest index : (NSUInteger)index
{
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager upload:uploadRequest] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                
            }
            else
            {
            }
        }
        if (task.result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self businessRegister];
                
            });
        }
        return nil;
    }];
}

#pragma mark - end

- (IBAction)closeHourView:(id)sender
{
    hourSelectionView.hidden=YES;
}



- (IBAction)saveHourSelection:(id)sender
{
    NSIndexPath * index = [NSIndexPath indexPathForItem:button_tag inSection:0];
    NSMutableDictionary *tempDict=[workingHoursArray objectAtIndex:button_tag];
    [tempDict setObject:[NSString stringWithFormat:@"%@",leftLabel.text] forKey:@"StartTime"];
    NSString *endTime=rightLabel.text;
    if ([endTime isEqualToString:@"24:00"])
    {
        endTime=@"23:59";
    }
    [tempDict setObject:[NSString stringWithFormat:@"%@",endTime] forKey:@"EndTime"];
    //[tempDict setObject:@"YES" forKey:@"iSSelectedBefore"];
    NSDictionary * Dict = [workingHoursArray objectAtIndex:button_tag];
    if ((([[Dict objectForKey:@"StartTime"] isEqualToString:@"00:00"] || [[Dict objectForKey:@"StartTime"] isEqualToString:@"00:00:00"]) && ([[Dict objectForKey:@"EndTime"] isEqualToString:@"00:00"] || [[Dict objectForKey:@"EndTime"] isEqualToString:@"00:00:00"])))
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please select valid working hours." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    
    UICollectionViewCell *tmpCell = [collectionView cellForItemAtIndexPath:index];
    MyButton * btn =(MyButton *)[tmpCell.contentView viewWithTag:2];
    [btn setSelected:YES];
    [self closeHourView:nil];
}

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
    if (textField == contactField) {
        [_scrollView setContentOffset:CGPointMake(0, postalView.frame.origin.y) animated:YES];
    }
    else if (textField == postalTextField)
    {
        [_scrollView setContentOffset:CGPointMake(0, postalView.frame.origin.y-12) animated:YES];
    }
    else if (textField == otherSubCategory)
    {
        
        [_scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y-25) animated:YES];
    }
    
    
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.keyboardControls setActiveField:textView];
    
    [_scrollView setContentOffset:CGPointMake(0, textView.frame.origin.y-12) animated:YES];
    
    
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
    //[_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
}




#pragma mark - AWSDownload delegate
-(void)ListObjectprocessCompleted:DownloadimageArray{
    awsImageArray=[DownloadimageArray mutableCopy];
    //    [myDelegate StopIndicator];
    uploadImageIndicator.hidden=YES;
    [uploadImageIndicator stopAnimating];
    id object = [awsImageArray objectAtIndex:0];
    if ([object isKindOfClass:[AWSS3TransferManagerDownloadRequest class]]) {
        
        AWSS3TransferManagerDownloadRequest *downloadRequest = object;
        
        downloadRequest.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (totalBytesExpectedToWrite > 0) {
                    progress.progress = (float)((double) totalBytesWritten / totalBytesExpectedToWrite);
                    
                    
                }
            });
        };
        
    } else if ([object isKindOfClass:[NSURL class]]) {
        
    }
}

-(void)DownloadprocessCompleted:(AWSS3TransferManagerDownloadRequest *)downloadRequest index:(NSUInteger)index{
    
    [awsImageArray replaceObjectAtIndex:index withObject:downloadRequest.downloadingFileURL];
    uploadImageBtn.enabled = YES;
    profileImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:downloadRequest.downloadingFileURL]];
    progress.hidden=YES;
    uploadProfilePicLabel.hidden=YES;
    progress.progress = 1.0f;
}
#pragma mark - end delegate
#pragma mark - MJGeocoderDelegate
//Getting the location of store added
- (void)geocoder:(MJGeocoder *)geocoder didFindLocations:(NSArray *)locations{
    //hide network indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    
    
    NSArray * displayedResults = [locations mutableCopy] ;
    Address *address = [displayedResults objectAtIndex:0];
    
    latitude=[address.latitude doubleValue];
    longitude=[address.longitude doubleValue];
    
    [self callUploadImageMethod];
}
//Error message displayed when user enters invalid location
- (void)geocoder:(MJGeocoder *)geocoder didFailWithError:(NSError *)error
{
    //    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [myDelegate StopIndicator];
    //
    if([error code] == 1)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You have entered an invalid location." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
}
#pragma mark - end
@end
