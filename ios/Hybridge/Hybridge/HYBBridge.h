//
//  HYBBridge.h
//  Hybridge
//
//  Copyright (c) 2014 Telefonica I+D. All rights reserved.
//  Licensed under the Affero GNU GPL v3, see LICENSE for more details.
//

#import <UIKit/UIKit.h>

@protocol HYBBridgeDelegate;

/**
 A communication bridge between the Javascript running in a `UIWebView` and the application.
 */
@interface HYBBridge : NSObject

/**
 The bridge delegate will receive actions from the visible `UIWebView`.
 */
@property (weak, nonatomic) NSObject<HYBBridgeDelegate> *delegate;

/**
 Returns the native bridge version.
 */
+ (NSInteger)version;

/**
 Sets the active bridge.
 
 @param bridge The bridge that will receive actions for the visible `UIWebView`.
 */
+ (void)setActiveBridge:(HYBBridge *)bridge;

/**
 Returns active the bridge.
 */
+ (instancetype)activeBridge;

/**
 Configures a `UIWebView` to be able to communicate with this bridge.
 This method should be called after the web view has finished loading the HTML contents.
 
 @param webView The `UIWebView` to configure.
 */
- (void)prepareWebView:(UIWebView *)webView;

/**
 This method is called by the URL loading system when a Hybridge request is made.
 
 When this method is called, the bridge will ask its delegate to handle the action.
 
 If the delegate object implements a `- (void)handle<Action>WithData:(NSDictionary *)data` method,
 the bridge will call this method. The bridge assumes that action names are in snake_case, that is,
 if it receives the action 'go_to_detail' it will look for a method named
 `-handleGoToDetailWithData:`.
 
 If a method is not found, the bridge will try `-bridge:didReceiveAction:data:`. If the delegate
 does not implement neither of these methods, the bridge will return an HTTP 404 status code to the
 caller.
 
 @param action The action name.
 @param data An `NSDictionary` containing data attached to the action.
 
 @return `nil` if the action was handled correctly, otherwise an `NSHTTPURLResponse` initialized with a 404 status code.
 */
- (NSHTTPURLResponse *)sendAction:(NSString *)action data:(NSDictionary *)data;

@end

/**
 Defines the bridge's delegate methods.
 */
@protocol HYBBridgeDelegate <NSObject>

@required

/**
 Returns the array of actions that the receiver can process.
 */
- (NSArray *)bridgeActions:(HYBBridge *)bridge;

@optional

/**
 Called when the bridge receives an action.
 
 @param bridge The bridge that receives the action.
 @param action The action name.
 @param data An `NSDictionary` containing data attached to the action.
 
 @return `nil` if the action was handled correctly, otherwise a `NSHTTPURLResponse` initialized with the appropiate status code.
 */
- (NSHTTPURLResponse *)bridge:(HYBBridge *)bridge didReceiveAction:(NSString *)action data:(NSDictionary *)data;

@end