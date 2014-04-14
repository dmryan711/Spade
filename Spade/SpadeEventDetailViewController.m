//
//  SpadeEventDetailViewController.m
//  Spade
//
//  Created by Devon Ryan on 1/5/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "SpadeEventDetailViewController.h"
#import "SpadeVenueDetailViewController.h"
#import "SpadeFriendDetailViewController.h"
#import "SpadeChatViewController.h"
#import "SpadeChatCell.h"
#import "SpadeConstants.h"
#import "SpadeUtility.h"
#import "SpadeCache.h"
#import "FUIButton.h"
#import "UIColor+FlatUI.h"

@interface SpadeEventDetailViewController ()

@property (strong, nonatomic) UIRefreshControl *friendTableRefreshControl;
@property (strong, nonatomic) NSMutableArray *friendData;
@property (strong, nonatomic) PFQuery *friendsForEventQuery;
@property (weak, nonatomic) IBOutlet UITableView *friendsTable;
@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueLabel;
@property (weak, nonatomic) IBOutlet UILabel *whenLabel;
@property (weak, nonatomic) IBOutlet UILabel *atLabel;
@property (weak, nonatomic) IBOutlet FUIButton *attendanceButton;
@property (weak, nonatomic) IBOutlet FUIButton *venueDetailButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;


@end

@implementation SpadeEventDetailViewController

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
    //self.friendsForEventQuery = [PFQuery queryWithClassName:spadeClassActivity];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Kills Swipe Navigation
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    //[self.view addSubview:self.friendsTable];
    
    //[self.view bringSubviewToFront:self.friendsTable];
    
    //[self toggleChat];
	// Do any additional setup after loading the view.
    PFObject *event = [self.object objectForKey:spadeActivityToEvent];
    PFObject *venue = [self.object objectForKey:spadeActivityForVenue];
    
    //self.title = [event objectForKey:spadeEventName];
    self.view.backgroundColor  = [UIColor blackColor];
    
    self.venueDetailButton.cornerRadius = 3;
    self.venueDetailButton.buttonColor = [UIColor concreteColor];
    self.venueDetailButton.shadowColor = [UIColor asbestosColor];
    self.venueDetailButton.shadowHeight = 3;
    self.venueDetailButton.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:12];
    [self.venueDetailButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    
    self.attendanceButton.cornerRadius = 3;
    self.attendanceButton.buttonColor = [UIColor amethystColor];
    self.attendanceButton.shadowColor = [UIColor wisteriaColor];
    self.attendanceButton.shadowHeight = 3;
    self.attendanceButton.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:12];
    [self.attendanceButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];

    
    //Set Query and Run
    /*self.friendsForEventQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [self.friendsForEventQuery whereKeyExists:spadeActivityToEvent];
    [self.friendsForEventQuery includeKey:spadeActivityFromUser];
    [self.friendsForEventQuery whereKey:spadeActivityToEvent equalTo:event];
    
    [self runFriendQueryAndReloadData];
    
    //Add Refresh Controls
    
    self.friendTableRefreshControl = [[UIRefreshControl alloc]init];
    [self.friendTableRefreshControl addTarget:self action:@selector(runFriendQueryAndReloadData) forControlEvents:UIControlEventValueChanged];
    [self.friendsTable addSubview:self.friendTableRefreshControl];*/
   
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Chat" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleChat)];
    
    //set labels
   // NSLog(@"OBJECT %@",[[self.object objectForKey:@"Venue"]objectForKey:spadeVenueName]);
    self.eventLabel.text = self.title;
    self.venueLabel.text = [venue objectForKey:spadeVenueName];
    self.whenLabel.text = [event objectForKey:spadeEventWhen];
    self.timeLabel.text = [event objectForKey:spadeEventTime];
    
    self.eventLabel.font = [UIFont fontWithName:@"Lato-Bold" size:14];
    self.atLabel.font = [UIFont fontWithName:@"Lato-Regular" size:14];
    self.venueLabel.font = [UIFont fontWithName:@"Lato-Bold" size:14];
    self.whenLabel.font = [UIFont fontWithName:@"Lato-Bold" size:14];
    self.timeLabel.font = [UIFont fontWithName:@"Lato-Bold" size:14];
    
    self.eventLabel.textColor = [UIColor whiteColor];
    self.atLabel.textColor = [UIColor whiteColor];
    self.venueLabel.textColor = [UIColor whiteColor];
    self.whenLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textColor = [UIColor whiteColor];
    
    
    
    //if venue club,lounge,bar  statement to dictate image
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"party_night-wide_3.jpg"]];
    
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    leftBtn.frame = CGRectMake(-10, 380, 30, 50);
    [leftBtn setTitle:@"☰" forState:UIControlStateNormal];
    leftBtn.backgroundColor = [UIColor cloudsColor];
    leftBtn.titleLabel.textColor = [UIColor amethystColor];
    leftBtn.alpha = .6;
    leftBtn.tag = 1;
    [leftBtn.layer setCornerRadius:0.0f];
    [leftBtn.layer setShadowOffset:CGSizeMake(2, 2)];
    [leftBtn.layer setShadowColor:[UIColor whiteColor].CGColor];
    [leftBtn.layer setShadowOpacity:0.8];
    [leftBtn addTarget:self action:@selector(movePanelRight:) forControlEvents:UIControlEventTouchUpInside];
    self.leftButton = leftBtn;
    [self.view addSubview:self.leftButton];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    rightBtn.frame = CGRectMake(300, 380, 30, 50);
    [rightBtn setTitle:@"☰" forState:UIControlStateNormal];
    rightBtn.backgroundColor = [UIColor cloudsColor];
    rightBtn.alpha = .6;
    rightBtn.tag = 1;
    [rightBtn.layer setCornerRadius:0.0f];
    [rightBtn.layer setShadowOffset:CGSizeMake(-2, 2)];
    [rightBtn.layer setShadowColor:[UIColor whiteColor].CGColor];
    [rightBtn.layer setShadowOpacity:0.8];
    [rightBtn addTarget:self action:@selector(movePanelLeft:) forControlEvents:UIControlEventTouchUpInside];
    self.rightButton = rightBtn;
    [self.view addSubview:self.rightButton];
    
    [self.view bringSubviewToFront:self.rightButton];

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*#pragma mark TableView Data Source
- (SpadeFollowCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        static NSString *FriendCellIdentifier = @"FriendCell";
        
        PFUser *friend = [[self.friendData objectAtIndex:indexPath.row] objectForKey:spadeActivityFromUser];
    
    
        SpadeFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
        if (cell == nil) {
            cell = [[SpadeFollowCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:FriendCellIdentifier];
        }
    
    [cell bringSubviewToFront:cell.followButton];
        cell.backgroundColor = [UIColor cloudsColor];
    
        cell.delegate = self;
        cell.object = friend;
    cell.nameLabel.font = [UIFont fontWithName:@"Lato-Bold" size:12];
    
    
    
        
        if ([[[[[SpadeCache sharedCache]cache]objectForKey:spadeCache]objectForKey:spadeCacheUser] containsObject:friend]) {
            [cell.followButton setTitle:spadeFollowButtonTitleUnfollow forState:UIControlStateNormal];
            cell.followButton.cornerRadius = 3;
            cell.followButton.buttonColor = [UIColor concreteColor];
            cell.followButton.shadowColor = [UIColor asbestosColor];
            cell.followButton.shadowHeight = 3;
            cell.followButton.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:12];
            [cell.followButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
        }else{
            cell.followButton.cornerRadius = 3;
            cell.followButton.buttonColor = [UIColor amethystColor];
            cell.followButton.shadowColor = [UIColor wisteriaColor];
            cell.followButton.shadowHeight = 3;
            cell.followButton.titleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:12];
            [cell.followButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
        }
        // Configure the cell
        cell.nameLabel.text = [friend objectForKey:spadeUserDisplayName];
        
        if ([friend objectForKey:spadeUserSmallProfilePic]) {
            [cell.profileImageView setFile:[friend objectForKey:spadeUserSmallProfilePic]];
            [cell.profileImageView loadInBackground];
        }else{
            cell.profileImageView.image = [UIImage imageNamed:@"AvatarPlaceHolder.png"];
        }
        
        return cell;
}*/

/*-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
        UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0,0,300,50)];
        tempView.backgroundColor=[UIColor asbestosColor];
        UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(0,-10,300,44)];
        tempLabel.backgroundColor=[UIColor clearColor];
        tempLabel.font = [UIFont fontWithName:@"Lato-Bold" size:16];
    tempLabel.textColor = [UIColor cloudsColor];
        tempLabel.text=@"                                          Attendees";
        [tempView addSubview: tempLabel];
        return tempView;
    
}*/


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friendData count];

}
/*- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 96;
    
}*/

#pragma mark - Table view delegate

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

/*- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.friendsTable) {

        if (indexPath.row < [self.friendData count]) {
        
            //Set Selection Object
            PFUser *userSelection = [[self.friendData objectAtIndex:indexPath.row]objectForKey:spadeActivityFromUser];
        
            //Create Detail View
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
            //Create Detail View
            SpadeFriendDetailViewController *friendDetail = [mainStoryboard   instantiateViewControllerWithIdentifier:@"friendDetailController"];
        
            [friendDetail setFriend:userSelection];
        
            [self.navigationController pushViewController:friendDetail animated:YES];
        }
    }else{
    
    
    }
}*/


#pragma mark { }

-(void)runFriendQueryAndReloadData
{
    if (!_friendData) _friendData = [[NSMutableArray alloc]init];
    [self.friendsForEventQuery findObjectsInBackgroundWithBlock:^(NSArray *objectsFound, NSError *error){
        if (!error) {
            [self.friendData removeAllObjects];
            [self.friendData addObjectsFromArray:objectsFound];
            [self.friendsTable reloadData];
            [self.friendTableRefreshControl endRefreshing];
            
        }
    
    }];

}

/*-(void)toggleChat
{
    if (![self.tableView isHidden]) { //Chat is not hidden
        //Hide IT
        self.tableView.hidden = YES;
        self.chatEntryField.hidden = YES;
        self.sendButton.hidden = YES;
        
        //Show Friend Table & Other Labels
        self.friendsTable.hidden = NO;
        self.eventLabel.hidden  = NO;
        self.venueLabel.hidden = NO;
        self.atLabel.hidden = NO;
        self.whenLabel.hidden = NO;
        
    }else{
        self.tableView.hidden = NO;
        self.chatEntryField.hidden = NO;
        self.sendButton.hidden = NO;
        
        //Show Friend Table & Other Labels
        self.friendsTable.hidden = YES;
        self.eventLabel.hidden  = YES;
        self.atLabel.hidden = YES;
        self.whenLabel.hidden = YES;
        self.venueLabel.hidden = YES;
    
    
    }
}*/

-(void)toggleChat
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    //Create Detail View
    SpadeChatViewController *chatViewController = [mainStoryboard   instantiateViewControllerWithIdentifier:@"chatVC"];
    
    chatViewController.event = self.object;
    
    UINavigationController *tempNav = [[UINavigationController alloc]initWithRootViewController:chatViewController];
    [self presentViewController:tempNav animated:YES completion:nil];


}

#pragma mark Button Methods
- (IBAction)venueButtonPressed:(UIButton *)sender {
    //Go to the venue detail for this venue
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    //Create Detail View
    SpadeVenueDetailViewController  *venueDetail = [mainStoryboard   instantiateViewControllerWithIdentifier:@"venueDetailController"];
    
    venueDetail.venue = [self.object objectForKey:spadeActivityForVenue];
    
    [self.navigationController pushViewController:venueDetail animated:YES];

    
    
}
- (IBAction)attendanceButtonPressed:(UIButton *)sender {
    if ([self.attendButton.titleLabel.text isEqualToString: spadeEventAttendanceButtonTitleAttend] ) {
        [SpadeUtility user:[PFUser currentUser] attendingEvent:[self.object objectForKey: spadeActivityToEvent]];
        [self.attendButton setTitle:spadeEventAttendanceButtonTitleUnattend forState:UIControlStateNormal];
        
    }else if ([self.attendButton.titleLabel.text isEqualToString: spadeEventAttendanceButtonTitleUnattend]){
        [SpadeUtility user:[PFUser currentUser] unAttendingEvent:[self.object objectForKey: spadeActivityToEvent]];
        [self.attendButton setTitle:spadeEventAttendanceButtonTitleAttend forState:UIControlStateNormal];

    }
    
}



#pragma mark SpadeFollowCell Delegate Methods
-(void)followButtonWasPressedForCell:(SpadeFollowCell *)cell
{
    NSLog(@"followpressed");
    if ([cell.followButton.titleLabel.text isEqualToString:spadeFollowButtonTitleFollow]) {
        [cell.followButton setTitle:spadeFollowButtonTitleUnfollow forState:UIControlStateNormal];
        //set cache to follow user
        
        [[SpadeCache sharedCache]addFollowedUser:(PFUser *)cell.object];
        
      
        
    }else if ([cell.followButton.titleLabel.text isEqualToString:spadeFollowButtonTitleUnfollow]){
        [cell.followButton setTitle:spadeFollowButtonTitleFollow forState:UIControlStateNormal];
        
        //set cache to remove user from follow list
        [[SpadeCache sharedCache]removeFollowedUser:(PFUser *)cell.object];
        
        
    }else{
        NSError *error = [NSError errorWithDomain:@"Cell Title Not Matching Follow/UNfollow" code:1 userInfo:@{@"Title": [NSString stringWithFormat:@"Button Title: %@", cell.nameLabel.text ]}];
        NSLog(@"Error %@",error);

        
    }
    
}
- (void)movePanelRight:(UIButton *)sender {
    UIButton *button = sender;
    switch (button.tag) {
        case 0: {
            [_delegate movePanelToOriginalPosition];
            break;
        }
            
        case 1: {
            [_delegate movePanelRight];
            break;
        }
            
        default:
            break;
    }
}
- (void)movePanelLeft:(UIButton *)sender {
    UIButton *button = sender;
    switch (button.tag) {
        case 0: {
            [_delegate movePanelToOriginalPosition];
            break;
        }
            
        case 1: {
            [_delegate movePanelLeft];
            break;
        }
            
        default:
            break;
    }

}


@end
