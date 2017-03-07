//
//  PhotoViewController.m
//  SidebarDemoApp
//
//  Created by Ranosys on 06/02/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "PendingConfirmationViewController.h"
#import "SWRevealViewController.h"
#import "PendingConfirmationCell.h"
#import "GlobalMethod.h"
#import "PendingConfirmationModel.h"
#import "BookingRequestViewController.h"
#import "BookingResponseViewController.h"
@interface PendingConfirmationViewController ()
{

    __weak IBOutlet UITableView *pendingListTable;
    __weak IBOutlet UILabel *noPendingConfrmationLbl;

}
@property (strong,nonatomic) NSString *bookingID;

@end

@implementation PendingConfirmationViewController
@synthesize pendingListArray;
@synthesize bookingID;

- (void)viewDidLoad
{
    [super viewDidLoad];
    noPendingConfrmationLbl.hidden=YES;
    
    // Do any additional setup after loading the view.
    self.title = @"Pending Confirmation";
    
    //Remove swipe gesture for sidebar
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:recognizer];
    }
   
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [pendingListArray removeAllObjects];
    [myDelegate StopIndicator];
    [myDelegate StopIndicator];
    [myDelegate ShowIndicator];
    if (myDelegate.pushCount==2)
    {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BookingResponseViewController *objBookingReq = [storyboard instantiateViewControllerWithIdentifier:@"BookingResponseViewController"];
        myDelegate.pushCount =0;
       
        [self.navigationController pushViewController:objBookingReq animated:YES];
        
    }
    else
    {
        myDelegate.pushCount =0;
       [self performSelector:@selector(getPendingConfirmationListForSP) withObject:nil afterDelay:.3];
    }
}

-(void)getPendingConfirmationListForSP
{
    [[WebService sharedManager] getPendingConfirmationList:^(id responseObject)
    {
        
        
        if ([responseObject isKindOfClass:[NSArray class]])
        {
            [myDelegate StopIndicator];
            [myDelegate StopIndicator];
            pendingListArray = [responseObject mutableCopy];
            [pendingListTable reloadData];
        }
        else
        {
            [myDelegate StopIndicator];
            [pendingListTable reloadData];
            noPendingConfrmationLbl.hidden=NO;
        }
        [[NSUserDefaults standardUserDefaults]setInteger:pendingListArray.count forKey:@"PendingConfirmation"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    } failure:^(NSError *error)
     {
         
     }] ;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tableview metohds
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return pendingListArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"PendingConfirmationCell";
    PendingConfirmationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[PendingConfirmationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        
    }
    
    PendingConfirmationModel * dataModel = [pendingListArray objectAtIndex:indexPath.row];
    [cell displayData:dataModel];
    
    return cell;
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PendingConfirmationModel * dataModel = [pendingListArray objectAtIndex:indexPath.row];
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BookingRequestViewController *objBookingReq = [storyboard instantiateViewControllerWithIdentifier:@"BookingRequestViewController"];
   // objBookingReq.objPendingConfirmation = dataModel;
    myDelegate.bookingId =dataModel.bookingId;
    [self.navigationController pushViewController:objBookingReq animated:YES];
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

@end
