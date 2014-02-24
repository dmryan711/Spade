//
//  SpadeFriendTableViewController.m
//  Spade
//
//  Created by Devon Ryan on 12/25/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import "SpadeFriendTableViewController.h"
#import "SpadeFriendDetailViewController.h"
#import "SpadeUtility.h"
#import "SpadeConstants.h"
#import "SpadeCache.h"
#import "SpadeFeedController.h"

@interface SpadeFriendTableViewController ()


@property (strong, nonatomic)NSMutableArray *usersFollowed;
@end

@implementation SpadeFriendTableViewController

#define MIN_FOLLOWER 4
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)awakeFromNib
{
    self.parseClassName = spadeClassUser;
    self.textKey = @"Name";
    self.pullToRefreshEnabled = YES;
    self.paginationEnabled = NO;
    //self.objectsPerPage = 3;
    
    
    
    
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title =  @"Friends";
    
    /*self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Follow All" style:UIBarButtonItemStylePlain target:self action:@selector(followAllSelected)];*/
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneSelected)];
    
    
    if ([[[[[SpadeCache sharedCache]cache]objectForKey:spadeCache]objectForKey:spadeCacheUser]count] < MIN_FOLLOWER) {
        [self createAndDisplayFollowerAlert];
    
    }
    
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
    [query whereKey:spadeUserFacebookId containedIn:[[PFUser currentUser]objectForKey:spadeUserFriends]]; //Facebook ID is in friends array
    [query whereKey:spadeUserFacebookId notEqualTo:[[PFUser currentUser]objectForKey:spadeUserFacebookId]]; //Facebook ID is not user
    

    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    //}
    
    [query orderByAscending:spadeUserDisplayName];

    
    return query;
}



// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (SpadeFollowCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"FriendCell";
    
   SpadeFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SpadeFollowCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.delegate = self;
   // cell.userObject = (PFUser *)object;
    cell.object = object;
    
    
    
    if ([[[[[SpadeCache sharedCache]cache]objectForKey:spadeCache]objectForKey:spadeCacheUser] containsObject:(PFUser *)object]) {
        [cell.followButton setTitle:spadeFollowButtonTitleUnfollow forState:UIControlStateNormal];
    }else{
        [cell.followButton setTitle:spadeFollowButtonTitleFollow forState:UIControlStateNormal];
    }
    // Configure the cell
    cell.nameLabel.text = [object objectForKey:spadeUserDisplayName];
    
    if ([object objectForKey:spadeUserSmallProfilePic]) {
        [cell.profileImageView setFile:[object objectForKey:spadeUserSmallProfilePic]];
        [cell.profileImageView loadInBackground];
    }else{
        cell.profileImageView.image = [UIImage imageNamed:@"AvatarPlaceHolder.png"];
    }
    
    
    return cell;
}


/*
 // Override if you need to change the ordering of objects in the table.
 - (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
 return [objects objectAtIndex:indexPath.row];
 }
 */

/*
 // Override to customize the look of the cell that allows the user to load the next page of objects.
 // The default implementation is a UITableViewCellStyleDefault cell with simple labels.
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
 static NSString *CellIdentifier = @"NextPage";
 
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
 if (cell == nil) {
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
 }
 
 cell.selectionStyle = UITableViewCellSelectionStyleNone;
 cell.textLabel.text = @"Load more...";
 
 return cell;
 }
 */

#pragma mark - Table view data source

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
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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


#pragma mark - Table view delegate

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

/*- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (indexPath.row < [self.objects count]) {
        
        //Set Selection Object
        PFUser *userSelection = [self.objects objectAtIndex:indexPath.row];
        
        //Create Detail View
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        //Create Detail View
        SpadeFriendDetailViewController *friendDetail = [mainStoryboard   instantiateViewControllerWithIdentifier:@"friendDetailController"];
        
        [friendDetail setFriend:userSelection];
        
        [self.navigationController pushViewController:friendDetail animated:YES];
        
        
    }
}*/


#pragma mark Navigation Button Methods

-(void)doneSelected
{
    
    if ([[[[[SpadeCache  sharedCache]cache]objectForKey:spadeCache]objectForKey:spadeCacheUser]count]  >= MIN_FOLLOWER) {
        //Unset Login Flag
        if ([[NSUserDefaults standardUserDefaults]boolForKey:spadeFirstLoginFlag]) {
            //[[NSUserDefaults standardUserDefaults]setBool:NO forKey:spadeFirstLoginFlag];
        }
        
        if ([self.navigationController.viewControllers objectAtIndex:0] == self){
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }else{
            
            [self.navigationController popViewControllerAnimated:YES];
        
        }
        
        
    }else{
        [self createAndDisplayNotEnoughFollowerAlert];
    }
    
    

}



/*-(void)followAllSelected
{
    
    [self createAndDisplayConfirmFollowAllAlert];


}*/



#pragma mark Create Alert Methods
-(void)createAndDisplayFollowerAlert
{
    UIAlertView *followerAlert = [[UIAlertView alloc]initWithTitle:@"Start Following!" message:[NSString stringWithFormat:@"Welcome to Spade! \n Start your Spade Experience by following at least %i friends.",MIN_FOLLOWER] delegate:self cancelButtonTitle:@"Sounds Good" otherButtonTitles:nil];
    
    [followerAlert show];

}

/*-(void)createAndDisplayConfirmFollowAllAlert
{
    UIAlertView *followerAllAlert = [[UIAlertView alloc]initWithTitle:spadeAlertViewTitleConfirmFollower message:[NSString stringWithFormat:@"Are you sure you would like to follow these %i friends",(int)self.objects.count] delegate:self cancelButtonTitle:@"Sounds Good" otherButtonTitles:@"No Way",nil];
    
    [followerAllAlert show];

}*/

-(void)createAndDisplayNotEnoughFollowerAlert
{
    
    int remainingLeftToFollow =  MIN_FOLLOWER - (int)[[[[[SpadeCache sharedCache]cache]objectForKey:spadeCache]objectForKey:spadeCacheUser]count] ;
    UIAlertView *followerAlert = [[UIAlertView alloc]initWithTitle:@"Almost There!" message:[NSString stringWithFormat:@"Please select %i more friends to follow",remainingLeftToFollow] delegate:self cancelButtonTitle:@"Sounds Good" otherButtonTitles:nil];
    
    [followerAlert show];

}

#pragma mark AlertView Delegate Method
#define ALERT_CANCEL_BUTTON 0
/*- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:spadeAlertViewTitleConfirmFollower]) {
        if (buttonIndex == ALERT_CANCEL_BUTTON) {
            //Update Cache
            for (PFObject *object in self.objects)
            {
            
                [[[SpadeCache sharedCache]followingUsers] addObject:object.objectId];
            }
            
            
             NSLog(@"User Cache: %@",[[SpadeCache sharedCache]followingUsers]);
            //Push to Parse
            [SpadeUtility user:[PFUser currentUser] followingUsers:self.objects];
        }
    }

}*/


#pragma mark SpadeFollowCell Delegate Methods
-(void)followButtonWasPressedForCell:(SpadeFollowCell *)cell
{
    if ([cell.followButton.titleLabel.text isEqualToString:spadeFollowButtonTitleFollow]) {
        [cell.followButton setTitle:spadeFollowButtonTitleUnfollow forState:UIControlStateNormal];
        //set cache to follow user
        [[SpadeCache sharedCache]addFollowedUser:(PFUser *)cell.object];

        
    }else if ([cell.followButton.titleLabel.text isEqualToString:spadeFollowButtonTitleUnfollow]){
        [cell.followButton setTitle:spadeFollowButtonTitleFollow forState:UIControlStateNormal];
        
        //set cache to remove user from follow list
        [[SpadeCache sharedCache]removeFollowedUser:cell.object];
    
    }else{
        NSError *error = [NSError errorWithDomain:@"Cell Title Not Matching Follow/UNfollow" code:1 userInfo:@{@"Title": [NSString stringWithFormat:@"Button Title: %@", cell.nameLabel.text ]}];
        
        NSLog(@"Error: %@",error.description);
    }

   

}





@end
