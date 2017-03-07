//
//  TermsConditionView.m
//  Sure
//
//  Created by Hema on 14/04/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "TermsConditionView.h"

@interface TermsConditionView ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIWebView *termAndCondition_webView;
@end

@implementation TermsConditionView

- (void)viewDidLoad {
    [super viewDidLoad];
    [_indicator startAnimating];
    // Do any additional setup after loading the view.
    self.title=@"Terms and Condition";
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
     NSURL *url = [NSURL URLWithString:@"https://docs.google.com/document/d/1H2lWHV5k3zDUjWjoVVu66fGiMnTARwlnio6Mm1KdATg/preview"];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_termAndCondition_webView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_indicator stopAnimating];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
