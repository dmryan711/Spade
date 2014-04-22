//
//  SpadeAppDelegate.m
//  Spade
//
//  Created by Devon Ryan on 11/22/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "SpadeAppDelegate.h"
#import "SpadeInviteCodeViewController.h"
#import "SpadeUtility.h"
#import "SpadeLoginViewController.h"
#import <Parse/Parse.h>
#import "SpadeFeedController.h"
#import "SpadeCache.h"
#import "SpadeEditProfileViewController.h"
#import "SpadeConstants.h"
#import "SpadeFriendTableViewController.h"
#import "UITabBar+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "SpadeContainerViewController.h"
#import "UserMenuTableViewController.h"
#import "MapAndCalendarViewController.h"
#import "SpadeMapSlideViewController.h"

#define LEFT_VIEWCONTROLLER 0
#define MIDDLE_VC 1
#define FEED_CONTROLLER 0
#define AMOUNT_OF_REFERALS 2
#define GOOGLE_API_KEY @"AIzaSyCR-VUyP05mZowGrUyzlD0qzVPOH2UbKaE"
#define STORYBOARD   [UIStoryboard storyboardWithName:@"Main" bundle: nil]

@interface SpadeAppDelegate ()

@property (strong,nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) SpadeContainerViewController *mainContainer;
@property (strong,nonatomic) SpadeFeedController *feedController;
@property (strong,nonatomic) NSMutableData *data;
@property (strong, nonatomic) NSCache *cache;


@end


@implementation SpadeAppDelegate

#pragma mark Application Delegate Methods
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //Bundle ID
    NSLog(@"Bundle ID: %@",[[NSBundle mainBundle] bundleIdentifier]);
    
    //Set User Defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{spadePicFLag:@NO, spadeNameFlag:@NO, isFirstLogin:@YES,areEnoughFriendsFollowed:@NO}];
    
    /***** INITIALIZE GOOGLE *****/
     [GMSServices provideAPIKey:GOOGLE_API_KEY];
                                                                 
    /*****   PARSE APPLICATION *******/
    [Parse setApplicationId:@"XQODiEaHhQUZWP8WdgcD6FAtQLP0XV33hrDtwgJD"
                  clientKey:@"MQI08xDJxyrt0ajlOW3pLaF3SHitkCQGusCsnLTt"];
    
    /***** PARSE ANALYTICS *****/
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    /***** INITIALIZE FACEBOOK *****/
    [PFFacebookUtils initializeFacebook];
    

    
    //Set Up the Container
    self.mainContainer = [STORYBOARD instantiateInitialViewController];
    
    //Load Main Set of View Controllers or Load Invite Controller into Tab Bar
    if ([[NSUserDefaults standardUserDefaults] boolForKey:isFirstLogin]){
        [self setInviteCodeController];
    }else{
        [self setMainControllers];
    }

    //Set Up App
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.mainContainer;
    [self.window makeKeyAndVisible];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    

    //Log Fonts
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
    
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

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    return [PFFacebookUtils handleOpenURL:url];
}

#pragma mark Tab Bar Controller Delegate Methods

-(void)tabBarController:(UITabBarController *)tabBarController
didSelectViewController:(UIViewController *)viewController
{
}

#pragma mark Login Delegate Methods
// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController
               didLogInUser:(PFUser *)user {

    //Get Rid of the Login View
    [[self.tabBarController.viewControllers objectAtIndex:LEFT_VIEWCONTROLLER] dismissViewControllerAnimated:YES completion:nil];
    
    //Set Facebook Request for user & friends
    FBRequest *requestForFriends = [FBRequest requestForMyFriends];
    FBRequest *request = [FBRequest requestForMe];
    
    //Request Friend Information
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
         //Request Failed
        } else if ([error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"type"] isEqualToString:@"OAuthException"]) {
            NSLog(@"The facebook session was invalidated");
            [self logOutUser];
            //Display Error
            
        } else {
            NSLog(@"Some other error: %@", error);
            [self logOutUser];
        }
    }];
    
    
    
    //Request User Information
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        if (!error) {
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
            
            //Create Referals if user is new
            if ([[NSUserDefaults standardUserDefaults] boolForKey:isFirstLogin]){
                
                //Create X Referrals for User
                    PFObject *referralForUser = [PFObject objectWithClassName:spadeInviteCodeClass];
                    [referralForUser setObject:[PFUser currentUser] forKey:belongsTo];
                    [referralForUser setObject:[NSNumber numberWithInt:AMOUNT_OF_REFERALS] forKey:totalUses];
                    [referralForUser setObject:[NSNumber numberWithInt:0] forKey:amountUsed];
                    [referralForUser saveEventually];
                [[NSUserDefaults standardUserDefaults]setBool:NO forKey:isFirstLogin];
            }
           
            
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
                 //USED WITH NAV STYLED  // [[[self.feedController viewControllers]objectAtIndex:FEED_CONTROLLER]runQueryAndReloadData];
                    [self.feedController runQueryAndReloadData];
                    
                   /* //Follow the Spade Team
                    PFQuery *querySpadeTeam = [PFQuery queryWithClassName:spadeClassUser];
                    [querySpadeTeam whereKey:spadeUserFacebookId containedIn:@[spadeDevonFacebookId]];
                    
                    [querySpadeTeam findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                        if (!error) {
                           
                            [SpadeUtility user:[PFUser currentUser] followingUsers:objects];
                        }
                    }];*/
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
- (void)logInViewController:(PFLogInViewController *)logInController
    didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"User dimissed the loginviewcontroller");
    [[self.tabBarController.viewControllers objectAtIndex:LEFT_VIEWCONTROLLER] dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark NSConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response {
    self.data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data {
    [self.data appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [SpadeUtility processProfilePictureData:self.data];
}


#pragma mark Present View Controllers
/**
 *  Presents the Login Controller
 */
-(void)presentLoginView
{
    SpadeLoginViewController *logInViewController = [[SpadeLoginViewController alloc] init];
    [logInViewController setDelegate:self]; // Set ourselves as the delegate
    [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"email",@"user_location",@"user_birthday", nil]];
    [logInViewController setFields:PFLogInFieldsFacebook];
    
    // Present the log in view controller
    [[self.tabBarController.viewControllers objectAtIndex:LEFT_VIEWCONTROLLER ] presentViewController:logInViewController animated:YES completion:NULL];
}

/**
 *  Present the Friend View Controller.
 *  This is used to ask the user to follow a certain amount of friends when they first join Spade
 */
-(void)presentFriendsViewController
{

    //Create Detail View
   // SpadeFriendTableViewController *friendListViewController = [STORYBOARD  instantiateViewControllerWithIdentifier:@"findFriendView"];
    
   // [[self.tabBarController.viewControllers objectAtIndex:LEFT_VIEWCONTROLLER] presentViewController:friendListViewController animated:YES completion:NULL];

}

#pragma mark Set Up View Controllers
/**
 *  Sets up the Invite Controller when a user is using the app for the first time.
 *
 */
-(void)setInviteCodeController
{
    [self.tabBarController setViewControllers:@[[STORYBOARD instantiateViewControllerWithIdentifier:@"InviteCode"]]];
    [self.tabBarController setSelectedIndex:MIDDLE_VC];
}

/**
 *  Set up the main app controllers.
 */
-(void)setMainControllers
{
    MapAndCalendarViewController *mapAndCalendar = [STORYBOARD instantiateViewControllerWithIdentifier:@"MapAndCalendar"];
    //SpadeMapSlideViewController *mapSlideViewController = [STORYBOARD instantiateViewControllerWithIdentifier: @"mapSlide"];
    //mapSlideViewController.centerViewController = [STORYBOARD instantiateViewControllerWithIdentifier:@"mapViewController"];

    
    self.mainContainer.isPullFromRightEnabled = YES;
    self.mainContainer.isPullFromLeftEnabled = YES;
    self.mainContainer.rightMenuTableViewController = [STORYBOARD instantiateViewControllerWithIdentifier:@"menuTable"];
    self.mainContainer.leftMenuTableViewController = [STORYBOARD instantiateViewControllerWithIdentifier:@"menuTable"];
    self.mainContainer.mainViewController = mapAndCalendar;
    
    
}

#pragma mark User Utility Methods
/**
 *  Logs out the current user, Presents Login Screen, and Kills the cache
 */
-(void)logOutUser{
    [PFUser logOut];
    [self presentLoginView];
    [[[SpadeCache sharedCache] cache] removeAllObjects];
}


-(void)setCacheForUser
{
    [self cacheForVenues];
    [self cacheForFollowers];
    [self cacheForAttendingEvents];
}

#pragma mark Helper Methods
-(void)cacheForVenues
{
    //Query for Followed Venues
    PFQuery *queryFollowedVenues = [PFQuery queryWithClassName:spadeClassActivity];
    queryFollowedVenues.cachePolicy = kPFCachePolicyNetworkOnly;
    [queryFollowedVenues whereKey:spadeActivityFromUser equalTo:[PFUser currentUser]];
    [queryFollowedVenues whereKeyExists:spadeActivityToVenue];
    
    //Run Query
    [queryFollowedVenues findObjectsInBackgroundWithBlock:^(NSArray *followedVenuesForUserFromParse, NSError *error){
        if (!error) {
            for(PFObject *object in followedVenuesForUserFromParse){
                [[SpadeCache sharedCache] addFollowedVenue:[object objectForKey:spadeActivityToVenue]];
            }
        }else{
            NSLog(@"App Delegate Set Query Error:%@",error);
        }
    }];
}

-(void)cacheForFollowers
{
    //Query for Followed Users
    PFQuery *queryFollowedUsers = [PFQuery queryWithClassName:spadeClassActivity];
    queryFollowedUsers.cachePolicy = kPFCachePolicyNetworkOnly;
    [queryFollowedUsers whereKey:spadeActivityFromUser equalTo:[PFUser currentUser]];
    [queryFollowedUsers whereKeyExists:spadeActivityToUser];
    //Run Query
    [queryFollowedUsers findObjectsInBackgroundWithBlock:^(NSArray *followedUsersForUserFromParse, NSError *error){
        if (!error) {
            for(PFUser *object in followedUsersForUserFromParse){
                [[SpadeCache sharedCache] addFollowedUser:[object objectForKey:spadeActivityToUser]];
            }
        }else{
            NSLog(@"App Delegate Set Query Error:%@",error);
        }
    }];
}

-(void)cacheForAttendingEvents
{
    //Query for Attending Events
    PFQuery *queryFollowedEvents = [PFQuery queryWithClassName:spadeClassActivity];
    queryFollowedEvents.cachePolicy = kPFCachePolicyNetworkOnly;
    [queryFollowedEvents whereKey:spadeActivityFromUser equalTo:[PFUser currentUser]];
    [queryFollowedEvents whereKeyExists:spadeActivityToEvent];
    //Run Query
    [queryFollowedEvents  findObjectsInBackgroundWithBlock:^(NSArray *followedEventsForUserFromParse, NSError *error){
        if (!error) {
            for(PFObject *object in followedEventsForUserFromParse){
                //NSLog(@"Attneding Event: %@",[object objectForKey:spadeActivityToEvent]);
                [[SpadeCache sharedCache] addAttendingEvent:[object objectForKey:spadeActivityToEvent]];
            }
        }else{
            NSLog(@"App Delegate Set Query Error:%@",error);
        }
    }];
}


@end
