//
//  HYBWebViewController.h
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under the Affero GNU GPL v3, see LICENSE for more details.
//

#import <UIKit/UIKit.h>

#import "HYBBridge.h"

typedef NS_ENUM(NSUInteger, HYBHTTPError) {
    HYBHTTPErrorForbidden = 403,
    HYBHTTPErrorNotFound = 404,
    HYBHTTPErrorServerError = 500,
};

/**
 A view controller that manages a web view and the bridge to communicate with it.
 */
@interface HYBWebViewController : UIViewController <UIWebViewDelegate, HYBBridgeDelegate>

@property (strong, nonatomic, readonly) UIWebView *webView;
@property (strong, nonatomic, readonly) HYBBridge *bridge;

- (id)initWithURL:(NSURL *)url;

- (void)webViewDidStartLoad;

- (void)webViewDidFinishLoad;

- (void)webViewDidFailLoadWithError:(NSError *)error;

@end
