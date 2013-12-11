//
//  SpadeAppDelegate.h
//  Spade
//
//  Created by Devon Ryan on 11/22/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import "SpadeLoginViewController.h"
#import <UIKit/UIKit.h>

@interface SpadeAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, PFLogInViewControllerDelegate,NSURLConnectionDataDelegate>

@property (strong, nonatomic) UIWindow *window;

-(void)presentLoginView;
-(void)logOutUser;

@end
