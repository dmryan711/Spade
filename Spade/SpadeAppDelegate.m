//
//  SpadeAppDelegate.m
//  Spade
//
//  Created by Devon Ryan on 11/22/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import "SpadeAppDelegate.h"
#import "SpadeLoginViewController.h"
#import <Parse/Parse.h>
#import "SpadeEventController.h"

@interface SpadeAppDelegate ()

//@property(strong,nonatomic) UITabBarController *tabBarController;
//@property (strong,nonatomic) UINavigationController *navigationController;



@end


@implementation SpadeAppDelegate

#pragma mark Application Delegate Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    \
    /*****   PARSE APPLICATION *******/
    [Parse setApplicationId:@"XQODiEaHhQUZWP8WdgcD6FAtQLP0XV33hrDtwgJD"
                  clientKey:@"MQI08xDJxyrt0ajlOW3pLaF3SHitkCQGusCsnLTt"];
    
    /***** PARSE ANALYTICS *****/
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [PFFacebookUtils initializeFacebook];
    
    NSLog(@"Bundle ID: %@",[[NSBundle mainBundle] bundleIdentifier]);
    
    UITabBarController *tabBar = (UITabBarController *)self.window.rootViewController;
    tabBar.delegate = self;
    
    return YES;
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark FaceBook Handlers
// Facebook oauth callback
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

#pragma mark Tab Bar Controller Delegate Methods

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"Called");

    


}





@end
