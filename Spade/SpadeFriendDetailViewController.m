//
//  SpadeFriendDetailViewController.m
//  Spade
//
//  Created by Devon Ryan on 12/29/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//
#import "SpadeConstants.h"
#import "SpadeUtility.h"
#import "SpadeCache.h"
#import "SpadeFriendDetailViewController.h"


@interface SpadeFriendDetailViewController ()

@property (weak, nonatomic) IBOutlet PFImageView *friendProfileImage;
@property (weak, nonatomic) IBOutlet UITableView *eventTableView;
@property (strong, nonatomic) NSMutableArray *objects;
@property (strong, nonatomic) PFQuery *query;
@property (strong, nonatomic) UIRefreshControl *tableRefresh;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@end

@implementation SpadeFriendDetailViewController

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
    NSLog(@"Awake from nib");
    
  
   self.query =  [PFQuery queryWithClassName:spadeClassActivity];

   //
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.title = [self.friend objectForKey:spadeUserDisplayName];
    self.friendProfileImage.file  = [self.friend objectForKey:spadeUserMediumProfilePic];
    [self.friendProfileImage loadInBackground];
    
    //Set Query and Run
    self.query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [self.query whereKey:spadeActivityToUser equalTo:self.friend];
    [self runQueryAndReloadData];
    
    //Add Refresh Control
    self.tableRefresh = [[UIRefreshControl alloc]init];
    [self.tableRefresh addTarget:self action:@selector(runQueryAndReloadData) forControlEvents:UIControlEventValueChanged];
    [self.eventTableView addSubview:self.tableRefresh];
    
    //setFollowButton
    if ([[[SpadeCache sharedCache]followingUsers] containsObject:[self.friend objectId]]) {
        [self.followButton setTitle:spadeFollowButtonTitleUnfollow forState:UIControlStateNormal];
    }else{
        
        [self.followButton setTitle:spadeFollowButtonTitleFollow forState:UIControlStateNormal];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[[[self.navigationController viewControllers]objectAtIndex:1]tableView]reloadData];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.objects count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    NSLog(@"%@",[object description]);
    cell.textLabel.text = @"Test";
    return cell;

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (IBAction)followButtonPressed:(UIButton *)sender {
    
    
    if([sender.titleLabel.text isEqualToString:spadeFollowButtonTitleFollow]){
        [sender setTitle:spadeFollowButtonTitleUnfollow forState:UIControlStateNormal];
        [[[SpadeCache sharedCache] followingUsers] addObject:[self.friend objectId]];
        [SpadeUtility user:[PFUser currentUser] followingUser:self.friend];
    
        [self createAndDisplayFollowAlert];
        
    }else if ([sender.titleLabel.text isEqualToString:spadeFollowButtonTitleUnfollow]){
        
        [sender setTitle:spadeFollowButtonTitleFollow forState:UIControlStateNormal];
        [[[SpadeCache sharedCache] followingUsers] removeObject:[self.friend objectId]];
        [SpadeUtility user:[PFUser currentUser] unfollowingUser:self.friend];
        
       
        
    }
    NSLog(@"User Cache: %@",[[SpadeCache sharedCache]followingUsers]);
}



#pragma mark { }

-(void)runQueryAndReloadData
{
    if (!_objects) _objects = [[NSMutableArray alloc]init];
    
    [self.query findObjectsInBackgroundWithBlock:^(NSArray *objectsFound, NSError *error){
        if (!error) {
            NSLog(@"Ran");
            [self.objects removeAllObjects];
            [self.objects addObjectsFromArray:objectsFound];
            [self.eventTableView reloadData];
            [self.tableRefresh endRefreshing];
        }
        
    }];

    
}

-(void)createAndDisplayFollowAlert{
    UIAlertView *followingUser = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Following %@",self.title] message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [followingUser show];
    
}

@end
