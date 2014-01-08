//
//  SpadeEventDetailViewController.m
//  Spade
//
//  Created by Devon Ryan on 1/5/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "SpadeEventDetailViewController.h"
#import "SpadeFriendDetailViewController.h"
#import "SpadeChatCell.h"
#import "SpadeConstants.h"
#import "SpadeUtility.h"
#import "SpadeCache.h"

@interface SpadeEventDetailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *chatEntryField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIRefreshControl *friendTableRefreshControl;
@property (strong, nonatomic) NSMutableArray *chatData;
@property (strong, nonatomic) NSMutableArray *friendData;
@property (strong, nonatomic) PFQuery *query;
@property (strong, nonatomic) PFQuery *friendsForEventQuery;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITableView *friendsTable;
@property (weak, nonatomic) IBOutlet UILabel *eventLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueLabel;
@property (weak, nonatomic) IBOutlet UILabel *whenLabel;
@property (weak, nonatomic) IBOutlet UILabel *atLabel;

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
    self.query =  [PFQuery queryWithClassName:spadeClassChat];
    self.friendsForEventQuery = [PFQuery queryWithClassName:spadeClassActivity];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self toggleChat];
	// Do any additional setup after loading the view.
    self.title = [self.object objectForKey:spadeEventName];
    self.chatEntryField.delegate = self;
    self.chatEntryField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self registerForKeyboardNotifications];
    
    //Set Query and Run
    self.query.cachePolicy = kPFCachePolicyNetworkOnly;
    [self.query whereKey:spadeChatforEvent equalTo:self.object];
    [self.query includeKey:spadeChatFromUser];
    [self.query includeKey:spadeUserDisplayName];
    [self.query orderByDescending:@"createdAt"];

    [self runQueryAndReloadData];
    
    self.friendsForEventQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [self.friendsForEventQuery whereKeyExists:spadeActivityToEvent];
    [self.friendsForEventQuery includeKey:spadeActivityFromUser];
    [self.friendsForEventQuery whereKey:spadeActivityToEvent equalTo:self.object];
    
    [self runFriendQueryAndReloadData];
    
    //Add Refresh Controls
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(runQueryAndReloadData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    self.friendTableRefreshControl = [[UIRefreshControl alloc]init];
    [self.friendTableRefreshControl addTarget:self action:@selector(runFriendQueryAndReloadData) forControlEvents:UIControlEventValueChanged];
    [self.friendsTable addSubview:self.friendTableRefreshControl];
   
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Chat" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleChat)];
    
    //set labels
    self.eventLabel.text = [self.object objectForKey:spadeEventName];
    //self.venueLabel.text = [[self.object objectForKey:spadeEventVenue]objectForKey:spadeVenueName];
    self.whenLabel.text = [self.object objectForKey:spadeEventWhen];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self freeKeyboardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark TableView Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {

        NSUInteger newIndex = (indexPath.row /2);
        static NSString *CellIdentifier = @"spadeChatCelll";
        static NSString *CellIdentifierUser = @"spadeUserChatCelll";
        static NSString *CellSpacer = @"spacer";
        if (indexPath.row % 2 == 1) { //odd
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellSpacer ];
            if (cell == nil) {
                cell = [[SpadeChatCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellSpacer];
            }
        
            [cell.contentView setAlpha:0];
            cell.backgroundColor = [UIColor clearColor];
            [cell setUserInteractionEnabled:NO];
        
            return cell;

        
        }else if ([[[[self.chatData objectAtIndex:newIndex]objectForKey:spadeChatFromUser]objectId] isEqualToString:[[PFUser currentUser]objectId]]) {
        
            SpadeChatCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierUser];
            if (cell == nil) {
                cell = [[SpadeChatCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierUser];
            }
    
            PFObject *messageLog = [self.chatData objectAtIndex:newIndex];
            cell.userName.text = [[messageLog objectForKey:spadeChatFromUser]objectForKey:spadeUserDisplayName];
            cell.textString.text = [messageLog objectForKey:spadeChatMessage];
    
            return cell;
        
        }else{
        
            SpadeChatCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[SpadeChatCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }
        
            PFObject *messageLog = [self.chatData objectAtIndex:newIndex];
            cell.userName.text = [[messageLog objectForKey:spadeChatFromUser]objectForKey:spadeUserDisplayName];
            cell.textString.text = [messageLog objectForKey:spadeChatMessage];
        
            return cell;
    
        }
    }else{
        static NSString *FriendCellIdentifier = @"FriendCell";
        
        PFUser *friend = [[self.friendData objectAtIndex:indexPath.row] objectForKey:spadeActivityFromUser];
        
        SpadeFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:FriendCellIdentifier];
        if (cell == nil) {
            cell = [[SpadeFollowCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:FriendCellIdentifier];
        }
        
        cell.delegate = self;
        cell.object = friend;
        
        
        if ([[[SpadeCache sharedCache]followingUsers] containsObject:friend.objectId]) {
            [cell.followButton setTitle:spadeFollowButtonTitleUnfollow forState:UIControlStateNormal];
        }else{
            [cell.followButton setTitle:spadeFollowButtonTitleFollow forState:UIControlStateNormal];
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

    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.friendsTable) {
        return @"Attendees";
    }else{
    
        return @"";
    }

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {

        if ([self.chatData count] == 0) {
            return 0;
        }else{
        
            return ([self.chatData count] *2)-1;
        }
    }else{
        return [self.friendData count];
    
    }

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.tableView) {

        if (indexPath.row % 2 == 1)
            return 40;
        return 80;
    }else{
        return 96;
    
    }
}

#pragma mark - Table view delegate

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


- (IBAction)viewTapped:(id)sender {
    
    [self.view endEditing:YES];
}
#pragma mark Chat TextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self sendPressed:nil];
    return YES;
}
-(void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


-(void) freeKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#define TABBAR_HEIGHT 57
-(void) keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"Keyboard was shown");
    NSDictionary* info = [aNotification userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y- keyboardFrame.size.height + TABBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height)];
    
    [UIView commitAnimations];
    
}

-(void) keyboardWillHide:(NSNotification*)aNotification
{
    NSLog(@"Keyboard will hide");
    NSDictionary* info = [aNotification userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + keyboardFrame.size.height-TABBAR_HEIGHT , self.view.frame.size.width, self.view.frame.size.height)];
    
    [UIView commitAnimations];
}
- (IBAction)sendPressed:(UIButton *)sender {
    
        PFObject *chatEntry = [PFObject objectWithClassName:spadeClassChat];
        [chatEntry setObject:self.chatEntryField.text forKey:spadeChatMessage];
        [chatEntry setObject:self.object forKey:spadeChatforEvent];
        [chatEntry setObject:[PFUser currentUser] forKey:spadeChatFromUser];
        [chatEntry saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if (succeeded) {
                [self runQueryAndReloadData];
            }
    
        }];
    
        self.chatEntryField.text =  @"";
        [self.view endEditing:YES];
  
    
}

#pragma mark { }
-(void)runQueryAndReloadData
{
    
    if (!_chatData) _chatData = [[NSMutableArray alloc]init];
    
    [self.query findObjectsInBackgroundWithBlock:^(NSArray *objectsFound, NSError *error){
        if (!error) {

            [self.chatData removeAllObjects];
            [self.chatData addObjectsFromArray:objectsFound];
            [self.tableView reloadData];
            [self.refreshControl  endRefreshing];
        }
        
    }];

}

-(void)runFriendQueryAndReloadData
{
    if (!_friendData) _friendData = [[NSMutableArray alloc]init];
    [self.friendsForEventQuery findObjectsInBackgroundWithBlock:^(NSArray *objectsFound, NSError *error){
        if (!error) {
            NSLog(@"Ran");
            [self.friendData removeAllObjects];
            [self.friendData addObjectsFromArray:objectsFound];
            [self.friendsTable reloadData];
            [self.friendTableRefreshControl endRefreshing];
            NSLog(@"Friend Data:%@",[self.friendData description]);
        }
    
    }];

}

-(void)toggleChat
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
}



#pragma mark SpadeFollowCell Delegate Methods
-(void)followButtonWasPressedForCell:(SpadeFollowCell *)cell
{
    if ([cell.followButton.titleLabel.text isEqualToString:spadeFollowButtonTitleFollow]) {
        [cell.followButton setTitle:spadeFollowButtonTitleUnfollow forState:UIControlStateNormal];
        //set cache to follow user
        [[[SpadeCache sharedCache]followingUsers] addObject:cell.object.objectId];
        
        //Follow User in Parse
        [SpadeUtility user:[PFUser currentUser] followingUser:(PFUser *)cell.object];
        
    }else if ([cell.followButton.titleLabel.text isEqualToString:spadeFollowButtonTitleUnfollow]){
        [cell.followButton setTitle:spadeFollowButtonTitleFollow forState:UIControlStateNormal];
        
        //set cache to remove user from follow list
        [[[SpadeCache sharedCache]followingUsers] removeObject:cell.object.objectId];
        
        //unfollow from Parse
        [SpadeUtility user:[PFUser currentUser] unfollowingUser:(PFUser *)cell.object];
        
    }else{
        NSError *error = [NSError errorWithDomain:@"Cell Title Not Matching Follow/UNfollow" code:1 userInfo:@{@"Title": [NSString stringWithFormat:@"Button Title: %@", cell.nameLabel.text ]}];
        
        NSLog(@"Error: %@",error.description);
    }
    
    NSLog(@"User Cache: %@",[[SpadeCache sharedCache]followingUsers]);
    
}


@end
