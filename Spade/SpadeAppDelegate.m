//
//  SpadeAppDelegate.m
//  Spade
//
//  Created by Devon Ryan on 11/22/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import "SpadeAppDelegate.h"
#import "SpadeUtility.h"
#import "SpadeLoginViewController.h"
#import <Parse/Parse.h>
#import "SpadeFeedController.h"
#import "SpadeCache.h"
#import "SpadeEditProfileViewController.h"
#import "SpadeConstants.h"
#import "SpadeFriendTableViewController.h"

@interface SpadeAppDelegate ()

@property (strong,nonatomic) UITabBarController *tabBarController;
@property (strong,nonatomic) NSMutableData *data;


@end


@implementation SpadeAppDelegate

#pragma mark Application Delegate Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //Initially Set Flag to NO
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{spadePicFLag:@NO, spadeNameFlag:@NO, spadeFirstLoginFlag:@YES}];

                                                                 
    /*****   PARSE APPLICATION *******/
    [Parse setApplicationId:@"XQODiEaHhQUZWP8WdgcD6FAtQLP0XV33hrDtwgJD"
                  clientKey:@"MQI08xDJxyrt0ajlOW3pLaF3SHitkCQGusCsnLTt"];
    
    /***** PARSE ANALYTICS *****/
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [PFFacebookUtils initializeFacebook];
    
    NSLog(@"Bundle ID: %@",[[NSBundle mainBundle] bundleIdentifier]);
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    
    //Getting a Reference to the UITabBarController & setting the delegate
    self.tabBarController = [mainStoryboard instantiateInitialViewController];
    self.tabBarController.delegate = self;

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:self.tabBarController];
    [self.window makeKeyAndVisible];
    
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
   

}




#pragma mark Spade Login Delegate Methods
#define LEFT_VIEWCONTROLLER 0
// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    
   
    
    //Get Rid of the Login View
    [[self.tabBarController.viewControllers objectAtIndex:LEFT_VIEWCONTROLLER] dismissViewControllerAnimated:YES completion:nil];
    
    //Set Requests
    FBRequest *requestForFriends = [FBRequest requestForMyFriends];
    FBRequest *request = [FBRequest requestForMe];
    
    //Request Friends
    [requestForFriends startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        if (!error) {
            
            NSArray *data = [result objectForKey:@"data"];
            
            //Create List of Friend Ids
            if (data) {
                NSMutableArray *friendIdList = [[NSMutableArray alloc]initWithCapacity:[data count]];
                for (NSDictionary *friend in data){
                    [friendIdList addObject:friend[@"id"]];
                }
                
                [user setObject:friendIdList forKey:spadeUserFriends];
                
                [user saveEventually];
                
                
            }
            
        } else if ([error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"type"] isEqualToString:@"OAuthException"]) {//Request Failed , Checking Why
            NSLog(@"The facebook session was invalidated");
            [self logOutUser];
            
        } else {
            NSLog(@"Some other error: %@", error);
            [self logOutUser];
        }
        
        
    }];
    
    //Request User Information
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        if (!error) {
            
            
            //NSLog(@"%@",[result description]);
            
            //Store Facebook Results to local objects
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *email = [userData objectForKey:@"email"];
            NSString *gender = [userData objectForKey:@"gender"];
            NSString  *locale = [userData objectForKey:@"locale"];
            NSString *birthday = [userData objectForKey:@"birthday"];
            NSString *fullName = [userData objectForKey:@"name"];
            NSString *faceBookID = [userData objectForKey:@"id"];
            
            //Derive Age from Birthday
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"MM/dd/yyyy"];
            [dateFormat dateFromString:birthday];
            NSNumber *age = [NSNumber numberWithInteger:[SpadeUtility age:[dateFormat dateFromString:birthday]]];
            
            //Save local facebook result to Parse
            [user setObject:email forKey:spadeUserEmail];
            [user setObject:gender forKey:spadeUserGender];
            [user setObject:locale forKey:spadeUserLocale];
            [user setObject:birthday forKey:spadeUserBirthday];
            [user setObject:age forKey:spadeUserAge];;
            [user setObject:faceBookID forKey:spadeUserFacebookId];
           
            
            if (![[NSUserDefaults standardUserDefaults]boolForKey:spadePicFLag]) { //User Did not Change Picture
                NSLog(@"Pic Flag No");
                // Download user's profile picture
                NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", faceBookID]];
                NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f]; // Facebook profile picture cache policy: Expires in 2 weeks
                [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
                
            }
            if (![[NSUserDefaults standardUserDefaults]boolForKey:spadeNameFlag] ) { //User Did not Change Name
                [user setObject:fullName forKey:spadeUserDisplayName];
            }
            
            
            [self setCacheForUser];
            
            //Save to Parse
            [user saveInBackgroundWithBlock:^(BOOL succeeded , NSError *error){
                if (succeeded) {
                    
                    //Follow the Spade Team
                    PFQuery *querySpadeTeam = [PFQuery queryWithClassName:spadeClassUser];
                    [querySpadeTeam whereKey:spadeUserFacebookId containedIn:@[spadeDevonFacebookId]];
                    
                    [querySpadeTeam findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                        if (!error) {
                            NSLog(@"HIT");
                            [SpadeUtility user:[PFUser currentUser] followingUsers:objects];
                        }
                    }];
                }
            }];
                
            
        } else if ([error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"type"] isEqualToString:@"OAuthException"]) {//Request Failed , Checking Why
            NSLog(@"The facebook session was invalidated");
            [self logOutUser];
            
        } else {
            NSLog(@"Some other error: %@", error);
            [self logOutUser];
        }
        
        
    }];
}


// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"User dimissed the loginviewcontroller");
    [[self.tabBarController.viewControllers objectAtIndex:LEFT_VIEWCONTROLLER] dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark NSConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.data appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [SpadeUtility processProfilePictureData:self.data];

}


#pragma mark {   }

-(void)presentLoginView
{
    SpadeLoginViewController *logInViewController = [[SpadeLoginViewController alloc] init];
    [logInViewController setDelegate:self]; // Set ourselves as the delegate
    [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"email",@"user_location",@"user_birthday", nil]];
    [logInViewController setFields:PFLogInFieldsFacebook];
    
    
    // Present the log in view controller
    [[self.tabBarController.viewControllers objectAtIndex:LEFT_VIEWCONTROLLER ] presentViewController:logInViewController animated:YES completion:NULL];
}

-(void)presentFriendsViewController
{

    // Present Friend List
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    //Create Detail View
    SpadeFriendTableViewController *friendListViewController = [mainStoryboard   instantiateViewControllerWithIdentifier:@"findFriendView"];
    
    [[self.tabBarController.viewControllers objectAtIndex:LEFT_VIEWCONTROLLER] presentViewController:friendListViewController animated:YES completion:NULL];

}

-(void)logOutUser{
    
    [PFUser logOut];
    
    [self presentLoginView];
    
}


-(void)setCacheForUser{
    
    NSLog(@"Venue Cache %@",[[SpadeCache sharedCache]followingVenues]);
    //Query for Followed Venues
    PFQuery *queryFollowedVenues = [PFQuery queryWithClassName:spadeClassActivity];
    [queryFollowedVenues whereKey:spadeActivityFromUser equalTo:[PFUser currentUser]];
    [queryFollowedVenues whereKeyExists:spadeActivityToVenue];
    
    //Run Query
    [queryFollowedVenues findObjectsInBackgroundWithBlock:^(NSArray *followedVenuesForUserFromParse, NSError *error){
        if (!error) {
            for(PFObject *object in followedVenuesForUserFromParse){
                
                [[[SpadeCache sharedCache]followingVenues]addObject:[[object objectForKey:spadeActivityToVenue]objectId]];
            }
            
        }else{
            NSLog(@"App Delegate Set Query Error:%@",error);
        
        }
        
        NSLog(@"Venue Cache %@",[[SpadeCache sharedCache]followingVenues]);
    }];
    
    //Query for Followed Users
    PFQuery *queryFollowedUsers = [PFQuery queryWithClassName:spadeClassActivity];
    [queryFollowedUsers whereKey:spadeActivityFromUser equalTo:[PFUser currentUser]];
    [queryFollowedUsers whereKeyExists:spadeActivityToUser];
    //Run Query
    [queryFollowedUsers findObjectsInBackgroundWithBlock:^(NSArray *followedUsersForUserFromParse, NSError *error){
        if (!error) {
            for(PFObject *object in followedUsersForUserFromParse){
                [[[SpadeCache sharedCache]followingUsers]addObject:[[object objectForKey:spadeActivityToUser]objectId]];
            }
        }else{
            NSLog(@"App Delegate Set Query Error:%@",error);
            
        }
        
        NSLog(@"HITTT user cache");
        NSLog(@"User Cache %@",[[SpadeCache sharedCache]followingUsers]);
        
    }];

    

    //Query for Followed Users
    PFQuery *queryFollowedEvents = [PFQuery queryWithClassName:spadeClassActivity];
    [queryFollowedEvents whereKey:spadeActivityFromUser equalTo:[PFUser currentUser]];
    [queryFollowedEvents whereKeyExists:spadeActivityToEvent];
    //Run Query
    [queryFollowedEvents  findObjectsInBackgroundWithBlock:^(NSArray *followedEventsForUserFromParse, NSError *error){
        if (!error) {
            for(PFObject *object in followedEventsForUserFromParse){
                [[[SpadeCache sharedCache]followingEvents]addObject:[[object objectForKey:spadeActivityToEvent]objectId]];
            }
        }else{
            NSLog(@"App Delegate Set Query Error:%@",error);
            
        }
        
        NSLog(@"Event Cache %@",[[SpadeCache sharedCache]followingEvents]);

    }];

    
    
    
    
    
    
    
}





@end
