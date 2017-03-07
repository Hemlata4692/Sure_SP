//
//  AddServiceViewController.m
//  Sure_sp
//
//  Created by Ranosys on 25/03/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "AddServiceViewController.h"
#import "QBImagePickerController.h"
#import "UITextField+Padding.h"
#import "UIPlaceHolderTextView.h"
#import "UIView+RoundedCorner.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "BSKeyboardControls.h"
#import "BFTask.h"
#import <AWSS3/AWSS3.h>
#import "Constants.h"
#import "UITextField+Validations.h"
#import "UITextView+Validations.h"
#import "MyButton.h"
#import "STKSpinnerView.h"
#import "AWSDownload.h"
#import "serviceDetailModel.h"
#import "UIImage+UIImage_fixOrientation.h"
#define kCellsPerRow 3

@interface AddServiceViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate,QBImagePickerControllerDelegate,UITextFieldDelegate,BSKeyboardControlsDelegate,UIActionSheetDelegate,AWSDownloadDelegate>
{
    NSMutableArray *imagesArray;
    int buttonTag;
    NSString *serviceType;
    NSMutableArray * imageName;
    NSMutableArray * checkImagesCount;
    bool previousHeight;
    AWSDownload *download;
    NSString * serviceName;
    __weak IBOutlet UIActivityIndicatorView *indicator;
    __weak IBOutlet UIButton *doneBtn;
    bool inShop;
    bool onSite;
}

@property (strong,nonatomic) NSMutableArray *hourArray;
@property (strong,nonatomic) NSMutableArray *dayArray;

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

@property (weak, nonatomic) IBOutlet UITextField *serviceNameField;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *serviceTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *onSiteBtn;
@property (weak, nonatomic) IBOutlet UIButton *inShopBtn;
@property (weak, nonatomic) IBOutlet UILabel *onSiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *inShopLabel;
@property (weak, nonatomic) IBOutlet UITextField *chargeField;
@property (weak, nonatomic) IBOutlet UILabel *slotLabel;
@property (weak, nonatomic) IBOutlet UILabel *advancedBookingDaysLabel;
@property (weak, nonatomic) IBOutlet UILabel *daysLabel;
@property (weak, nonatomic) IBOutlet UILabel *advancedBookingHoursLabel;
@property (weak, nonatomic) IBOutlet UITextField *advancedBookingField;
@property (weak, nonatomic) IBOutlet UITextField *serviceSlotField;
@property (weak, nonatomic) IBOutlet UIButton *serviceSlotBtn;
@property (weak, nonatomic) IBOutlet UIButton *advancedBookingBtn;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIButton *uploadPicture;
- (IBAction)uploadImageFromGallleryAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *advanceBookingDayField;
@property (weak, nonatomic) IBOutlet UIButton *advanceBookingDayBtn;
@property (weak, nonatomic) IBOutlet UIToolbar *pickertoolbar;
@property (weak, nonatomic) IBOutlet UIPickerView *hourPicker;
- (IBAction)toolBarDoneClicked:(id)sender;



@end

@implementation AddServiceViewController
@synthesize serviceId;
@synthesize canEdit;
#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
    
    download = [[AWSDownload alloc]init];
    download.delegate = self;
    imagesArray=[[NSMutableArray alloc]init];
    imageName = [[NSMutableArray alloc]init];
    checkImagesCount=[[NSMutableArray alloc]init];
   
    serviceType = @"0";
    // Do any additional setup after loading the view.
    _serviceNameField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    [self setframesOfObjects];
    
    //settinng collection view cell size according to iPhone screens
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    CGFloat availableWidthForCells = CGRectGetWidth(self.view.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (kCellsPerRow-1)-32;
    CGFloat cellWidth = (availableWidthForCells / kCellsPerRow)-8;
    flowLayout.itemSize = CGSizeMake(cellWidth, flowLayout.itemSize.height);
    
    //Adding textfield padding
    [self addTextFieldPadding];
    [self roundCorners];
    [_descriptionTextView setPlaceholder:@"Description of the service"];
    [_descriptionTextView setTextContainerInset:UIEdgeInsetsMake(9, 5, 0,0)];
    
    self.dayArray=[[NSMutableArray alloc] init];
    self.hourArray=[[NSMutableArray alloc] init];
    
    //Keyboard toolbar action to display toolbar with keyboard to move next,previous
    NSArray * fieldArray = @[_serviceNameField,_descriptionTextView,_chargeField];
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fieldArray]];
    [self.keyboardControls setDelegate:self];
   
    
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"download"]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
    }
    //    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
        
    }
    if(canEdit)
    {
        self.title = @"Edit Service";
        [myDelegate ShowIndicator];
    }
    else
    {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"]
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:&error]) {
        }
        self.title = @"Add Service";
    }
    
    [self performSelector:@selector(getServiceType) withObject:nil afterDelay:.1];
    
}

-(void)addObjectsToImageArray
{
    if (imagesArray.count>0)
    {
        
        for (int i = 0; i<imagesArray.count; i++)
            
        {
            UIImage *image = [imagesArray objectAtIndex:i];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *locale = [[NSLocale alloc]
                                initWithLocaleIdentifier:@"en_US"];
            [dateFormatter setLocale:locale];
            [dateFormatter setDateFormat:@"ddMMYYhhmmss"];
            NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString stringWithFormat:@"Sure_Sp%@-%d.jpeg",datestr,i];
            NSMutableDictionary * tempDict = [NSMutableDictionary new];
            [tempDict setObject:fileName forKey:@"Image"];
            [imageName addObject:tempDict];
            NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"] stringByAppendingPathComponent:fileName];
            NSData * imageData = UIImageJPEGRepresentation(image, 0.1);
            [imageData writeToFile:filePath atomically:YES];
            AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
            uploadRequest.body = [NSURL fileURLWithPath:filePath];
            uploadRequest.key = fileName;
            uploadRequest.bucket = [NSString stringWithFormat:@"%@/serviceimages",S3BucketName];
            [self upload:uploadRequest index:i];
            
        }
    }
    
    
}

-(void)roundCorners
{
    [_serviceNameField setCornerRadius:1.0f];
    [_serviceSlotField setCornerRadius:1.0f];
    [_chargeField setCornerRadius:1.0f];
    [_advancedBookingField setCornerRadius:1.0f];
    [_advanceBookingDayField setCornerRadius:1.0f];
    [_uploadPicture setCornerRadius:1.0f];
    [_descriptionTextView setCornerRadius:1.0f];
    
}

-(void)addTextFieldPadding
{
    [_serviceNameField addTextFieldPaddingWithoutImages:_serviceNameField];
    [_serviceSlotField addTextFieldPaddingWithoutImages:_serviceSlotField];
    [_chargeField addTextFieldPaddingWithoutImages:_chargeField];
    [_advanceBookingDayField addTextFieldPaddingWithoutImages:_advanceBookingDayField];
    [_advancedBookingField addTextFieldPaddingWithoutImages:_advancedBookingField];
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - end

#pragma mark - Reframing Objects

-(void) removeAutolayouts
{
    _collectionView.translatesAutoresizingMaskIntoConstraints=YES;
    _scrollview.translatesAutoresizingMaskIntoConstraints=YES;
    _mainView.translatesAutoresizingMaskIntoConstraints=YES;
    _uploadPicture.translatesAutoresizingMaskIntoConstraints = YES;
    _serviceNameField.translatesAutoresizingMaskIntoConstraints = YES;
    _descriptionTextView.translatesAutoresizingMaskIntoConstraints =YES;
    _serviceTypeLabel.translatesAutoresizingMaskIntoConstraints =YES;
    _onSiteBtn.translatesAutoresizingMaskIntoConstraints =YES;
    _inShopBtn.translatesAutoresizingMaskIntoConstraints =YES;
    _onSiteLabel.translatesAutoresizingMaskIntoConstraints =YES;
    _inShopLabel.translatesAutoresizingMaskIntoConstraints =YES;
    _chargeField.translatesAutoresizingMaskIntoConstraints =YES;
    _slotLabel.translatesAutoresizingMaskIntoConstraints=YES;
    _advancedBookingDaysLabel.translatesAutoresizingMaskIntoConstraints=YES;
    _daysLabel.translatesAutoresizingMaskIntoConstraints=YES;
    _advancedBookingHoursLabel.translatesAutoresizingMaskIntoConstraints=YES;
    _advancedBookingField.translatesAutoresizingMaskIntoConstraints=YES;
    _serviceSlotField.translatesAutoresizingMaskIntoConstraints=YES;
    _serviceSlotBtn.translatesAutoresizingMaskIntoConstraints=YES;
    _advancedBookingBtn.translatesAutoresizingMaskIntoConstraints=YES;
    _advanceBookingDayBtn.translatesAutoresizingMaskIntoConstraints=YES;
    _advanceBookingDayField.translatesAutoresizingMaskIntoConstraints=YES;
    _hourPicker.translatesAutoresizingMaskIntoConstraints = YES;
    _pickertoolbar.translatesAutoresizingMaskIntoConstraints = YES;
    indicator.translatesAutoresizingMaskIntoConstraints = YES;
}


-(void)resizeScrollview
{
    if (imagesArray.count<1 && imageName.count<1) {
        _scrollview.contentInset = UIEdgeInsetsMake(0, 0, self.mainView.frame.size.height, 0);
        _collectionView.frame=CGRectMake(16, _collectionView.frame.origin.y, self.view.frame.size.width-32, 0);
    }
    else if((imagesArray.count<=3 && imagesArray.count>=1) || (myDelegate.count<=3 && myDelegate.count>=1))
    {
        previousHeight = NO;
        _scrollview.contentInset = UIEdgeInsetsMake(0, 0, self.mainView.frame.size.height+50, 0);
        _collectionView.frame=CGRectMake(16, _collectionView.frame.origin.y, self.view.frame.size.width-32, 100);
        
    }
    else if ((imagesArray.count>3 || myDelegate.count>3) )
    {
        previousHeight = YES;
        _scrollview.contentInset = UIEdgeInsetsMake(0, 0, self.mainView.frame.size.height+100, 0);
        _collectionView.frame=CGRectMake(16, _collectionView.frame.origin.y, self.view.frame.size.width-32, 200);
    }
    

    [self resizeFramesBelowScrollview];
}

-(void)resizeFramesBelowScrollview
{
    _serviceTypeLabel.frame=CGRectMake(16, _collectionView.frame.origin.y+_collectionView.frame.size.height+11, self.view.frame.size.width-32, _serviceTypeLabel.frame.size.height);
    _onSiteBtn.frame=CGRectMake(self.view.frame.origin.x+16, _serviceTypeLabel.frame.origin.y+_serviceTypeLabel.frame.size.height+13, _onSiteBtn.frame.size.width, _onSiteBtn.frame.size.height);
    _onSiteLabel.frame=CGRectMake(_onSiteBtn.frame.origin.x+_onSiteBtn.frame.size.width+8, _serviceTypeLabel.frame.origin.y+_serviceTypeLabel.frame.size.height+16, _onSiteLabel.frame.size.width, _onSiteLabel.frame.size.height);
    _inShopBtn.frame=CGRectMake(_onSiteLabel.frame.origin.x+_onSiteLabel.frame.size.width+57, _serviceTypeLabel.frame.origin.y+_serviceTypeLabel.frame.size.height+13, _inShopBtn.frame.size.width, _inShopBtn.frame.size.height);
    _inShopLabel.frame=CGRectMake(_inShopBtn.frame.origin.x+_inShopBtn.frame.size.width+8, _serviceTypeLabel.frame.origin.y+_serviceTypeLabel.frame.size.height+16, _inShopLabel.frame.size.width, _inShopLabel.frame.size.height);
    _slotLabel.frame=CGRectMake(16, _inShopLabel.frame.origin.y+_inShopLabel.frame.size.height+14, self.view.frame.size.width-32, _slotLabel.frame.size.height);
    _serviceSlotField.frame=CGRectMake(16, _slotLabel.frame.origin.y+_slotLabel.frame.size.height+5, self.view.frame.size.width-32, _serviceSlotField.frame.size.height);
    _chargeField.frame=CGRectMake(16, _serviceSlotField.frame.origin.y+_serviceSlotField.frame.size.height+18, self.view.frame.size.width-32, _chargeField.frame.size.height);
    _serviceSlotBtn.frame=CGRectMake(16, _slotLabel.frame.origin.y+_slotLabel.frame.size.height+5, self.view.frame.size.width-32, _serviceSlotBtn.frame.size.height);
    _serviceSlotBtn.imageEdgeInsets = UIEdgeInsetsMake(0, _serviceSlotBtn.frame.size.width-34, 0, 0);
    _advancedBookingDaysLabel.frame=CGRectMake(16, _chargeField.frame.origin.y+_chargeField.frame.size.height+12, self.view.frame.size.width-32, _advancedBookingDaysLabel.frame.size.height);
    _advanceBookingDayField.frame=CGRectMake(16, _advancedBookingDaysLabel.frame.origin.y+_advancedBookingDaysLabel.frame.size.height+8, _advanceBookingDayField.frame.size.width, _advanceBookingDayField.frame.size.height);
    _advanceBookingDayBtn.frame=CGRectMake(16, _advancedBookingDaysLabel.frame.origin.y+_advancedBookingDaysLabel.frame.size.height+8, _advanceBookingDayBtn.frame.size.width, _advanceBookingDayField.frame.size.height);
    _advanceBookingDayBtn.imageEdgeInsets = UIEdgeInsetsMake(0, _advanceBookingDayBtn.frame.size.width-34, 0, 0);
    _daysLabel.frame=CGRectMake(_advanceBookingDayBtn.frame.origin.x+_advanceBookingDayBtn.frame.size.width+18, _advancedBookingDaysLabel.frame.origin.y+_advancedBookingDaysLabel.frame.size.height+8, _daysLabel.frame.size.width, _daysLabel.frame.size.height);
    _advancedBookingHoursLabel.frame=CGRectMake(16,  _daysLabel.frame.origin.y+ _daysLabel.frame.size.height+15, self.view.frame.size.width-32, _advancedBookingHoursLabel.frame.size.height);
    _advancedBookingField.frame=CGRectMake(16, _advancedBookingHoursLabel.frame.origin.y+_advancedBookingHoursLabel.frame.size.height+11, self.view.frame.size.width-32, _advancedBookingField.frame.size.height);
    _advancedBookingBtn.frame=CGRectMake(16, _advancedBookingHoursLabel.frame.origin.y+_advancedBookingHoursLabel.frame.size.height+11, self.view.frame.size.width-32, _advancedBookingBtn.frame.size.height);
    _advancedBookingBtn.imageEdgeInsets = UIEdgeInsetsMake(7, _advancedBookingBtn.frame.size.width-34, 0, 0);
    
}

-(void)setframesOfObjects
{
    
    [self removeAutolayouts];
    _scrollview.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _mainView.frame=CGRectMake(0, 0, self.scrollview.frame.size.width, _mainView.frame.size.height+100);
    _serviceNameField.frame=CGRectMake(16, _serviceNameField.frame.origin.y, self.view.frame.size.width-32, _serviceNameField.frame.size.height);
    indicator.frame = CGRectMake(self.view.frame.size.width-50, indicator.frame.origin.y, indicator.frame.size.width, indicator.frame.size.height);
    
    _descriptionTextView.frame=CGRectMake(16, _descriptionTextView.frame.origin.y, self.view.frame.size.width-139, _descriptionTextView.frame.size.height);
    _uploadPicture.frame=CGRectMake(_descriptionTextView.frame.origin.x+_descriptionTextView.frame.size.width+13, _uploadPicture.frame.origin.y, _uploadPicture.frame.size.width, _uploadPicture.frame.size.height);
    
    
    [self resizeScrollview];
    [self resizeFramesBelowScrollview];
    
    
}

#pragma mark - end

#pragma mark - Upload Image
- (IBAction)uploadImageFromGallleryAction:(id)sender
{
    if(imagesArray.count>=6 || myDelegate.count>=6)
    {
        
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"You can select maximum 6 images." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        return;
        
    }
    
    UIActionSheet * share=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Choose Existing Photo", nil];
    //    popup.tag = 1;
    [share showInView:self.view];
    
    
    
    
}

#pragma mark - end

#pragma mark - Webservice
-(void)getServiceType
{
    [[WebService sharedManager] getServiceType:^(id responseObject)
    {
        // 1. can not login as email or password are incorrect
        [myDelegate StopIndicator];
        onSite = [[responseObject objectForKey:@"OnSite"]boolValue];
        inShop = [[responseObject objectForKey:@"InShop"]boolValue];
        if (!inShop)
        {
            _inShopBtn.enabled = NO;
            [_onSiteBtn setSelected:YES];
            serviceType=[NSString stringWithFormat:@"%d",1];
        }
       else if (!onSite)
        {
            _onSiteBtn.enabled = NO;
            [_inShopBtn setSelected:YES];
            serviceType=[NSString stringWithFormat:@"%d",2];
        }
        else if ((inShop && onSite) && !canEdit)
        {
           [_onSiteBtn setSelected:YES];
            serviceType=[NSString stringWithFormat:@"%d",1];
        }
        if (canEdit)
        {
            [self performSelector:@selector(getServiceDetailsFromServer) withObject:nil afterDelay:.1];
        }
        
    } failure:^(NSError *error)
    {
        [myDelegate StopIndicator];
    }];


}
-(void)deleteImageFromServer : (NSString *)imagName
{
    
    
    
    [[WebService sharedManager] deleteImage:imagName serviceId:serviceId success:^(id responseObject) {
        // 1. can not login as email or password are incorrect
        [myDelegate StopIndicator];
        
        
    } failure:^(NSError *error) {
        [myDelegate StopIndicator];
    }] ;
    
    
    
    
}

-(void)chechDuplicateService
{

    [[WebService sharedManager] checkDuplicateService:_serviceNameField.text success:^(id responseObject)
    {
        // 1. can not login as email or password are incorrect
        
        doneBtn.enabled = YES;
        [indicator stopAnimating];
        if ([[responseObject objectForKey:@"IsDuplicate"]intValue]==1) {
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[responseObject objectForKey:@"Message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            alert.tag = 10;
            [alert show];
        }
        
        
        
    } failure:^(NSError *error) {
        
    }];

}

-(void)getServiceDetailsFromServer
{
    [[WebService sharedManager] getServiceDetail:[NSString stringWithFormat:@"%@",serviceId] success:^(id responseObject)
     {
         // 1. can not login as email or password are incorrect
         
         serviceDetailModel * dataModel = (serviceDetailModel *)responseObject;
         
         _serviceNameField.text = dataModel.serviceName;
         serviceName =dataModel.serviceName;
         NSMutableArray * tmpAry = dataModel.imageNameArray;
         imageName = [tmpAry mutableCopy];
         _descriptionTextView.text = dataModel.serviceDescription;
         _chargeField.text = [NSString stringWithFormat:@"%@",dataModel.serviceCharges];
         _serviceSlotField.text = [NSString stringWithFormat:@"%@",dataModel.slotDurationHours];
         _advancedBookingField.text =[NSString stringWithFormat:@"%@",dataModel.bookBeforeHours];
         _advanceBookingDayField.text =[NSString stringWithFormat:@"%@",dataModel.advanceBookingDays];
         serviceType=[NSString stringWithFormat:@"%@",dataModel.serviceType];
         if ([serviceType isEqual:@"1"])
         {
             _onSiteBtn.selected=YES;
             _inShopBtn.selected=NO;
         }
         else if ([serviceType isEqual:@"2"])
         {
             _inShopBtn.selected=YES;
             _onSiteBtn.selected=NO;
         }
         tmpAry=[NSMutableArray new];
         for (int i=0; i<imageName.count; i++)
         {
             NSMutableDictionary *tempdic=[imageName objectAtIndex:i];
             [tmpAry addObject:[tempdic objectForKey:@"Image"]];
             
         }
         myDelegate.count = (int)tmpAry.count;
         [self resizeScrollview];
         checkImagesCount=[imageName mutableCopy];
         if(myDelegate.count>0)
         {
           
//            [myDelegate ShowIndicator];
             [_collectionView reloadData];
           [download listObjects:self ImageName:tmpAry folderName:@"serviceimages"];
         }
     } failure:^(NSError *error) {
         
     }];
    
    
}


-(BOOL)performValidation
{
    UIAlertView *alert;
    
    
    if ([_serviceNameField isEmpty] || [_descriptionTextView isEmpty] ||[_chargeField isEmpty] || [_serviceSlotField isEmpty] || [_advancedBookingField isEmpty] || [_advanceBookingDayField isEmpty])
    {
        
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please fill in all fields." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
        
    }
    else if([serviceType isEqualToString:@"0"])
    {
        
        alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please select either in shop or on site service." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
        
    }
    else
    {
        return YES;
    }
    
    
}

- (IBAction)doneAction:(id)sender
{
    
    if ([self performValidation])
    {
        
        [myDelegate ShowIndicator];
        if (imagesArray.count>0)
        {
            bool canSend = true;
            [imageName removeAllObjects];
            for (int i = 0; i<imagesArray.count; i++)
                
            {
                if ([[imagesArray objectAtIndex:i] isKindOfClass:[UIImage class]])
                {
                    canSend = false;
                    UIImage *image = [[imagesArray objectAtIndex:i] fixOrientation];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    NSLocale *locale = [[NSLocale alloc]
                                        initWithLocaleIdentifier:@"en_US"];
                    [dateFormatter setLocale:locale];
                    [dateFormatter setDateFormat:@"ddMMYYhhmmss"];
                    NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
                    NSString *fileName = [NSString stringWithFormat:@"Sure_Sp%@-%d.jpeg",datestr,i];
                    NSMutableDictionary * tempDict = [NSMutableDictionary new];
                    [tempDict setObject:fileName forKey:@"Image"];
                    [imageName addObject:tempDict];
                    NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"] stringByAppendingPathComponent:fileName];
                    NSData * imageData = UIImageJPEGRepresentation(image, 0.1);
                    [imageData writeToFile:filePath atomically:YES];
                    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
                    uploadRequest.ACL = AWSS3ObjectCannedACLPublicReadWrite;
                    uploadRequest.body = [NSURL fileURLWithPath:filePath];
                    uploadRequest.contentType = @"image";
                    uploadRequest.key = fileName;
                    uploadRequest.bucket = [NSString stringWithFormat:@"%@/serviceimages",S3BucketName];
                    [self upload:uploadRequest index:i];
                    
                }
            }
            if (canSend)
            {
                if(canEdit)
                {
                    if (imagesArray.count<1)
                    {
                        [imageName removeAllObjects];
                    }
                    
                    [self performSelector:@selector(callEditServiceWebservice) withObject:nil afterDelay:.1];
                }
                else
                {
                    [self performSelector:@selector(callAddServiceWebservice) withObject:nil afterDelay:.1];
                }
            }
        }
        else
        {
            if(canEdit)
            {
                if (imagesArray.count<1)
                {
                    [imageName removeAllObjects];
                }
                [self performSelector:@selector(callEditServiceWebservice) withObject:nil afterDelay:.1];
            }
            else
            {
                [self performSelector:@selector(callAddServiceWebservice) withObject:nil afterDelay:.1];
            }
        }
    }
    
}

-(void)callEditServiceWebservice
{
    
    [_keyboardControls.activeField resignFirstResponder];
    [[WebService sharedManager]editService:imageName serviceDesc:_descriptionTextView.text slotDurationHrs:_serviceSlotField.text daysAdvanceBooking:_advanceBookingDayField.text serviceCharges:_chargeField.text serviceType:serviceType bookBeforeHrs:_advancedBookingField.text name:_serviceNameField.text serviceId:serviceId success:^(id responseObject)
     {
         UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:[responseObject objectForKey:@"Message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
         alert.tag = 1;
         [alert show];
     }
                                   failure:^(NSError *error) {
                                       
                                   }] ;
    
    
}

-(void) callAddServiceWebservice
{
    [_keyboardControls.activeField resignFirstResponder];
    [[WebService sharedManager]addService:imageName serviceDesc:_descriptionTextView.text slotDurationHrs:_serviceSlotField.text daysAdvanceBooking:_advanceBookingDayField.text serviceCharges:_chargeField.text serviceType:serviceType bookBeforeHrs:_advancedBookingField.text name:_serviceNameField.text success:^(id responseObject)
     {
         UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:[responseObject objectForKey:@"Message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
         alert.tag = 1;
         [alert show];
     }
                                  failure:^(NSError *error) {
                                      
                                  }] ;
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag==1) {
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else if (alertView.tag == 10)
    {
    
        [_serviceNameField becomeFirstResponder];
    
    }
    
    
}


#pragma mark - end

#pragma mark - Textfield and BSkeyboard control Delegates

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if(textField==_chargeField)
    {
        if (range.length > 0 && [string length] == 0)
        {
            // enable delete
            return YES;
        }
        if (textField.text.length >= 15 && range.length == 0)
        {
            
            return NO; // return NO to not change text
        }
        else
        {
            return YES;
        }
        
        
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
          _serviceNameField.text= [_serviceNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (textField == _serviceNameField && (![_serviceNameField.text isEqualToString:serviceName]) && _serviceNameField.text.length>0)
    {
        
        
        doneBtn.enabled = NO;
        [indicator startAnimating];
        [self chechDuplicateService];
    }
    
    return YES;

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_scrollview setContentOffset:CGPointMake(0,0) animated:YES];
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self hidePickerWithAnimation];
    [self.keyboardControls setActiveField:textField];
    
    if (textField==_chargeField)
    {
        [_scrollview setContentOffset:CGPointMake(0, _chargeField.frame.origin.y-15) animated:YES];
    }
    
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.keyboardControls setActiveField:textView];
    if (textView==_descriptionTextView)
    {
        [_scrollview setContentOffset:CGPointMake(0, _descriptionTextView.frame.origin.y-15) animated:YES];
    }
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    [_scrollview setContentOffset:CGPointMake(0, 0) animated:YES];
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
    //[_scrollview setContentOffset:CGPointMake(0, 0) animated:YES];
    
}
#pragma mark - end

#pragma mark - Collection View

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    if (canEdit)
    {
        return [checkImagesCount count];
    }
    else
    {
        return [imagesArray count];
    }
    
    
    
    
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView1 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *myCell = [collectionView1
                                    dequeueReusableCellWithReuseIdentifier:@"myCell"
                                    forIndexPath:indexPath];
    
    
    MyButton *dltButton=(MyButton *)[myCell viewWithTag:2];
    dltButton.Tag = (int)indexPath.item;
    dltButton.translatesAutoresizingMaskIntoConstraints=YES;
    dltButton.frame=CGRectMake(myCell.frame.size.width-dltButton.frame.size.width, 2, dltButton.frame.size.width,  dltButton.frame.size.height);
    [dltButton addTarget:self action:@selector(deleteImageAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIActivityIndicatorView *imageIndicator=(UIActivityIndicatorView *)[myCell viewWithTag:20];
    imageIndicator.translatesAutoresizingMaskIntoConstraints=YES;
    imageIndicator.frame=CGRectMake(myCell.frame.size.width/2-imageIndicator.frame.size.width/2, myCell.frame.size.height/2-imageIndicator.frame.size.height/2, imageIndicator.frame.size.width, imageIndicator.frame.size.height);
    [imageIndicator stopAnimating];
    imageIndicator.hidden=YES;
    
    
    if (canEdit)
    {
         dltButton.hidden=YES;
        imageIndicator.hidden=NO;
        [imageIndicator startAnimating];
    }
    
    UIProgressView *progress=(UIProgressView *)[myCell viewWithTag:30];
    progress.hidden=YES;
    progress.translatesAutoresizingMaskIntoConstraints=YES;
    progress.frame=CGRectMake(0, myCell.frame.size.height-2, myCell.frame.size.width, progress.frame.size.height);
  
    
    UIImageView *uploadImage=(UIImageView *)[myCell viewWithTag:1];
    uploadImage.translatesAutoresizingMaskIntoConstraints=YES;
    uploadImage.frame=CGRectMake(0, 0, myCell.frame.size.width,  myCell.frame.size.height);
    uploadImage.image=[UIImage imageNamed:@"picture.png"];
    uploadImage.contentMode = UIViewContentModeScaleAspectFill;
    uploadImage.clipsToBounds=YES;
    
    if(imagesArray.count>0)
    {
        
        if (canEdit)
        {
            [imageIndicator stopAnimating];
            imageIndicator.hidden=YES;
            id object = [imagesArray objectAtIndex:indexPath.row];
            if ([object isKindOfClass:[AWSS3TransferManagerDownloadRequest class]])
            {
                progress.hidden=NO;
                
               
                AWSS3TransferManagerDownloadRequest *downloadRequest = object;
                //            [self download:downloadRequest index:indexPath.row];
                downloadRequest.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (totalBytesExpectedToWrite > 0) {
                            progress.progress = (float)((double) totalBytesWritten / totalBytesExpectedToWrite);
                            
                        }
                    });
                };
                
            }
            else if ([object isKindOfClass:[NSURL class]])
            {
                progress.hidden=YES;
                dltButton.hidden=NO;
                //            myCell.label.hidden = YES;
                NSURL *downloadFileURL = object;
                //            myCell.progressView.progress = 1.0f;
                uploadImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:downloadFileURL]];
            }
            else
            {
                progress.hidden=YES;
                dltButton.hidden=NO;
                uploadImage.image=[imagesArray objectAtIndex:indexPath.row];
                
            }
            
        }
        else
        {
            progress.hidden=YES;
            uploadImage.image=[imagesArray objectAtIndex:indexPath.row];
        }
        
    }
    
    return myCell;
    
    
}
#pragma mark - end

#pragma mark - QBImagePickerControllerDelegate
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex==0) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:NULL];
    }
    else if (buttonIndex==1) {
        QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsMultipleSelection=YES;
        imagePickerController.minimumNumberOfSelection = 1;
        imagePickerController.maximumNumberOfSelection = 6;
        [self.navigationController pushViewController:imagePickerController animated:YES];
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    //    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    [imagesArray addObject:info[UIImagePickerControllerEditedImage]];
    [checkImagesCount addObject:info[UIImagePickerControllerEditedImage]];
    
    //myDelegate.count = 0;
    myDelegate.count = (int)imagesArray.count;
    [self dismissImagePickerController];
    [self resizeScrollview];
    [_collectionView reloadData];
    //    self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


- (void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset
{
    [self dismissImagePickerController];
}

- (void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
{
    
    for (int i = 0; i < [assets count]; i++)
    {
        
        ALAsset *asset1;
        asset1=[assets objectAtIndex:i];
        [imagesArray addObject:[UIImage imageWithCGImage:[[asset1 defaultRepresentation]fullResolutionImage]]];
        [checkImagesCount addObject:[UIImage imageWithCGImage:[[asset1 defaultRepresentation]fullResolutionImage]]];
        
    }
    //myDelegate.count = 0;
    myDelegate.count = (int)imagesArray.count;
    [self dismissImagePickerController];
    [self resizeScrollview];
    [_collectionView reloadData];
    
    
}


- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    
    [self dismissImagePickerController];
}


- (void)dismissImagePickerController
{
    if (self.presentedViewController) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [self.navigationController popToViewController:self animated:YES];
    }
}

#pragma mark - end

#pragma mark - IBAction
- (IBAction)serviceTypeSelectAction:(id)sender
{
    if([sender tag]==10)
    {
        
        _onSiteBtn.selected = YES;
        _inShopBtn.selected = NO;
        serviceType=[NSString stringWithFormat:@"%d",1];
        
        
    }
    else
    {
        
        _onSiteBtn.selected = NO;
        _inShopBtn.selected = YES;
        serviceType=[NSString stringWithFormat:@"%d",2];
        
    }
    
}
- (IBAction)selectHoursDropdownAction:(id)sender
{
    [[self.keyboardControls activeField] resignFirstResponder];
    buttonTag = (int)[sender tag];
    _scrollview.scrollEnabled = NO;
    
    [self.hourArray removeAllObjects];
    [self.dayArray removeAllObjects];
    float j=0.0;
    
    for ( int i=0; i<48; i++)
    {
        
        j=j+0.5;
        [self.hourArray addObject:[NSString stringWithFormat:@"%.1f",j ]];
    }
    
    [_hourPicker reloadAllComponents];
    [_hourPicker selectRow:0 inComponent:0 animated:YES];
    [_scrollview setContentOffset:CGPointMake(0, _serviceSlotField.frame.origin.y-150) animated:YES];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _hourPicker.frame = CGRectMake(_hourPicker.frame.origin.x, self.view.bounds.size.height-_hourPicker.frame.size.height , self.view.bounds.size.width, _hourPicker.frame.size.height);
    _pickertoolbar.frame = CGRectMake(_pickertoolbar.frame.origin.x, _hourPicker.frame.origin.y-44, self.view.bounds.size.width, _pickertoolbar.frame.size.height);
    [UIView commitAnimations];
    
}

- (IBAction)selectAdvanceBookingDays:(id)sender
{
    [[self.keyboardControls activeField] resignFirstResponder];
    //[_chargeField resignFirstResponder];
    buttonTag = (int)[sender tag];
    _scrollview.scrollEnabled = NO;
    
    
    [self.dayArray removeAllObjects];
    [self.hourArray removeAllObjects];
    for (int x=1; x<61; x++)
    {
        
        [self.dayArray addObject:[NSString stringWithFormat:@"%d",x]];
    }
    
    [_hourPicker reloadAllComponents];
    [_hourPicker selectRow:0 inComponent:0 animated:YES];
    [_scrollview setContentOffset:CGPointMake(0, _advanceBookingDayField.frame.origin.y-150) animated:YES];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _hourPicker.frame = CGRectMake(_hourPicker.frame.origin.x, self.view.bounds.size.height-_hourPicker.frame.size.height , self.view.bounds.size.width, _hourPicker.frame.size.height);
    _pickertoolbar.frame = CGRectMake(_pickertoolbar.frame.origin.x, _hourPicker.frame.origin.y-44, self.view.bounds.size.width, _pickertoolbar.frame.size.height);
    [UIView commitAnimations];
    
    
}
- (IBAction)selectAdvanceBookingHours:(id)sender
{
    [self.keyboardControls resignFirstResponder];
    buttonTag = (int)[sender tag];
    _scrollview.scrollEnabled = NO;
    [self.hourArray removeAllObjects];
    [self.dayArray removeAllObjects];
    float j=0.0;
    
    for ( int i=0; i<48; i++)
    {
        
        j=j+0.5;
        [self.hourArray addObject:[NSString stringWithFormat:@"%.1f",j]];
    }
    [_hourPicker reloadAllComponents];
    [_hourPicker selectRow:0 inComponent:0 animated:YES];
    [_scrollview setContentOffset:CGPointMake(0, _advancedBookingField.frame.origin.y-150) animated:YES];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _hourPicker.frame = CGRectMake(_hourPicker.frame.origin.x, self.view.bounds.size.height-_hourPicker.frame.size.height , self.view.bounds.size.width, _hourPicker.frame.size.height);
    _pickertoolbar.frame = CGRectMake(_pickertoolbar.frame.origin.x, _hourPicker.frame.origin.y-44, self.view.bounds.size.width, _pickertoolbar.frame.size.height);
    [UIView commitAnimations];
}

#pragma mark - end

#pragma mark - Picker toolbar action
- (IBAction)toolBarDoneClicked:(id)sender
{
    if (buttonTag==20) {
        NSInteger index = [_hourPicker selectedRowInComponent:0];
        _serviceSlotField.text=[_hourArray objectAtIndex:index];
        
    }
    else if (buttonTag==21)
    {
        NSInteger index = [_hourPicker selectedRowInComponent:0];
        _advanceBookingDayField.text=[_dayArray objectAtIndex:index];
        
    }
    else
    {
        NSInteger index = [_hourPicker selectedRowInComponent:0];
        _advancedBookingField.text=[_hourArray objectAtIndex:index];
        
    }
    [self hidePickerWithAnimation];
}

-(void)hidePickerWithAnimation
{
    //[_scrollview setContentOffset:CGPointMake(0, 0) animated:YES];
    _scrollview.scrollEnabled = YES;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    _hourPicker.frame = CGRectMake(_hourPicker.frame.origin.x, 1000, self.view.bounds.size.width, _hourPicker.frame.size.height);
    _pickertoolbar.frame = CGRectMake(_pickertoolbar.frame.origin.x, 1000, self.view.bounds.size.width, _pickertoolbar.frame.size.height);
    [UIView commitAnimations];
}

#pragma mark - endbn

#pragma mark - Picker Delegates
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
    
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (buttonTag==20)
    {
        return [_hourArray count];
    }
    else if (buttonTag==21)
    {
        return [_dayArray count];
    }
    else
    {
        return [_hourArray count];
    }
    
    
}



-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (buttonTag==20)
    {
        return [_hourArray objectAtIndex:row];
    }
    else if (buttonTag==21)
    {
        return [_dayArray objectAtIndex:row];
    }
    else
    {
        return [_hourArray objectAtIndex:row];
    }
    
    
}
#pragma mark - end

-(IBAction)deleteImageAction:(id)sender
{
    buttonTag = [sender Tag];
    if(canEdit && (![[imagesArray objectAtIndex:buttonTag] isKindOfClass:[UIImage class]]))
    {
        NSDictionary * nameDict =[imageName objectAtIndex:[sender Tag]];
        [myDelegate ShowIndicator];
        [self performSelector:@selector(deleteImage:) withObject:[nameDict objectForKey:@"Image"] afterDelay:.1];
    }
    else
    {
        [imagesArray removeObjectAtIndex:buttonTag];
        [checkImagesCount removeObjectAtIndex:buttonTag];
        myDelegate.count = (int)imagesArray.count;
        [self resizeScrollview];
        [_collectionView reloadData];
    }
    
}

-(void)deleteImage : (NSString *)imgName
{
    
    AWSS3 *s3 = [AWSS3 defaultS3];
    AWSS3DeleteObjectRequest *deleteRequest = [AWSS3DeleteObjectRequest new];
    deleteRequest.bucket = [NSString stringWithFormat:@"%@/serviceimages",S3BucketName];
    deleteRequest.key = imgName;
    [[s3 deleteObject:deleteRequest] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                        });
                    }
                        break;
                        
                    default:
                        break;
                }
            } else {
            }
        }
        
        if (task.result)
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self deleteImageFromServer : imgName];
                [imagesArray removeObjectAtIndex:buttonTag];
                [checkImagesCount removeObjectAtIndex:buttonTag];
                [imageName removeObjectAtIndex:buttonTag];
                myDelegate.count = (int)imagesArray.count;
                [self resizeScrollview];
                [_collectionView reloadData];
                
                
            });
        }
        
        return nil;
    }];
    
    
}

- (void)upload:(AWSS3TransferManagerUploadRequest *)uploadRequest index : (NSUInteger)index

{
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    
    
    
    [[transferManager upload:uploadRequest] continueWithBlock:^id(BFTask *task) {
        
        if (task.error) {
            
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
               
            }
            
            else {
                
                
            }
            
        }
        
        
        
        if (task.result) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index
                                          
                                                            inSection:0];
                
                [_collectionView reloadItemsAtIndexPaths:@[indexPath]];
                if (index==[imagesArray count]-1) {
                    if(canEdit)
                    {
                        [self performSelector:@selector(callEditServiceWebservice) withObject:nil afterDelay:.1];
                    }
                    else
                    {
                        [self performSelector:@selector(callAddServiceWebservice) withObject:nil afterDelay:.1];
                    }
                }
                
            });
            
        }
        return nil;
        
    }];
    
}



#pragma mark - AWSDownload delegate
-(void)ListObjectprocessCompleted:DownloadimageArray{
    imagesArray=[DownloadimageArray mutableCopy];
    [myDelegate StopIndicator];
    [_collectionView reloadData];
}

-(void)DownloadprocessCompleted:(AWSS3TransferManagerDownloadRequest *)downloadRequest index:(NSUInteger)index{
    
    [imagesArray replaceObjectAtIndex:index
                           withObject:downloadRequest.downloadingFileURL];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [_collectionView reloadItemsAtIndexPaths:@[indexPath]];
    
    
}
#pragma mark - end delegate
@end
