//
//  Sure_spViewController.m
//  Sure_sp
//
//  Created by Ranosys on 25/03/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "SureServiceProviderViewController.h"
#import "SWRevealViewController.h"

@interface SureServiceProviderViewController ()
{
    UIBarButtonItem *barButton;
}
@end

@implementation SureServiceProviderViewController

#pragma mark - view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    myDelegate.currentNavigationController=self.navigationController;
//    [[NSUserDefaults standardUserDefaults] setObject:self.navigationController forKey:@"currentNavigationController"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"menu.png"]];
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end
#pragma mark - Method to add global side bar button
- (void)addLeftBarButtonWithImage:(UIImage *)buttonImage {
    CGRect frameimg = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    
    
    UIButton *button = [[UIButton alloc] initWithFrame:frameimg];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    barButton =[[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [button addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    
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
