//
//  SlideFeedViewController.m
//  Spade
//
//  Created by Devon Ryan on 4/22/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "SlideFeedViewController.h"
#import "UIColor+FlatUI.h"
#import <Parse/Parse.h>
#import "SpadeAppDelegate.h"
#import "SpadeConstants.h"
#import "SpadeFriendTableViewController.h"
#import "SpadeUtility.h"
#import "SpadeSlideCell.h"

#define APPLICATION_DELEGATE (SpadeAppDelegate *)[[UIApplication sharedApplication] delegate]
@interface SlideFeedViewController ()<UIActionSheetDelegate>

@property (strong, nonatomic) UIRefreshControl  *eventRefresh;
@property (strong, nonatomic) PFQuery *eventQuery;
@property (strong, nonatomic) NSMutableArray *events;

@end

@implementation SlideFeedViewController

static NSString *SpadeSlideCellIdentifier = @"SpadeSlidingCellIdentifier";


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.collectionView registerClass:[SpadeSlideCell class] forCellWithReuseIdentifier:SpadeSlideCellIdentifier];
    
    //Set Up Navigation Controller
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"spade_6.png"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor blendedColorWithForegroundColor:[UIColor blackColor] backgroundColor:[UIColor wisteriaColor] percentBlend:.6];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"☰" style:UIBarButtonItemStyleBordered target:self action:@selector(showSettingsMenu)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor cloudsColor];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Copperplate-Bold" size:24]} forState:UIControlStateNormal];
    
    //Check for User State, show Login Controller if no user
    if (![PFUser currentUser] ) {
        // Create the log in view controller
        [APPLICATION_DELEGATE presentLoginView];
    }
    
    
    //******************* REMOVED FOR TESTING ************
    /*//Check if user is following enough friends, if not show friends list
    if (![[NSUserDefaults standardUserDefaults]boolForKey:areEnoughFriendsFollowed]){
        [self performSelector:@selector(showFriends) withObject:nil afterDelay:.5];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }*/

    //Add Refresh Control
    self.eventRefresh = [[UIRefreshControl alloc]init];
    [self.eventRefresh addTarget:self action:@selector(runEventQuery) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.eventRefresh];
    
    //Set Up Query
    self.eventQuery =  [PFQuery queryWithClassName:spadeClassActivity];
    self.eventQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [self.eventQuery includeKey:spadeActivityFromUser];
    [self.eventQuery includeKey:spadeActivityToEvent];
    [self.eventQuery includeKey:spadeActivityForVenue];
    [self.eventQuery includeKey:spadeVenueName];
    [self.eventQuery includeKey:spadeVenuePicture];
    [self.eventQuery whereKey:spadeActivityAction equalTo:spadeActivityActionCreatedEvent];
    [self.eventQuery orderByDescending:@"createdAt"];
    
    //Run the Query if there is a user
    if ([PFUser currentUser]) {
        [self runEventQuery];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Custom Methods

-(void)showSettingsMenu{
    
    
    UIActionSheet *settingsPressed = [[UIActionSheet alloc]initWithTitle:@"Settings" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Log Out" otherButtonTitles:@"Profile",@"Find Friends", nil];
    
    [settingsPressed showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

-(void)showFriends
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    //Create Detail View
    SpadeFriendTableViewController *friendListViewController = [mainStoryboard   instantiateViewControllerWithIdentifier:@"findFriendView"];
    
    UINavigationController *tempNav = [[UINavigationController alloc]initWithRootViewController:friendListViewController];
    
    [self presentViewController:tempNav animated:YES completion:nil];
    
}

-(void)runEventQuery
{
    PFQuery *myfriends = [PFQuery queryWithClassName:spadeClassUser];
    [myfriends whereKey:spadeUserFacebookId containedIn:[[PFUser currentUser]objectForKey:spadeUserFriends]];
    myfriends.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [self.eventQuery whereKey:spadeActivityFromUser matchesQuery:myfriends];
    
    if (!_events) _events = [[NSMutableArray alloc]init];
    
    [self.eventQuery findObjectsInBackgroundWithBlock:^(NSArray *objectsFound, NSError *error){
        if (!error) {
            [self.events removeAllObjects];
            
            [self.events addObjectsFromArray:[SpadeUtility crunchUpdates:(NSMutableArray *)objectsFound]];
            [self.collectionView reloadData];
            [self.eventRefresh endRefreshing];
            
            NSLog(@"Objects Uncrunched Here     %@",objectsFound);
            NSLog(@"Objects Here     %@",self.events);
        }
    }];

}

#pragma mark Slide Menu Data Source Methods
- (NSInteger)numberOfItemsInSlidingMenu {
    return [self.events count]; 
}

- (void)customizeCell:(SpadeSlideCell *)slidingMenuCell forRow:(NSInteger)row {

    PFUser *user = [[self.events objectAtIndex:row] objectForKey:spadeActivityFromUser];
    PFObject *event = [[self.events objectAtIndex:row]objectForKey:spadeActivityToEvent];
    PFObject *venue = [[self.events objectAtIndex:row]objectForKey:spadeActivityForVenue];
    NSLog(@"%@",venue.description);
    //NSString *action = [[self.events objectAtIndex:row] objectForKey:spadeActivityAction];
    
    
    slidingMenuCell.textLabel.text = [event objectForKey:spadeEventName];

    
    if ([venue objectForKey:spadeVenuePicture]) {
       slidingMenuCell.backgroundImageView.file = [venue objectForKey:spadeVenuePicture];
        [slidingMenuCell.backgroundImageView loadInBackground];
    }else{
        slidingMenuCell.backgroundImageView.image = [UIImage imageNamed:@"argyle.png"];
    }
    
    if ([user objectForKey:spadeUserSmallProfilePic]) {
        slidingMenuCell.userImage.file  = [user objectForKey:spadeUserSmallProfilePic];
        [slidingMenuCell.userImage loadInBackground];
    }else{
        slidingMenuCell.userImage.backgroundColor = [UIColor clearColor];
    }
    
   slidingMenuCell.detailTextLabel.text = [SpadeUtility dateStringFromString:[event objectForKey:spadeEventWhen]];
   

    
}

- (void)slidingMenu:(RPSlidingMenuViewController *)slidingMenu didSelectItemAtRow:(NSInteger)row {
    [super slidingMenu:self didSelectItemAtRow:row];
    // when a row is tapped do some action like go to another view controller
   }

#pragma mark Slide Menu Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfItemsInSlidingMenu];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SpadeSlideCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SpadeSlideCellIdentifier forIndexPath:indexPath];
    
    [self customizeCell:cell forRow:indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self slidingMenu:self didSelectItemAtRow:indexPath.row];
}






#pragma mark


@end
