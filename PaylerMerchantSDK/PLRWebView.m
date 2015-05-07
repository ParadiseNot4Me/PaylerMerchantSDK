//
//  PLRWebView.m
//  PaylerMerchantSDK
//
//  Created by Иван Григорьев on 07.05.15.
//  Copyright (c) 2015 poloniumarts. All rights reserved.
//

#import "PLRWebView.h"

@interface PLRWebView ()<UIWebViewDelegate>

@property (nonatomic, weak) UIActivityIndicatorView *activityView;
@property (nonatomic, copy) PLRCompletionBlock completionBlock;
@property (nonatomic, strong) PLRPayment *payment;

@end

@implementation PLRWebView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self commonInit];
}

- (void)commonInit {
    self.delegate = self;
    //self.scalesPageToFit = YES;
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:activityView];
    self.activityView = activityView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.activityView.center = CGPointMake(CGRectGetWidth(self.frame)/2, 40.0);
}

- (void)auth3dsForPayment:(PLRPayment *)payment withCompletion:(PLRCompletionBlock)completion{
    self.completionBlock = completion;
    self.payment = payment;
    NSDictionary *postParameters = @{@"MD": payment.md, @"TermUrl": @"http://payler.com/", @"PaReq": payment.pareq};
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST"
                                                                                 URLString:payment.acs_url
                                                                                parameters:postParameters
                                                                                     error:nil];
    
    [self loadRequest:request];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = [request.URL absoluteString];
    if ([urlString isEqualToString:@"http://payler.com/"]) {
        NSString *response = [[NSString alloc] initWithData:request.HTTPBody encoding:NSASCIIStringEncoding];
        NSDictionary *responseDictionary = [self parseQueryString:response];
        self.payment.pares = responseDictionary[@"PaRes"];
        self.payment.md = responseDictionary[@"MD"];
        self.completionBlock(self.payment, nil);
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (!self.activityView.isAnimating) [self.activityView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.activityView stopAnimating];
}

#pragma mark - Utilities

- (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

@end


