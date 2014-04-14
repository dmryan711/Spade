//
//  SpadeFeedController.m
//  Spade
//
//  Created by Devon Ryan on 12/3/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//
#import "SpadeEventCreationViewController.h"
#import "SpadeFeedController.h"
#import "SpadeFeedCell.h"
#import "SpadeAppDelegate.h"
#import "SpadeLoginViewController.h"
#import "SpadeProfileController.h"
#import <Parse/Parse.h>
#import "SpadeConstants.h"
#import "SpadeFriendTableViewController.h"
#import "SpadeCache.h"
#import "SpadeEventDetailViewController.h"
#import "UINavigationBar+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"
#import "SpadeMainSlideViewController.h"

@interface SpadeFeedController ()
@property (strong,nonatomic) NSMutableArray *objects;
@property (strong, nonatomic) PFQuery *query;
@property (strong, nonatomic) UIRefreshControl *tableRefresh;

@end

@implementation SpadeFeedController

#define APPLICATION_DELEGATE (SpadeAppDelegate *)[[UIApplication sharedApplication] delegate]
#define TITLE_FONT_SIZE 12
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
    
    self.query =  [PFQuery queryWithClassName:spadeClassActivity];
    //self.parseClassName = spadeClassActivity;
    //self.textKey = @"objectId";
    //self.pullToRefreshEnabled = YES;
    //self.paginationEnabled = NO;
    //self.objectsPerPage = 3;

        

}

- (void)viewDidLoad
{
    

    [super viewDidLoad];
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"spade_6.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor blendedColorWithForegroundColor:[UIColor blackColor] backgroundColor:[UIColor wisteriaColor] percentBlend:.6];
    
    //self.navigationController.navigationBar.backgroundColor = [UIColor wisteriaColor];

   // [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
   /* NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor wisteriaColor],NSBackgroundColorAttributeName,[UIFont fontWithName:@"Lato-Black" size:22],NSFontAttributeName, nil];
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;*/
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"☰" style:UIBarButtonItemStyleBordered target:self action:@selector(settingsPressed)];
    
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor cloudsColor];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Copperplate-Bold" size:24]} forState:UIControlStateNormal];
    
   /* [self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor blendedColorWithForegroundColor:[UIColor blackColor] backgroundColor:[UIColor wisteriaColor] percentBlend:.6]];*/
    
    //[[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    if (![PFUser currentUser] ) { // No user logged in
        // Create the log in view controller
        [APPLICATION_DELEGATE presentLoginView];
    }else if (![[NSUserDefaults standardUserDefaults]boolForKey:areEnoughFriendsFollowed]) {
        
        //[[NSUserDefaults standardUserDefaults] forKey:spadeFirstLoginFlag];
        // Present Friend List
        
        
        [self performSelector:@selector(loadFriendsView) withObject:nil afterDelay:.5];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        

    }
    
    //Set Query and Run
    self.query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [self.query includeKey:spadeActivityFromUser];
    [self.query includeKey:spadeActivityToEvent];
    [self.query includeKey:spadeActivityForVenue];
    //[self.query includeKey:spadeEventVenue];
    [self.query includeKey:spadeVenueName];
    [self.query includeKey:spadeVenuePicture];
    [self.query orderByDescending:@"createdAt"];
    
    if ([PFUser currentUser]) {
    
        [self runQueryAndReloadData];
    }
    
    //Add Refresh Control
    self.tableRefresh = [[UIRefreshControl alloc]init];
    [self.tableRefresh addTarget:self action:@selector(runQueryAndReloadData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.tableRefresh];
    
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dark_exa.png"]];
    
   
}


-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    return 1;

   
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if ([self.objects count] == 0) {
        return 0;
    }else{
    
        return ([self.objects count] *2)-1;
    }


}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 1)
        return 40;
    return 169;
}

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    
    if (indexPath.row % 2 == 1) {
        //Even
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            
        }
        
        [cell.contentView setAlpha:0];
        cell.backgroundColor = [UIColor clearColor];
        [cell setUserInteractionEnabled:NO];
        
        return cell;
        
    }else{
        static NSString *FeedCellIdentifier = @"spadeFeedCell";
        
         SpadeFeedCell *feedCell = [tableView dequeueReusableCellWithIdentifier:FeedCellIdentifier];
        if (feedCell == nil) {
            feedCell = [[SpadeFeedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:FeedCellIdentifier];
        }
        
        // Configure the cell

        feedCell.backgroundColor = [UIColor cloudsColor];
        feedCell.actionLabel.font = [UIFont fontWithName:@"Lato-Regular" size:10];
        feedCell.userNameLabel.font  = [UIFont fontWithName:@"Lato-Black" size:10];
        feedCell.venueNameLabel.font  = [UIFont fontWithName:@"Lato-Black" size:10];
        
        [feedCell.layer setShadowOffset:CGSizeMake(-5, 5)];
        [feedCell.layer setShadowColor:[UIColor blueColor].CGColor];
        [feedCell.layer setShadowOpacity:0.8];
        
        NSUInteger newIndex = (indexPath.row /2);
        
        
        PFUser *user = [[self.objects objectAtIndex:newIndex] objectForKey:spadeActivityFromUser];
        PFObject *event = [[self.objects objectAtIndex:newIndex]objectForKey:spadeActivityToEvent];
        PFObject *venue = [[self.objects objectAtIndex:newIndex]objectForKey:spadeActivityForVenue];
        NSString *action = [[self.objects objectAtIndex:newIndex] objectForKey:spadeActivityAction];
        
        //PFObject *event = [object objectForKey:spadeActivityToEvent];
        //NSString *eventName = [event objectForKey:spadeEventName];
        
        if([user objectForKey:spadeUserSmallProfilePic]){
            [feedCell.userImageView setFile:[user objectForKey:spadeUserSmallProfilePic]];
            [feedCell.userImageView loadInBackground];
        }else{
            feedCell.userImageView.image = [UIImage imageNamed:@"spade.png"];
        }
        if ([event objectForKey:spadeEventImageFile]) {
            [feedCell.eventImageView setFile:[event objectForKey:spadeEventImageFile]];
            [feedCell.eventImageView loadInBackground];
        }
        else{
            feedCell.eventImageView.image = [UIImage imageNamed:@"spade.png"];
            
        }
    
        
        if ([action isEqualToString:spadeActivityActionAttendingEvent]) {
            if ([[self.objects objectAtIndex:newIndex]objectForKey:@"otherUserCount"]) {
                NSNumber *otherCount = [[self.objects objectAtIndex:newIndex]objectForKey:@"otherUserCount"];
                if ([otherCount isEqualToNumber:[NSNumber numberWithInt:1]]) {
                    feedCell.actionLabel.text = [NSString stringWithFormat:@"and %@ other friend\n\n is attending\n\n%@",otherCount,[event objectForKey:spadeEventName]];
                }else{
                    feedCell.actionLabel.text = [NSString stringWithFormat:@"and %@ other friends\n are attending\n%@", otherCount,[event objectForKey:spadeEventName]];
                }
            }else{
                feedCell.actionLabel.text = [NSString stringWithFormat:@"☰  is attending\n\n%@",[event objectForKey:spadeEventName]];
            }
            
            
            
        }else if ([action isEqualToString:spadeActivityActionCreatedEvent]){
           // feedCell.actionLabel.text = @"Created";
            feedCell.actionLabel.text = [NSString stringWithFormat:@"created the event\n\n%@",[event objectForKey:spadeEventName]] ;
            
        }
    
        feedCell.userNameLabel.text = [user objectForKey:spadeUserDisplayName];
        feedCell.venueNameLabel.text = [venue objectForKey:spadeVenueName];
        
        return feedCell;

    }
   
}


#pragma mark Actionsheet Delegate Methods
#define LOGOUT_BUTTON 0
#define PROFILE_BUTTON 1
#define FIND_FRIEND 2
//#define BETA 3
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == LOGOUT_BUTTON) {
        [self logOutPressed];
        
    }else if (buttonIndex == PROFILE_BUTTON){
        [self segueToProfileView];
    
    
    }else if (buttonIndex == FIND_FRIEND){
        [self segueToFriendView];
    
   /* }else if (buttonIndex == BETA){
        [self segueToBeta];*/
    
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

-(void)segueToFriendView
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    //Create Detail View
    SpadeFriendTableViewController *friendTableViewController = [mainStoryboard   instantiateViewControllerWithIdentifier:@"findFriendView"];
    
    [self.navigationController pushViewController:friendTableViewController animated:YES];
    
}

/*-(void)segueToBeta
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    //Create Detail View
    SpadeEventCreationViewController *beta = [mainStoryboard   instantiateViewControllerWithIdentifier:@"beta"];
    
    [self.navigationController pushViewController:beta animated:YES];
    
}*/


#pragma mark { }

-(void)runQueryAndReloadData
{
    PFQuery *myfriends = [PFQuery queryWithClassName:spadeClassUser];
    [myfriends whereKey:spadeUserFacebookId containedIn:[[PFUser currentUser]objectForKey:spadeUserFriends]];
    myfriends.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [self.query whereKey:spadeActivityFromUser matchesQuery:myfriends];
    
    if (!_objects) _objects = [[NSMutableArray alloc]init];
    
    [self.query findObjectsInBackgroundWithBlock:^(NSArray *objectsFound, NSError *error){
        if (!error) {
            [self.objects removeAllObjects];
            
            [self.objects addObjectsFromArray:[self crunchUpdates:(NSMutableArray *)objectsFound]];
            [self.tableView reloadData];
            [self.tableRefresh endRefreshing];
            
           // NSLog(@"Objects Uncrunched Here     %@",objectsFound);

            
           // NSLog(@"Objects Here     %@",self.objects);

            
        }
        
    }];

}

-(NSArray *)crunchUpdates:(NSMutableArray *)objectsFoundInQuery{
	NSMutableArray *crunchedActivities = [[NSMutableArray alloc]init];
	NSMutableDictionary *crunchedObject = [[NSMutableDictionary alloc]init];
	for(int i = 0; i< [objectsFoundInQuery count]; i++){
        if ([[[objectsFoundInQuery objectAtIndex:i]objectForKey:spadeActivityAction] isEqualToString:spadeActivityActionAttendingEvent]) {
            int crunches = 0;
            for(int j = i +1; j < [objectsFoundInQuery count]; j++){
                if ([[[objectsFoundInQuery objectAtIndex:j]objectForKey:spadeActivityAction] isEqualToString:spadeActivityActionAttendingEvent]){
                
                    if([[[[objectsFoundInQuery objectAtIndex:i] objectForKey:spadeActivityToEvent]objectId] isEqualToString:[[[objectsFoundInQuery objectAtIndex:j] objectForKey:spadeActivityToEvent]objectId]]	){//Match Found. crunch
                        if(crunches == 0){ //first Crunch
                            [crunchedObject addEntriesFromDictionary: @{spadeActivityFromUser:[[objectsFoundInQuery objectAtIndex:i]objectForKey:spadeActivityFromUser],spadeActivityAction: spadeActivityActionAttendingEvent, spadeActivityToEvent:[[objectsFoundInQuery objectAtIndex:i] objectForKey:spadeActivityToEvent]}];
                        }
                        crunches ++;
                        NSNumber *crunchesNumber = [NSNumber numberWithInt:crunches];
                        [crunchedObject addEntriesFromDictionary:@{@"otherUserCount":crunchesNumber}]; //add key and incremented other count
                    
                        //Removing Compared Object
                        [objectsFoundInQuery removeObjectAtIndex: j];
                        j--;
                        
                    }
                }
            }
            
            if(crunches == 0){ //No Crunches Made
                [crunchedActivities addObject:[objectsFoundInQuery objectAtIndex:i]];
                
            }else{ //crunches found
                NSDictionary *tempDict = [NSDictionary dictionaryWithDictionary:crunchedObject];
                [crunchedActivities addObject:tempDict];
                [crunchedObject removeAllObjects]; //reset the object
 
                
                //Removing Comparing Object
                [objectsFoundInQuery removeObjectAtIndex:i];
                i--;
            }
        }else{
            [crunchedActivities addObject:[objectsFoundInQuery objectAtIndex:i]]; // if it is the "Created" Action
        }
    }
    return crunchedActivities;
}

-(void)logOutPressed
{
    
    [APPLICATION_DELEGATE logOutUser];
    
}

-(void)settingsPressed{
    
    
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger newIndex = (indexPath.row /2);
    
    PFObject *eventActivity = [self.objects objectAtIndex:newIndex];
    
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    //Create Detail View
   /* SpadeEventDetailViewController *eventDetailViewController = [mainStoryboard   instantiateViewControllerWithIdentifier:@"eventDetailController"];*/
    
   // eventDetailViewController.object = eventActivity;
    
    SpadeMainSlideViewController *main = [mainStoryboard   instantiateViewControllerWithIdentifier:@"mainSlide"];
    NSLog(@"ACTIVITY FEED:%@",eventActivity);
 
    
    main.object = eventActivity;
    
    [self.navigationController pushViewController:main animated:YES];

    


}
@end
