//
//  MapViewController.m
//  SidebarDemoApp
//
//  Created by Ranosys on 06/02/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "ServiceManagementViewController.h"
#import "SWRevealViewController.h"
#import "AddServiceViewController.h"
#import "MyButton.h"
#import "GlobalMethod.h"

@interface ServiceManagementViewController (){
  
    NSMutableArray *serviceListData;
    UIButton *lastBtn;
     NSMutableArray *fields;
    int buttonTag;
    __weak IBOutlet UILabel *noServiceLbl;
}
@property (weak, nonatomic) IBOutlet UIView *rightSideView;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (weak, nonatomic) IBOutlet UIButton *editBtnOutlet;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtnOutlet;
- (IBAction)editBtnAction:(id)sender;
- (IBAction)addServiceAction:(id)sender;

@end

@implementation ServiceManagementViewController

@synthesize tableview,rightSideView,editBtnOutlet,cancelBtnOutlet;


#pragma mark - View lifecycle


//The event handling method
- (void)handleTap:(UITapGestureRecognizer *)recognizer {
   
    [self sideViewOperate];
    
    //Do stuff here...
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [[myDelegate navController] setNavigationBarHidden:YES animated:YES];
   [[NSUserDefaults standardUserDefaults]setObject:@"false" forKey:@"testing"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    self.title = @"Service Management";
    rightSideView.hidden=YES;
    rightSideView.translatesAutoresizingMaskIntoConstraints=YES;
    [rightSideView.layer setShadowColor:[UIColor grayColor].CGColor];
    [rightSideView.layer setShadowOpacity:0.5];
    [rightSideView.layer setShadowRadius:2.0];
    [rightSideView.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    [rightSideView.layer setBorderWidth:1.0];
    [rightSideView.layer setBorderColor:(__bridge CGColorRef)([UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0])];
    [self.rightSideView.layer setCornerRadius:2.0];
     serviceListData = [[NSMutableArray alloc]init];
    
    
    
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [myDelegate ShowIndicator];
    [self performSelector:@selector(getServiceListFromServer) withObject:nil afterDelay:.1];
}

-(void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:YES];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - web service methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 11 && buttonIndex==0)
    {
        [myDelegate ShowIndicator];
        [self performSelector:@selector(deleteService) withObject:nil afterDelay:.1];
    }
    
    
}
-(void)getServiceListFromServer
{
    [[WebService sharedManager]getServiceList:^(id responseObject) {
        
        NSMutableArray * tmpAry =[responseObject objectForKey:@"ServiceResponse"];
        
        serviceListData = [tmpAry mutableCopy];
        [[NSUserDefaults standardUserDefaults] setInteger:serviceListData.count forKey:@"ServiceCount"];
        if (serviceListData.count<1)
        {
            noServiceLbl.hidden = NO;
        }
        else
        {
           noServiceLbl.hidden = YES;
        }
        [tableview reloadData];
        
    } failure:^(NSError *error) {
        
    }] ;

}
-(void)deleteService
{
    NSDictionary * tempDict = [serviceListData objectAtIndex:buttonTag];
    [[WebService sharedManager] deleteService:[tempDict objectForKey:@"ServiceId"] success:^(id responseObject)
    {
        if (rightSideView.hidden==NO)
        {
            [self sideViewOperate];
            
        }
        [serviceListData removeObjectAtIndex:buttonTag];
        [tableview reloadData];
        if (serviceListData.count<1)
        {
            noServiceLbl.hidden = NO;
        }
        else
        {
            noServiceLbl.hidden = YES;
        }

        NSDictionary *dict = (NSDictionary *)responseObject;
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:[dict objectForKey:@"Message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
    } failure:^(NSError *error) {
        
    }] ;

}
#pragma mark - end

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return serviceListData.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
     UILabel *Title = (UILabel *)[cell viewWithTag:1];
     NSDictionary * tempDict = [serviceListData objectAtIndex:indexPath.row];
     Title.text = [tempDict objectForKey:@"Name"];
     MyButton *button = (MyButton *)[cell viewWithTag:10];
    button.Tag = (int)indexPath.row;
     [button addTarget:self action:@selector(showEditPopup:) forControlEvents:UIControlEventTouchUpInside];
     button.selected =NO;

    return cell;
}

// Used to remove left gap in table separators in iOS8
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (rightSideView.hidden==NO) {
        [self sideViewOperate];
        
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (rightSideView.hidden==NO) {
        [self sideViewOperate];

    }
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Popover View
-(void)showEditPopup:(MyButton*)sender
{
    //To get frame of button in table view
    buttonTag = [sender Tag];
    CGPoint a= [sender.superview convertPoint:sender.frame.origin toView:self.view];
    
    if (sender.selected==NO) {
        if (rightSideView.hidden==YES) {
            lastBtn=sender; //To maintain the state of last selected button.
            rightSideView.frame=CGRectMake(a.x-85, a.y+18, rightSideView.frame.size.width, rightSideView.frame.size.height);  //To give frame to rightsideView

            rightSideView.hidden=NO;
            [UIView animateWithDuration:0.5
                             animations:
             ^{
                 rightSideView.alpha=1;
             }
             ];
            
        }
        else if(rightSideView.hidden==NO){
            // if current btn is unselected and last btn is selected
            if (sender.selected==NO) {
                lastBtn.selected=NO;        //To set last clicked btn state to unselected.
                lastBtn=sender;
                rightSideView.frame=CGRectMake(a.x-85, a.y+18, rightSideView.frame.size.width, rightSideView.frame.size.height);
                
                rightSideView.hidden=NO;
                rightSideView.alpha=0;
                [UIView animateWithDuration:0.5
                                 animations:
                 ^{
                     rightSideView.alpha=1;
                 }
                 ];
            }
            
        }
        sender.selected=YES;
        
    }
    else{
        [UIView animateWithDuration:0.5 animations:^{
            self.rightSideView.alpha=0;
        } completion:^(BOOL finished){
            rightSideView.hidden=YES;
            
        }];
        
        sender.selected=NO;
    }
}


// Used in didSelectRowAtIndexPath and scrollViewDidScroll for hiding view when table scrolled or when clicked somewhere else on cell
-(void)sideViewOperate{
    lastBtn.selected=NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.rightSideView.alpha=0;
        } completion:^(BOOL finished){
            rightSideView.hidden=YES;
            
        }];
}


- (IBAction)editBtnAction:(id)sender
{
    [self sideViewOperate];
    [editBtnOutlet setBackgroundImage:[GlobalMethod imageWithColor:[UIColor colorWithRed:(233.0/255.0) green:(231.0/255.0) blue:(232.0/255.0) alpha:1]] forState:UIControlStateHighlighted];
    NSDictionary * tempDict = [serviceListData objectAtIndex:buttonTag];
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddServiceViewController * objAddService = [storyboard instantiateViewControllerWithIdentifier:@"AddServiceViewController"];
    objAddService.serviceId = [tempDict objectForKey:@"ServiceId"];
    objAddService.canEdit = YES;
    [self.navigationController pushViewController:objAddService animated:YES];
    
}
- (IBAction)deleteBtnAction:(id)sender
{
    
    
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Are you sure you want to delete this service?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alert.tag = 11;
    [alert show];
}

- (IBAction)addServiceAction:(id)sender
{
    myDelegate.count = 0;
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AddServiceViewController * objAddService = [storyboard instantiateViewControllerWithIdentifier:@"AddServiceViewController"];
    objAddService.canEdit = NO;
    [self.navigationController pushViewController:objAddService animated:YES];
}
@end
