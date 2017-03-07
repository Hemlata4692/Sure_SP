//
//  BackViewController.m
//  Sure_sp
//
//  Created by Ranosys on 29/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "BackViewController.h"
#import "SWRevealViewController.h"
@interface BackViewController ()<SWRevealViewControllerDelegate>
{
    UIBarButtonItem *barButton,*barButton1;
}

@end

@implementation BackViewController

#pragma mark - view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back"] secondImage:[UIImage imageNamed:@"menu.png"]];
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end
#pragma mark - Method to global back button
- (void)addLeftBarButtonWithImage:(UIImage *)buttonImage secondImage:(UIImage *)menuImage {
    CGRect framing = CGRectMake(0, 0, menuImage.size.width, menuImage.size.height);
    UIButton *menu = [[UIButton alloc] initWithFrame:framing];
    [menu setBackgroundImage:menuImage forState:UIControlStateNormal];
    barButton1 =[[UIBarButtonItem alloc] initWithCustomView:menu];
    framing = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:framing];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    barButton =[[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:barButton,barButton1, nil];
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [menu addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
}
#pragma mark - end

#pragma mark - back button action
-(void)backButtonAction :(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
