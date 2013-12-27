//
//  SpadeFeedController.m
//  Spade
//
//  Created by Devon Ryan on 12/3/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import "SpadeFeedController.h"
#import "SpadeAppDelegate.h"
#import "SpadeLoginViewController.h"
#import "SpadeProfileController.h"
#import <Parse/Parse.h>
#import "SpadeConstants.h"
#import "SpadeFriendTableViewController.h"

@interface SpadeFeedController ()
@property (strong,nonatomic) NSArray *dataSet;

@end

@implementation SpadeFeedController

#define APPLICATION_DELEGATE (SpadeAppDelegate *)[[UIApplication sharedApplication] delegate]
#pragma mark Table View Controller Delegate Methods
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization

            }
    return self;
}

-(void)awakeFromNib
{
    NSLog(@"called");
    self.parseClassName = spadeClassActivity;
    self.textKey = @"objectId";
    self.pullToRefreshEnabled = YES;
    self.paginationEnabled = NO;
    //self.objectsPerPage = 3;
}

- (void)viewDidLoad
{
    NSLog(@"View Did Load");
    [super viewDidLoad];
   
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.title = @"Night Feed";
    if (![PFUser currentUser] ) { // No user logged in
        // Create the log in view controller
        [APPLICATION_DELEGATE presentLoginView];
    }else if ([[NSUserDefaults standardUserDefaults]boolForKey:spadeFirstLoginFlag]) {
        
        NSLog(@"First TIME");
        //[[NSUserDefaults standardUserDefaults]setBool:NO forKey:spadeFirstLoginFlag];
        // Present Friend List
        
        
        [self performSelector:@selector(loadFriendsView) withObject:nil afterDelay:.5];
        
    
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

#pragma mark - Parse

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}


// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query includeKey:spadeActivityFromUser];
    [query includeKey:spadeActivityToVenue];
    [query includeKey:spadeActivityToUser];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByDescending:@"createdAt"];
    
    return query;
}



// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    
    
    PFUser *user = [object objectForKey:spadeActivityFromUser];
    NSString *action = [object objectForKey:spadeActivityAction];
    NSString *userName = [user objectForKey:spadeUserDisplayName];
    cell.textLabel.text = action;
   
    if ([action isEqualToString:spadeActivityActionFollowingVenue]) {
        
        PFObject *venue = [object objectForKey:spadeActivityToVenue];
        NSString *venueName = [venue objectForKey:spadeVenueName];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ is following %@ ", userName , venueName];
    }else if ([action isEqualToString:spadeActivityActionFollowingUser]){
        PFUser *toUser = [object objectForKey:spadeActivityToUser];
        NSString *toUserName = [toUser objectForKey:spadeUserDisplayName];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ is now following %@ ", userName , toUserName];
    
    }
    
    
    return cell;
}


#pragma mark Actionsheet Delegate Methods
#define LOGOUT_BUTTON 0
#define PROFILE_BUTTON 1
#define FIND_FRIEND 2
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == LOGOUT_BUTTON) {
        [self logOutPressed];
        
    }else if (buttonIndex == PROFILE_BUTTON){
        [self segueToProfileView];
    
    
    }else if (buttonIndex == FIND_FRIEND){
        [self performSegueWithIdentifier:@"moveToFindFriends" sender:self];
    
    }

}

-(void)segueToProfileView
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    //Create Detail View
    SpadeProfileController *profileDetail = [mainStoryboard   instantiateViewControllerWithIdentifier:@"profileDetailView"];
    PFUser *user = [PFUser currentUser];
    
    [profileDetail setUserName:[user objectForKey:spadeUserDisplayName]];
    
    [self.navigationController pushViewController:profileDetail animated:YES];

}


#pragma mark { }
-(void)logOutPressed
{
    
    [APPLICATION_DELEGATE logOutUser];
    
}

-(void)settingsPressed{
    
    //UIImageView *image =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"skyline_7.png"]];
    
    UIActionSheet *settingsPressed = [[UIActionSheet alloc]initWithTitle:@"Settings" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Log Out" otherButtonTitles:@"Profile",@"Find Friends", nil];

    [settingsPressed showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

-(void)loadFriendsView
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    //Create Detail View
    SpadeFriendTableViewController *friendListViewController = [mainStoryboard   instantiateViewControllerWithIdentifier:@"findFriendView"];
    
    UINavigationController *tempNav = [[UINavigationController alloc]initWithRootViewController:friendListViewController];
    [self presentViewController:tempNav animated:YES completion:nil];
    
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
