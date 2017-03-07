//
//  HolidayViewController.m
//  HRM360
//
//  Created by Ranosys on 12/02/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "BusinessProfileViewController.h"
#import "UIView+RoundedCorner.h"
#import "CommentsTableCell.h"
#import "MoreCommentsViewController.h"
#import <MapKit/MapKit.h>
#import "BusinessProfileDataModel.h"
#import "ServiceDataModel.h"
#import "AddressAnnotation.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>
#import "ASStarRatingView.h"
#import "AWSDownload.h"
#import "STKSpinnerView.h"
#import <UIImageView+AFNetworking.h>
#define kCellsPerRow 3

@interface BusinessProfileViewController ()<UIActionSheetDelegate,CLLocationManagerDelegate,MFMailComposeViewControllerDelegate,UIDocumentInteractionControllerDelegate,AWSDownloadDelegate>{
    
    NSMutableDictionary *dic;
    NSMutableArray *serviceListArray,*array;
    int selectedSectionIndex;
    NSMutableArray *imageList,*imageArray;
    UICollectionView *collection;
    NSMutableDictionary * allDataDict;
    __weak IBOutlet UILabel *contactNoLbl;
//    __weak IBOutlet UITextView *addressTextview;
    __weak IBOutlet UILabel *addressLabel;
    SLComposeViewController *slComposerSheet;
    BusinessProfileDataModel * businessData;
    __weak IBOutlet ASStarRatingView *staticStarRatingView;
    AWSDownload *download;
    int globalSection;
    NSMutableArray *profileImageArray;
    STKSpinnerView *progress;
     NSMutableDictionary *imageDict;
    AddressAnnotation *addAnnotation;

}

@property (retain) UIDocumentInteractionController * documentInteractionController;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *informationView;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UITextView *businessDescriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *bookingsLabel;
@property (weak, nonatomic) IBOutlet UITableView *serviceListTable;
@property (weak, nonatomic) IBOutlet UITableView *commentsTable;
@property (weak, nonatomic) IBOutlet UIView *bottomContainerView;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIView *addressDetailView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)loadMoreCommentsAction:(id)sender;
- (IBAction)showActionSheet:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *ratingStarView;
@end

@implementation BusinessProfileViewController
@synthesize scrollView,mainView,informationView,userImageView,businessDescriptionTextView,nameLabel,companyLabel,bookingsLabel,serviceListTable,commentsTable,bottomContainerView,moreButton,addressDetailView,mapView,ratingStarView;

#pragma mark- webservice
//method to disply user's business profile data.
-(void)displayBusinessProfileData
{
    
     businessData = [allDataDict objectForKey:@"BusinessProfileData"];
    
    if ([businessData.bookings intValue]>1)
    {
        bookingsLabel.text = [NSString stringWithFormat:@"%@ Bookings",businessData.bookings];
    }
    else
    {
    bookingsLabel.text = [NSString stringWithFormat:@"%@ Booking",businessData.bookings];
    
    }
    
    nameLabel.text = businessData.name;
    companyLabel.text = businessData.businessName;
    businessDescriptionTextView.text = businessData.businessDescription;
    contactNoLbl.text = businessData.contact;
//    addressTextview.text = [NSString stringWithFormat:@"%@, %@",businessData.address,businessData.pinCode];
    

    addressLabel.text= [NSString stringWithFormat:@"%@, %@",businessData.address,businessData.pinCode];


    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.5;     // 0.0 is min value u van provide for zooming
    span.longitudeDelta= 0.5;
    
    CLLocationCoordinate2D location;
    location.latitude = [businessData.latitude doubleValue];
    location.longitude = [businessData.longitude doubleValue];
    region.span=span;
    region.center =location;     // to locate to the center
    if(addAnnotation != nil)
    {
        [mapView removeAnnotation:addAnnotation];
        addAnnotation = nil;
    }
    addAnnotation = [[AddressAnnotation alloc] initWithCoordinate:location];
    [mapView addAnnotation:addAnnotation];
    [mapView setRegion:region animated:TRUE];
    [mapView regionThatFits:region];
    
    NSURL *url = [NSURL URLWithString:businessData.profileImage];
    if (![businessData.profileImage isEqualToString:@""])
    {
        [profileImageArray addObject:[NSString stringWithFormat:@"%@",[url lastPathComponent]]];
        //progress.hidden=NO;
        [self displayProfilePicture:businessData.profileImage];
        //[download listObjects:self ImageName:profileImageArray folderName:@"businessprofileimages"];
    }
    
    
    serviceListArray = [businessData.serviceDataArray mutableCopy];
    
    NSMutableDictionary *TempDict=[NSMutableDictionary new];
    NSMutableArray *tempArray=[NSMutableArray new];
    for (int i=0;i<serviceListArray.count;i++) {
        ServiceDataModel * serviceData=[serviceListArray objectAtIndex:i];
        tempArray=[NSMutableArray new];
        for (int j=0;j<serviceData.serviceImages.count;j++) {
            TempDict=[NSMutableDictionary new];
            TempDict=[serviceData.serviceImages objectAtIndex:j];
            [tempArray addObject:[TempDict objectForKey:@"Image"]];
            //            [imageArray addObject:[TempDict objectForKey:@"Image"]];
        }
        [imageDict setObject:tempArray forKey:[NSNumber numberWithInt:i]];
        if (tempArray.count>0) {
            [download BusinessProfilelistObjects:self ImageName:tempArray folderName:@"serviceimages" key:i];
        }
        
    }
    
    for(int i=0;i<serviceListArray.count;i++)
    {
        dic=[NSMutableDictionary new];
        [dic setObject:[NSNumber numberWithInt:0] forKey:[NSString stringWithFormat:@"%d",i]];
        [array addObject:dic];
    }
    [self setframesOfObjects];
    [self setRatings];
    [serviceListTable reloadData];
    
}
//method to get user's profile picture.
-(void)displayProfilePicture:(NSString * )imgName
{
    
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:50 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://s3-ap-southeast-1.amazonaws.com/surebeta/businessprofileimages/%@",imgName]] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0f];
    //NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://s3-ap-southeast-1.amazonaws.com/ranosystesting/businessprofileimages/%@",imgName]] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0f];
    UIImage *image = [[UIImageView sharedImageCache] cachedImageForRequest:urlRequest];
    if (image != nil) {
        userImageView.image = image;
        return;
    }
    else
    {
        AFHTTPRequestOperation *postOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        postOperation.responseSerializer = [AFImageResponseSerializer serializer];
        [postOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            UIImage *image = responseObject;
            userImageView.image = image;
            
            [[UIImageView sharedImageCache] cacheImage:image forRequest:urlRequest];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             
         }];
        [postOperation start];
    }
}
//method to set rating of user.
-(void)setRatings
{

    staticStarRatingView.canEdit = NO;
    staticStarRatingView.backgroundColor = [UIColor clearColor];
    staticStarRatingView.leftMargin=2.5;
    staticStarRatingView.midMargin=2;
    staticStarRatingView.maxRating = 5;
    staticStarRatingView.rating = [businessData.overallRating floatValue];
    staticStarRatingView.minAllowedRating = .5;
    staticStarRatingView.maxAllowedRating = 5;

}
//method to get business profile data from server.
-(void)callGetBusinessProfileWebservice
{
    NSMutableArray *tempArray;
    dic=[NSMutableDictionary new];
    serviceListArray=[NSMutableArray new];
    tempArray=[NSMutableArray new];
    selectedSectionIndex=-1;
    [[WebService sharedManager]getBusinessProfileFromServer:^(id responseObject)
     {
         allDataDict = responseObject;
         [self displayBusinessProfileData];
         
     } failure:^(NSError *error) {
         
     }];
}
#pragma mark - end
#pragma mark - View life cycle
-(void)dealloc
{
    serviceListArray = nil;
    array= nil;
    dic = nil;
    imageList = nil;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    myDelegate.shouldCancelDownload=0;
    profileImageArray=[NSMutableArray new];
    globalSection=-1;
    download = [[AWSDownload alloc]init];
    download.delegate = self;
    progress=(STKSpinnerView *)[self.view viewWithTag:30];
    progress.hidden=YES;
    progress.progress=0.0f;
    // Do any additional setup after loading the view.
    self.title = @"Business Profile";
    imageDict=[NSMutableDictionary new];
    self.view.backgroundColor=[UIColor colorWithRed:(238/255.0) green:(238/255.0) blue:(238/255.0) alpha:1];
    serviceListTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    array=[NSMutableArray new];
    imageList=[NSMutableArray new];
    [self roundCornersOfObjects];
    [self roundedCorner];
    [self removeAutolayouts];
    [myDelegate ShowIndicator];
    [self performSelector:@selector(callGetBusinessProfileWebservice) withObject:nil afterDelay:.2];
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//method to round user's image
-(void)roundCornersOfObjects
{
    userImageView.layer.cornerRadius=40.0f;
    userImageView.clipsToBounds=YES;
}
 //method to round corner of total bookings label.
-(void) roundedCorner
{
    [bookingsLabel setCornerRadius:6.0f];
}

-(void)viewWillDisappear:(BOOL)animated{
    //    [download cancelAllOperation:imageDict];
    //myDelegate.shouldCancelDownload=1;
}
#pragma mark - end

#pragma mark - Methods for reframing objects

-(void) removeAutolayouts
{
    staticStarRatingView.translatesAutoresizingMaskIntoConstraints=YES;
    scrollView.translatesAutoresizingMaskIntoConstraints=YES;
    mainView.translatesAutoresizingMaskIntoConstraints=YES;
    informationView.translatesAutoresizingMaskIntoConstraints = YES;
    userImageView.translatesAutoresizingMaskIntoConstraints = YES;
    businessDescriptionTextView.translatesAutoresizingMaskIntoConstraints =YES;
    nameLabel.translatesAutoresizingMaskIntoConstraints =YES;
    companyLabel.translatesAutoresizingMaskIntoConstraints =YES;
    bookingsLabel.translatesAutoresizingMaskIntoConstraints =YES;
    ratingStarView.translatesAutoresizingMaskIntoConstraints=YES;
    serviceListTable.translatesAutoresizingMaskIntoConstraints=YES;
    commentsTable.translatesAutoresizingMaskIntoConstraints=YES;
    bottomContainerView.translatesAutoresizingMaskIntoConstraints=YES;
    moreButton.translatesAutoresizingMaskIntoConstraints=YES;
    addressDetailView.translatesAutoresizingMaskIntoConstraints=YES;
    mapView.translatesAutoresizingMaskIntoConstraints=YES;
    addressLabel.translatesAutoresizingMaskIntoConstraints=YES;
    
}

-(void)setframesOfObjects
{
    
    [self removeAutolayouts];
    scrollView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    informationView.frame=CGRectMake(0, informationView.frame.origin.y, self.view.frame.size.width, informationView.frame.size.height);
    bookingsLabel.frame=CGRectMake(-4, bookingsLabel.frame.origin.y, bookingsLabel.frame.size.width, bookingsLabel.frame.size.height);
    userImageView.frame=CGRectMake(22, bookingsLabel.frame.origin.y+bookingsLabel.frame.size.height+14, userImageView.frame.size.width, userImageView.frame.size.height);
    CGSize size = CGSizeMake(172,999);
    CGRect textRect = [businessData.name
                       boundingRectWithSize:size
                       options:NSStringDrawingUsesLineFragmentOrigin
                       attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica Neue" size:17]}
                       context:nil];
    nameLabel.numberOfLines = 2;
    textRect.origin.x = nameLabel.frame.origin.x-5;
    textRect.origin.y = nameLabel.frame.origin.y+7;
    nameLabel.frame = textRect;
    companyLabel.frame=CGRectMake(nameLabel.frame.origin.x,nameLabel.frame.origin.y+nameLabel.frame.size.height,companyLabel.frame.size.width,companyLabel.frame.size.height);
    staticStarRatingView.frame=CGRectMake(self.view.frame.size.width-staticStarRatingView.frame.size.width, staticStarRatingView.frame.origin.y, staticStarRatingView.frame.size.width, staticStarRatingView.frame.size.height);
    CGSize size1 = CGSizeMake(288,1100);
    CGRect textRect1=[businessData.businessDescription boundingRectWithSize:size1
                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]}
                                                                    context:nil];
    businessDescriptionTextView.scrollEnabled=NO;
    businessDescriptionTextView.frame=CGRectMake(16, userImageView.frame.origin.y+userImageView.frame.size.height+16, self.view.frame.size.width-32, textRect1.size.height+30);
    
    serviceListTable.frame=CGRectMake(0, businessDescriptionTextView.frame.origin.y+businessDescriptionTextView.frame.size.height+10, self.view.frame.size.width, serviceListArray.count*60);
    [self bottomViewFrame];
    
}

-(void)bottomViewFrame
{
    
    bottomContainerView.frame=CGRectMake(0, serviceListTable.frame.origin.y+serviceListTable.frame.size.height+16, self.view.frame.size.width, bottomContainerView.frame.size.height);
    if ([businessData.comments  count]<1)
    {
        commentsTable.frame=CGRectMake(0, 0, self.view.frame.size.width, 0);
        mainView.frame=CGRectMake(0, 0, self.scrollView.frame.size.width, bottomContainerView.frame.size.height+(bottomContainerView.frame.origin.y-mapView.frame.size.height));
        moreButton.frame=CGRectMake(bottomContainerView.frame.size.width-46-20, commentsTable.frame.size.height+10, 0, 0);
        
    }
    else if(businessData.comments.count==3)
    {
        commentsTable.frame=CGRectMake(0, 0, self.view.frame.size.width, businessData.comments.count*88);
        mainView.frame=CGRectMake(0, 0, self.scrollView.frame.size.width, bottomContainerView.frame.size.height+bottomContainerView.frame.origin.y+30);
        moreButton.frame=CGRectMake(bottomContainerView.frame.size.width-46-20, commentsTable.frame.size.height+10, moreButton.frame.size.width, moreButton.frame.size.height);
        [commentsTable reloadData];
    }
    else
    {
        commentsTable.frame=CGRectMake(0, 0, self.view.frame.size.width, businessData.comments.count*88);
        mainView.frame=CGRectMake(0, 0, self.scrollView.frame.size.width, bottomContainerView.frame.size.height+bottomContainerView.frame.origin.y+30);
        moreButton.frame=CGRectMake(bottomContainerView.frame.size.width-46-20, commentsTable.frame.size.height+10, 0, 0);
        [commentsTable reloadData];
    
    }
    CGSize size = CGSizeMake(bottomContainerView.frame.size.width-32-addressLabel.frame.origin.x-15,999);
    CGRect textRect = [addressLabel.text
                       boundingRectWithSize:size
                       options:NSStringDrawingUsesLineFragmentOrigin
                       attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}
                       context:nil];
    addressLabel.numberOfLines = 0;
    textRect.origin.x = addressLabel.frame.origin.x;
    textRect.origin.y = addressLabel.frame.origin.y;
    addressLabel.frame = textRect;
    addressLabel.frame=CGRectMake(addressLabel.frame.origin.x, contactNoLbl.frame.origin.y+contactNoLbl.frame.size.height+5, bottomContainerView.frame.size.width-32-addressLabel.frame.origin.x-15 , addressLabel.frame.size.height);
    addressDetailView.frame=CGRectMake(16, moreButton.frame.origin.y+moreButton.frame.size.height+10, bottomContainerView.frame.size.width-32, contactNoLbl.frame.origin.y+contactNoLbl.frame.size.height+10+addressLabel.frame.size.height+10);
         mapView.frame=CGRectMake(16, addressDetailView.frame.origin.y+addressDetailView.frame.size.height+10, bottomContainerView.frame.size.width-32, mapView.frame.size.height);
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, self.mainView.frame.size.height, 0);
    
    
}

#pragma mark - table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView==serviceListTable) {
        return serviceListArray.count;
    }
    else
        return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==serviceListTable)
    {
        NSMutableDictionary *temp=[array objectAtIndex:section];
        if ([[temp objectForKey:[NSString stringWithFormat:@"%ld",(long)section]] intValue])  {
            return 1;
        }
        return 0;
    }
    else
        return businessData.comments.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView;
    if (tableView==serviceListTable) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 60.0)];
        headerView.backgroundColor = [UIColor whiteColor];
        headerView.layer.borderColor = [UIColor colorWithRed:(245/255.0) green:(245/255.0) blue:(245/255.0) alpha:1].CGColor;
        headerView.layer.borderWidth = 1.0f;
        ServiceDataModel * serviceData=[serviceListArray objectAtIndex:section];
        UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake(10, (headerView.frame.size.height/2)-7, 14, 14.0)];
        image.backgroundColor = [UIColor clearColor];
        NSMutableDictionary *temp=[array objectAtIndex:section];
        if ([[temp objectForKey:[NSString stringWithFormat:@"%ld",(long)section]] intValue])  {
            image.image=[UIImage imageNamed:@"arrow_icon_up.png"];
        }
        else{
            image.image=[UIImage imageNamed:@"arrow_icon.png"];
        }
        [headerView addSubview:image];
        UILabel * time = [[UILabel alloc] initWithFrame:CGRectMake( tableView.bounds.size.width-125, (headerView.frame.size.height/2)-10, 120, 20)];
        time.backgroundColor = [UIColor clearColor];
        time.textAlignment=NSTextAlignmentRight;
        time.textColor=[UIColor colorWithRed:(96/255.0) green:(94/255.0) blue:(95/255.0) alpha:1];
        time.text=serviceData.serviceCharges;
        time.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
        [headerView addSubview:time];
        int check=tableView.bounds.size.width-(image.frame.origin.x+image.frame.size.width+10)-(time.frame.size.width)-5;
        UILabel * subject = [[UILabel alloc] initWithFrame:CGRectMake(image.frame.origin.x+image.frame.size.width+10, 12, check, 20.0)];
        subject.backgroundColor = [UIColor clearColor];
        subject.textAlignment=NSTextAlignmentLeft;
        subject.textColor=[UIColor colorWithRed:(28/255.0) green:(28/255.0) blue:(28/255.0) alpha:1];
        subject.text=serviceData.name;
        subject.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        [headerView addSubview:subject];
        UILabel * label1 = [[UILabel alloc] initWithFrame:CGRectMake(subject.frame.origin.x, subject.frame.origin.y+subject.frame.size.height, check, 15)];
        label1.backgroundColor = [UIColor clearColor];
        label1.textAlignment=NSTextAlignmentLeft;
        label1.textColor=[UIColor colorWithRed:(96/255.0) green:(94/255.0) blue:(95/255.0) alpha:1];
        if ([serviceData.serviceType intValue]==1) {
            label1.text = @"On-Site";
        }
        else
        {
            label1.text = @"In-Shop";
        }
        label1.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
        [headerView addSubview:label1];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self
                   action:@selector(buttonClicked:)
         forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(0,0,  tableView.bounds.size.width, 50.0);
        button.tag=section;
        [headerView addSubview:button];
        
    }
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==serviceListTable)
    {
        ServiceDataModel * serviceData=[serviceListArray objectAtIndex:selectedSectionIndex];
        NSMutableArray *checker=[serviceData.serviceImages mutableCopy];
        CGSize size = CGSizeMake(serviceListTable.frame.size.width-32,999);
        CGRect textRect = [serviceData.serviceDescription
                           boundingRectWithSize:size
                           options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}
                           context:nil];
//        addressLabel.numberOfLines = 5;
        textRect.origin.x = 16;
        textRect.origin.y = 8;
//        serviceDescriptionLabel.frame = textRect;
        
        if (checker.count>0)
        {
                mainView.frame=CGRectMake(0, 0, self.scrollView.frame.size.width, mainView.frame.size.height+112);
                scrollView.contentInset = UIEdgeInsetsMake(0, 0, self.mainView.frame.size.height-140, 0);
            return 140+textRect.size.height;
        }
        else
        {
            return 28+textRect.size.height;
        }
    }
    else
    {
        return 88;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView==serviceListTable) {
        return 60.0;
    }
    else
        return 0.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==serviceListTable) {
        UITableViewCell *cell ;
        NSString *simpleTableIdentifier = @"ServiceListCell";
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        cell.backgroundColor=[UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
        ServiceDataModel * serviceData=[serviceListArray objectAtIndex:indexPath.section];
        [imageList removeAllObjects];
        imageList=[serviceData.serviceImages mutableCopy];
        UILabel *serviceDescriptionLabel=(UILabel *)[cell viewWithTag:6];
        collection=(UICollectionView *)[cell viewWithTag:30];
        serviceDescriptionLabel.translatesAutoresizingMaskIntoConstraints=YES;
        collection.translatesAutoresizingMaskIntoConstraints=YES;
        serviceDescriptionLabel.text= serviceData.serviceDescription;
        CGSize size = CGSizeMake(serviceListTable.frame.size.width-32,999);
        CGRect textRect = [serviceDescriptionLabel.text
                           boundingRectWithSize:size
                           options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}
                           context:nil];
        serviceDescriptionLabel.numberOfLines = 0;
        textRect.origin.x = serviceDescriptionLabel.frame.origin.x;
        textRect.origin.y = serviceDescriptionLabel.frame.origin.y;
        serviceDescriptionLabel.frame = textRect;
        serviceDescriptionLabel.frame =CGRectMake(16, serviceDescriptionLabel.frame.origin.y, serviceListTable.frame.size.width-32, serviceDescriptionLabel.frame.size.height);
        collection.frame =CGRectMake(16, serviceDescriptionLabel.frame.origin.y+serviceDescriptionLabel.frame.size.height+12, serviceListTable.frame.size.width-32, collection.frame.size.height);
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)collection.collectionViewLayout;
        CGFloat availableWidthForCells = CGRectGetWidth(self.view.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumInteritemSpacing * (kCellsPerRow-1)-32;
        CGFloat cellWidth = (availableWidthForCells / kCellsPerRow)-8;
        flowLayout.itemSize = CGSizeMake(cellWidth, flowLayout.itemSize.height);
        if (imageList.count>0)
        {
            collection.hidden=NO;
        }
        else{
            collection.hidden=YES;
        }
        [collection reloadData];
        return cell;
    }
    else{
        
        NSString *simpleTableIdentifier = @"commentsCell";
        CommentsTableCell *cell1 = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell1 == nil)
        {
            cell1 = [[CommentsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        
        [cell1 layoutView:self.view.frame];
        NSDictionary * tmpDict = [businessData.comments objectAtIndex:indexPath.row];
        [cell1 displayCommentData:tmpDict];
        return cell1;
    }
    
}
#pragma mark-end

#pragma mark- Section Button action
-(void) buttonClicked:(UIButton*)sender
{
    mainView.frame=CGRectMake(0, 0, self.scrollView.frame.size.width, mainView.frame.size.height-112);
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, self.mainView.frame.size.height, 0);
    int tag = (int)((UIButton *)sender).tag;
    NSMutableDictionary *temp=[array objectAtIndex:tag];
    if (![[temp objectForKey:[NSString stringWithFormat:@"%d",tag]] intValue])
    {
        [array removeAllObjects];
        globalSection=tag;
        ServiceDataModel * serviceData=[serviceListArray objectAtIndex:tag];
        NSMutableArray *checker=[serviceData.serviceImages mutableCopy];
        [imageList removeAllObjects];
        imageList=[checker mutableCopy];
       
        CGSize size = CGSizeMake(serviceListTable.frame.size.width-32,999);
        CGRect textRect = [serviceData.serviceDescription
                           boundingRectWithSize:size
                           options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}
                           context:nil];
        textRect.origin.x = 16;
        textRect.origin.y = 8;
        if (checker.count>0)
        {
            serviceListTable.frame=CGRectMake(0, serviceListTable.frame.origin.y, self.view.frame.size.width, (serviceListArray.count*60)+140+textRect.size.height);
        }
        else
            serviceListTable.frame=CGRectMake(0, serviceListTable.frame.origin.y, self.view.frame.size.width, (serviceListArray.count*60)+28+textRect.size.height);
        selectedSectionIndex=tag;
        [self bottomViewFrame];
        for(int i=0;i<serviceListArray.count;i++)
        {
            dic=[NSMutableDictionary new];
            if (tag==i)
            {
                [dic setObject:[NSNumber numberWithBool:1] forKey:[NSString stringWithFormat:@"%d",i]];
            }
            else
            {
                [dic setObject:[NSNumber numberWithBool:0] forKey:[NSString stringWithFormat:@"%d",i]];
            }
            
            [array addObject:dic];
        }
    }
    else{
         globalSection=-1;
        [array removeAllObjects];
        [imageList removeAllObjects];
        serviceListTable.frame=CGRectMake(0, serviceListTable.frame.origin.y, self.view.frame.size.width, serviceListArray.count*60);
        [self bottomViewFrame];
        for(int i=0;i<serviceListArray.count;i++){
            dic=[NSMutableDictionary new];
            [dic setObject:[NSNumber numberWithBool:0] forKey:[NSString stringWithFormat:@"%d",i]];
            [array addObject:dic];
        }
    }
    [serviceListTable reloadData];
}
#pragma mark-end

#pragma mark- Cell collection view methods
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    //    NSString *searchTerm = self.searches[section];
    
    return imageList.count;
}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}
// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *imageCell = [cv dequeueReusableCellWithReuseIdentifier:@"collectioncell" forIndexPath:indexPath];
    imageCell.backgroundColor = [UIColor greenColor];
    UIImageView *image=(UIImageView *)[imageCell viewWithTag:7];
    
    image.translatesAutoresizingMaskIntoConstraints=YES;
    image.frame =CGRectMake(0, 0, imageCell.frame.size.width, imageCell.frame.size.height);
    image.image=[UIImage imageNamed:@"picture.png"];
    UIProgressView *collectionViewProgress=(UIProgressView *)[imageCell viewWithTag:30];
    collectionViewProgress.hidden=YES;
    collectionViewProgress.translatesAutoresizingMaskIntoConstraints=YES;
    collectionViewProgress.frame=CGRectMake(0, imageCell.frame.size.height-2, imageCell.frame.size.width, collectionViewProgress.frame.size.height);
    //image.image=[UIImage imageNamed:[imageList objectAtIndex:indexPath.row]];
    NSMutableArray *localArray=[NSMutableArray new];
    localArray=[imageDict objectForKey:[NSNumber numberWithInt:globalSection]];
    if (localArray.count>0) {
//        [imageIndicator stopAnimating];
//        imageIndicator.hidden=YES;
        
        
        id object = [localArray objectAtIndex:indexPath.row];
        if ([object isKindOfClass:[AWSS3TransferManagerDownloadRequest class]])
        {
            collectionViewProgress.hidden=NO;
            
            AWSS3TransferManagerDownloadRequest *downloadRequest = object;
            //            [self download:downloadRequest index:indexPath.row];
            downloadRequest.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (totalBytesExpectedToWrite > 0) {
                        collectionViewProgress.progress = (float)((double) totalBytesWritten / totalBytesExpectedToWrite);
                        
                    }
                });
            };
        }
        else if ([object isKindOfClass:[NSURL class]])
        {
            collectionViewProgress.hidden=YES;
            NSURL *downloadFileURL = object;
            image.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:downloadFileURL]];
        }
        
    }
    return imageCell;
}
#pragma mark-end

- (IBAction)loadMoreCommentsAction:(id)sender {
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MoreCommentsViewController *objProductDetail =[storyboard instantiateViewControllerWithIdentifier:@"MoreCommentsViewController"];
    [self.navigationController pushViewController:objProductDetail animated:YES];
    
}

- (IBAction)showActionSheet:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share via" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email",@"Facebook", @"Twitter",@"Whatsapp",nil];
    [actionSheet showInView:self.view];
    
}

// UIActionSheetDelegate method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Share using whatsapp
    if (buttonIndex==3)
    {
        
        NSString * msg = [NSString stringWithFormat:@"%@ %@ %@ %@ %@%@%@%@\n\n%@\n\n%@",@"Check out",nameLabel.text,@"from",companyLabel.text,@"on Sure",@"(",[NSURL URLWithString: @"http://www.allsurething.com/"],@")",businessDescriptionTextView.text,@"Sure makes your life easier! We believe that booking local services should be easy, fast and definitely reliable! Through our app, you can book a trusted service provider in just a few clicks. With the collections of all the best services in town, we are opening up more possibilities in life for you."];
        NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",msg];
        NSURL * whatsappURL = [NSURL URLWithString:[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if ([[UIApplication sharedApplication] canOpenURL: whatsappURL])
        {
            [[UIApplication sharedApplication] openURL: whatsappURL];
        }
        else
        {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"WhatsApp not installed." message:@"Your device has WhatsApp not installed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    
    else if (buttonIndex==1)
    {
        //Share on facebook
        if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=6)
        {
            
            slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            [slComposerSheet setInitialText:[NSString stringWithFormat:@"%@ %@ %@ %@ %@%@%@%@\n\n%@\n\n%@",@"Check out",nameLabel.text,@"from",companyLabel.text,@"on Sure",@"(",[NSURL URLWithString: @"http://www.allsurething.com/"],@")",businessDescriptionTextView.text,@"Sure makes your life easier! We believe that booking local services should be easy, fast and definitely reliable! Through our app, you can book a trusted service provider in just a few clicks. With the collections of all the best services in town, we are opening up more possibilities in life for you."]];
            [slComposerSheet addImage:[UIImage imageNamed:@"appicon180.png"]];
            [slComposerSheet addURL:[NSURL URLWithString:nil]];
            [self presentViewController:slComposerSheet animated:YES completion:nil];
            [slComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
                NSString *output;
                switch (result) {
                    case SLComposeViewControllerResultCancelled:
                        output = @"Action Cancelled";
                        break;
                    case SLComposeViewControllerResultDone:
                        output = @"Your Post has been shared successfully.";
                        break;
                    default:
                        break;
                }
                if (result != SLComposeViewControllerResultCancelled)
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                }
            }];
            
        }
        else
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.facebook.com"]];
        }
    }
    else if (buttonIndex==2)
    {
        //Share on twitter
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheet setInitialText:[NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@%@%@",@"Check out",nameLabel.text,@"from",companyLabel.text,@"on Sure",@"(",[NSURL URLWithString: @"http://www.allsurething.com/"],@")"]];
            [slComposerSheet addImage:[UIImage imageNamed:@"appicon180.png"]];
            [tweetSheet addImage:[UIImage imageNamed:@"appicon180.png"]];
            [self presentViewController:tweetSheet animated:YES completion:nil];
            
            [tweetSheet setCompletionHandler:^(SLComposeViewControllerResult result)
             {
                 
                 NSString *output;
                 switch (result) {
                     case SLComposeViewControllerResultCancelled:
                         output = @"Action Cancelled";
                         break;
                     case SLComposeViewControllerResultDone:
                         output = @"Your Post has been shared successfully.";
                         break;
                     default:
                         break;
                 }
                 if (result != SLComposeViewControllerResultCancelled)
                 {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:output delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                     [alert show];
                 }
             }];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"Sorry"
                                      message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
        }
        
    }
    
    //Share via email
    else if (buttonIndex==0)
    {
        if ([MFMailComposeViewController canSendMail])
        {
            // Email Subject
            NSString *emailTitle = @"Sure";
            NSArray *toRecipents = [NSArray arrayWithObject:@""];
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;
            [mc setSubject:emailTitle];
            [mc setMessageBody:[NSString stringWithFormat:@"%@ %@ %@ %@ %@%@%@%@\n\n%@\n\n%@",@"Check out",nameLabel.text,@"from",companyLabel.text,@"on Sure",@"(",[NSURL URLWithString: @"http://www.allsurething.com/"],@")",businessDescriptionTextView.text,@"Sure makes your life easier! We believe that booking local services should be easy, fast and definitely reliable! Through our app, you can book a trusted service provider in just a few clicks. With the collections of all the best services in town, we are opening up more possibilities in life for you."] isHTML:NO];
            [mc setToRecipients:toRecipents];
            
            [self presentViewController:mc animated:YES completion:NULL];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:nil
                                      message:@"Email account is not configured in your device."
                                      delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
            [alertView show];
        }
        
    }
    
}
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //Actions for composing the email
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - end

#pragma mark - AWSDownload image download methods
-(void)ListObjectprocessCompleted:DownloadimageArray{
    [profileImageArray removeAllObjects];
    profileImageArray=[DownloadimageArray mutableCopy];
    //    [myDelegate StopIndicator];
    //    [collection reloadData];
    id object = [profileImageArray objectAtIndex:0];
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
    
    [profileImageArray replaceObjectAtIndex:index
                                 withObject:downloadRequest.downloadingFileURL];
    progress.hidden=YES;
    progress.progress = 1.0f;
    userImageView.image =[UIImage imageWithData:[NSData dataWithContentsOfURL:downloadRequest.downloadingFileURL]];
}

- (void) BusinessProfileListObjectprocessCompleted:DownloadimageArray key:(int)section{
    [imageArray removeAllObjects];
    imageArray=[DownloadimageArray mutableCopy];
    [imageDict setObject:DownloadimageArray forKey:[NSNumber numberWithInt:section]];
}

- (void) BusinessProfileDownloadprocessCompleted:(AWSS3TransferManagerDownloadRequest *)downloadRequest index : (NSUInteger)index key:(int)section{
    //    [imageDict setObject:DownloadimageArray forKey:[NSNumber numberWithInt:section]];
    NSMutableArray *localArray=[NSMutableArray new];
    localArray=[imageDict objectForKey:[NSNumber numberWithInt:section]];
    [localArray replaceObjectAtIndex:index
                          withObject:downloadRequest.downloadingFileURL];
    [imageDict setObject:localArray forKey:[NSNumber numberWithInt:section]];
    //        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    //           [collection reloadItemsAtIndexPaths:@[indexPath]];
         [collection reloadData];
    
}
#pragma mark - end delegate


@end
