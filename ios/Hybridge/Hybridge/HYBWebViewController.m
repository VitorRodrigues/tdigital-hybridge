//
//  HYBWebViewController.m
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under the Affero GNU GPL v3, see LICENSE for more details.
//

#import "HYBWebViewController.h"
#import "HYBBridge.h"

@interface HYBWebViewController () <NSURLConnectionDelegate>

@property (strong, nonatomic) NSURL *URL;
@property (strong, nonatomic) NSURL *requestedUrl;
@property (nonatomic) BOOL validRequest;

@end

@implementation HYBWebViewController

#pragma mark - Properties

- (UIWebView *)webView {
    return (UIWebView *)self.view;
}

#pragma mark - Lifecycle

- (void)dealloc {
    [self.webView stopLoading];
    self.webView.delegate = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        _bridge = [[HYBBridge alloc] init];
        _bridge.delegate = self;
    }
    
    return self;
}

- (id)initWithURL:(NSURL *)url {
    self = [self initWithNibName:nil bundle:nil];
    
    if (self) {
        _URL = url;
    }
    
    return self;
}

- (void)loadView {
    if ([self nibName]) {
        [super loadView];
        NSAssert([self.view isKindOfClass:[UIWebView class]], @"HYBWebViewController view must be a UIWebView instance.");
    } else {
        UIWebView *view = [[UIWebView alloc] init];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.scalesPageToFit = YES;
        view.delegate = self;
        
        self.view = view;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.URL){
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [HYBBridge setActiveBridge:self.bridge];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.bridge == [HYBBridge activeBridge]) {
        [HYBBridge setActiveBridge:nil];
    }
}

- (void)webViewDidStartLoad {
}

- (void)webViewDidFinishLoad {
}

- (void)webViewDidFailLoadWithError:(NSError *)error {
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self webViewDidStartLoad];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.bridge prepareWebView:webView];
    [self webViewDidFinishLoad];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self webViewDidFailLoadWithError:error];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    self.requestedUrl = request.URL;
    [NSURLConnection connectionWithRequest:request delegate:self];
    return YES;
}

#pragma mark - NSURLConnectionDelegate

//Since WebView handles invalid HTTP STATUS CODES as "OK", it doesn't call delegate errors
//so we need to manually check for the statusCodes
//
// Reference: http://stackoverflow.com/questions/14451012/uiwebview-not-go-to-didfailloadwitherror-when-weblink-not-found
//
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300)
    {
        [connection cancel];
        [self.webView stopLoading];
        [self webView:self.webView didFailLoadWithError:[NSError errorWithDomain:@"HTTP" code:httpResponse.statusCode userInfo:@{ @"URL" : response.URL.absoluteString }]];
    }
    
}

#pragma mark - HYBBridgeDelegate

- (NSArray *)bridgeActions:(HYBBridge *)bridge {
    return nil;
}

@end
