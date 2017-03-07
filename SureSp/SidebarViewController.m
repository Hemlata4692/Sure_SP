//
//  SidebarViewController.m
//  SidebarDemoApp
//
//  Created by Ranosys on 06/02/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "SidebarViewController.h"
#import "SWRevealViewController.h"
#import "PendingConfirmationViewController.h"
#import "LoginViewController.h"
#import "PendingConfirmationViewController.h"

@interface SidebarViewController (){
    NSArray *menuItems;
    NSMutableArray *awsImageArray;
    UIImage * profileImage;
    NSTimer * timer;
}
@end

@implementation SidebarViewController

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    menuItems = @[@"My Calendar", @"My Profile", @"Edit Business", @"Pending My Confirmation", @"Service Management", @"Logout"];
    profileImage = [UIImage imageNamed:@"user.png"];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, self.view.bounds.size.width, 20)];
    statusBarView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:63.0/255.0 blue:64.0/255.0 alpha:1.0];
    [self.view addSubview:statusBarView];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    [self.revealViewController.frontViewController.view setUserInteractionEnabled:YES];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        [timer invalidate];
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(setProfileImage) userInfo:nil repeats:YES];
    [self.revealViewController.frontViewController.view setUserInteractionEnabled:NO];
    //[self.revealViewController.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self.tableView reloadData];
    
}
#pragma mark - end

#pragma mark - Method to set user's profile picture
-(void)setProfileImage
{

    if (myDelegate.sideBarImage!=nil)
    {
        myDelegate.shouldDownload = false;
        profileImage = myDelegate.sideBarImage;
        //myDelegate.sideBarImage = nil;
        [timer invalidate];
        [self.tableView reloadData];
     }
    else
    {
       profileImage = [UIImage imageNamed:@"user.png"];
    }

}
#pragma mark - end


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return menuItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UIImageView *imageview = (UIImageView *)[cell.contentView viewWithTag:4];
    imageview.translatesAutoresizingMaskIntoConstraints = YES;
    if ([[NSUserDefaults standardUserDefaults]integerForKey:@"PendingConfirmation"]>0)
    {
        imageview.frame = CGRectMake(15, 10, imageview.frame.size.width, imageview.frame.size.height);
        imageview.image =[UIImage imageNamed:@"pending_confirmation.png"];
    }
    else
    {
        imageview.frame = CGRectMake(20, 13, imageview.frame.size.width, imageview.frame.size.height);
        imageview.image =[UIImage imageNamed:@"pending.png"];
    
    }
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 140.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 140)];
    headerView.backgroundColor=[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    UILabel * label1;
    label1 = [[UILabel alloc] initWithFrame:CGRectMake(130, 47, 280, 22)];
    label1.backgroundColor = [UIColor clearColor];
    label1.textAlignment=NSTextAlignmentLeft;
    label1.textColor=[UIColor colorWithRed:253.0/255.0 green:47.0/255.0 blue:47.0/255.0 alpha:1.0];
    label1.font = [UIFont fontWithName:@"Helvetica" size:13];
    label1.text = @"Welcome" ;// i.e. array element
    UILabel *label2;
    label2 = [[UILabel alloc] initWithFrame:CGRectMake(130, 53, 130, 60)];
    label2.backgroundColor = [UIColor clearColor];
    label2.textAlignment=NSTextAlignmentLeft;
    label2.lineBreakMode = NSLineBreakByWordWrapping;
    label2.numberOfLines = 2;
    label2.textColor=[UIColor colorWithRed:121.0/255.0 green:115.0/255.0 blue:115.0/255.0 alpha:1.0];
    label2.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"Name"] isEqualToString:@""]) {
        
        label2.text = @"User" ;
    }
    else
    {
        label2.text =[[NSUserDefaults standardUserDefaults]objectForKey:@"Name"];
    }
    // i.e. array element
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 20, 106, 106)] ;
    //imgView.contentMode=UIViewContentModeScaleAspectFill;
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    imgView.image=profileImage;
    imgView.layer.cornerRadius = imgView.frame.size.width / 2;
    [headerView addSubview:label1];
    [headerView addSubview:label2];
    [headerView addSubview:imgView];
    return headerView;   // return headerLabel;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Check Row and Select Next View controller
    if (indexPath.row==0||indexPath.row==1||indexPath.row==3)
    {
        return;
    }
    if (indexPath.row == 5)
    {
        if (!([FBSession activeSession].state != FBSessionStateOpen &&
              [FBSession activeSession].state != FBSessionStateOpenTokenExtended))
        {
            [[FBSession activeSession] closeAndClearTokenInformation];
        }
        UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        myDelegate.window.rootViewController = myDelegate.navController;
        LoginViewController *loginVC=[sb instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [myDelegate.navController setViewControllers: [NSArray arrayWithObject: loginVC]animated: YES];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ServiceCount"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ProfileImage"];
        [defaults removeObjectForKey:@"UserId"];
        [defaults removeObjectForKey:@"PendingConfirmation"];
        [myDelegate unrigisterForNotification];
        myDelegate.sideBarImage = nil;
        myDelegate.shouldDownload = false;
        //[defaults removeObjectForKey:@"HasBusinessProfile"];
        [defaults synchronize];
        
    }
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if(([[NSUserDefaults standardUserDefaults] integerForKey:@"HasBusinessProfile"]==1))
    {
        // Set the title of navigation bar by using the menu items
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
        destViewController.title = [[menuItems objectAtIndex:indexPath.row] capitalizedString];
    }
    
}
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if(([[NSUserDefaults standardUserDefaults] integerForKey:@"HasBusinessProfile"]==0))
    {
        return NO;
    }
    // by default perform the segue transition
    return YES;
}
#pragma mark - end delegate



@end
