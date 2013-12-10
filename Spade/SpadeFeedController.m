//
//  SpadeFeedController.m
//  Spade
//
//  Created by Devon Ryan on 12/3/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import "SpadeFeedController.h"
#import "SpadeLoginViewController.h"
#import "SpadeBirthday.h"
#import <Parse/Parse.h>

@interface SpadeFeedController ()
@property (strong,nonatomic) NSArray *dataSet;

@end

@implementation SpadeFeedController


#pragma mark Table View Controller Delegate Methods
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization

            }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"View Did Load");
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.title = @"What's Good";
    if (![PFUser currentUser] ) { // No user logged in
        // Create the log in view controller
        [self presentLoginView];
    }


    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(settingsPressed)];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray *)dataSet{
    if (!_dataSet) _dataSet = @[@"Hudson",@"Griffen",@"Rosewood"];
    return _dataSet;

}

-(void)settingsPressed{
    UIActionSheet *settingsPressed = [[UIActionSheet alloc]initWithTitle:@"Settings" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Log Out" otherButtonTitles:@"Profile",@"Find Friends", nil];
    
    [settingsPressed showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataSet count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [self.dataSet objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark Actionsheet Delegate Methods
#define LOGOUT_BUTTON 0
#define PROFILE_BUTTON 1
#define FIND_FRIEND 2
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == LOGOUT_BUTTON) {
        [PFUser logOut];
        [self presentLoginView];
        
    }else if (buttonIndex == PROFILE_BUTTON){
        [self performSegueWithIdentifier:@"moveToProfile" sender:self];
    
    
    }else if (buttonIndex == FIND_FRIEND){
        [self performSegueWithIdentifier:@"moveToFindFriends" sender:self];
    
    }

}

#pragma mark Spade Login Delegate Methods
// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
            NSString *fullName = [userData objectForKey:@"name"];
            
            //Derive Age from Birthday
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"MM/dd/yyyy"];
            [dateFormat dateFromString:birthday];
            NSNumber *age = [NSNumber numberWithInteger:[SpadeBirthday age:[dateFormat dateFromString:birthday]]];
            
            //Save local facebook result to Parse
            [user setObject:email forKey:@"email"];
            [user setObject:gender forKey:@"Gender"];
            [user setObject:locale forKey:@"Locale"];
            [user setObject:birthday forKey:@"Birthday"];
            [user setObject:fullName forKey:@"DisplayName"];
            [user setObject:age forKey:@"age"];
            
            //Save to Parse
            [user saveInBackground];
            
            //Push User to Main Path
            [self performSegueWithIdentifier:@"moveToMain" sender:self];
            
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
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark {   }
-(void)presentLoginView
{
    
    SpadeLoginViewController *logInViewController = [[SpadeLoginViewController alloc] init];
    [logInViewController setDelegate:self]; // Set ourselves as the delegate
    [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"email",@"user_location",@"user_birthday", nil]];
    [logInViewController setFields:PFLogInFieldsFacebook];
    
    
    // Present the log in view controller
    [self presentViewController:logInViewController animated:YES completion:NULL];
}

-(void)logOutUser{
    [PFUser logOut];
    
    [self presentLoginView];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
