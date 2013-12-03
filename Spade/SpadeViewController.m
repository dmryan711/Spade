//
//  SpadeViewController.m
//  Spade
//
//  Created by Devon Ryan on 11/22/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import <Parse/Parse.h>
#import "SpadeViewController.h"
#import "SpadeBirthday.h"
#import "SpadeAppDelegate.h"

@interface SpadeViewController ()

@end

@implementation SpadeViewController


#pragma mark Life View Life Cycle

-(void)viewWillAppear:(BOOL)animated
{

    

    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
   
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![PFUser currentUser] ) { // No user logged in
        // Create the log in view controller
        [self presentLoginView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark PFLoginViewController Delegate Methods

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    FBRequest *request = [FBRequest requestForMe];
    
    //FB Request Troubleshooting
    [FBSettings setLoggingBehavior:[NSSet setWithObjects:
                                    FBLoggingBehaviorFBRequests, nil]];
    //Send Request
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){
        if (!error) {
            
            
            
            //Store Facebook Results to local objects
            NSDictionary *userData = (NSDictionary *)result;
            NSLog(@"%@",userData.description);
            NSString *email = [userData objectForKey:@"email"];
            NSString *gender = [userData objectForKey:@"gender"];
            NSString  *locale = [userData objectForKey:@"locale"];
            NSString *birthday = [userData objectForKey:@"birthday"];
            NSString *firstName = [userData objectForKey:@"first_name"];
            NSString *lastName = [userData objectForKey:@"last_name"];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            
            //Derive Age from Birthday
            [dateFormat setDateFormat:@"MM/dd/yyyy"];
            [dateFormat dateFromString:birthday];
            NSNumber *age = [NSNumber numberWithInteger:[SpadeBirthday age:[dateFormat dateFromString:birthday]]];
            
            //Save local facebook result to Parse
            [user setObject:email forKey:@"email"];
            [user setObject:gender forKey:@"Gender"];
            [user setObject:locale forKey:@"Locale"];
            [user setObject:birthday forKey:@"Birthday"];
            [user setObject:firstName forKey:@"First_Name"];
            [user setObject:lastName forKey:@"Last_Name"];
            [user setObject:age forKey:@"age"];
            
            

            //Save to Parse
            [user saveInBackground];
            
        } else if ([error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"type"] isEqualToString:@"OAuthException"]) {//Request Failed , Checking Why
            NSLog(@"The facebook session was invalidated");
            [self logOutUser];
            
        } else {
            NSLog(@"Some other error: %@", error);
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
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UI Methods
- (IBAction)logOutPressed:(id)sender {
    
    UIActionSheet *confirmLogOut = [[UIActionSheet alloc]initWithTitle:@"Confrim Log Out?" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:@"Yes" otherButtonTitles:nil];
    [confirmLogOut showInView:self.view];

}

-(void)logOutUser{
    [PFUser logOut];
    
    [self presentLoginView];

}

-(void)presentLoginView
{

    SpadeLoginViewController *logInViewController = [[SpadeLoginViewController alloc] init];
    [logInViewController setDelegate:self]; // Set ourselves as the delegate
    [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"email",@"user_location",@"user_birthday", nil]];
    [logInViewController setFields:PFLogInFieldsFacebook];
    
    
    // Present the log in view controller
    [self presentViewController:logInViewController animated:YES completion:NULL];
}


#pragma mark ActionSheet Delegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
   
    
    if (buttonIndex == 0) {
       
        [self logOutUser];
    }
}




@end
