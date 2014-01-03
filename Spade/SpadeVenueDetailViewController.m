//
//  SpadeVenueDetailViewController.m
//  Spade
//
//  Created by Devon Ryan on 12/14/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import "SpadeVenueDetailViewController.h"
#import "SpadeUtility.h"
#import "SpadeConstants.h"
#import "SpadeCache.h"

@interface SpadeVenueDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@property (weak, nonatomic) IBOutlet UILabel *coverLabel;

@property (weak, nonatomic) IBOutlet UILabel *musicLabel;

@property (weak, nonatomic) IBOutlet UILabel *spendLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottleServiceLabel;
@property (weak, nonatomic) IBOutlet PFImageView *venueProfilePic;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UIButton *followButton;


@end

@implementation SpadeVenueDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    

   
    
    self.navigationController.navigationBarHidden = NO;
	// Do any additional setup after loading the view.
    //[self creatBackButton];
    self.title  = [self.venue objectForKey:spadeVenueName];
    self.categoryLabel.text = [NSString stringWithFormat:@"%@",[self.venue objectForKey:spadeVenueCategory]];
    self.coverLabel.text = [NSString stringWithFormat:@"$%@",[self.venue objectForKey:spadeVenueCover]];
     self.musicLabel.text = [NSString stringWithFormat:@"%@",[self.venue objectForKey:spadeVenueGenre]];
     self.spendLabel.text = [NSString stringWithFormat:@"%@",[SpadeUtility  processCurrencyLevel:[self.venue objectForKey:spadeVenueSpendLevel]]];
    self.bottleServiceLabel.text = [NSString stringWithFormat:@"%@",[SpadeUtility processBottleService:(BOOL)[self.venue objectForKey:spadeVenueTableService]]];
    self.addressLabel.text = [self.venue objectForKey:spadeVenueAddress];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed)];
  
    if ([self.venue objectForKey:spadeVenuePicture]) {
        NSLog(@"Venue Detail: Image File Found");
        
        [SpadeUtility loadFile:[self.venue objectForKey:spadeVenuePicture]forImageView:self.venueProfilePic];
        
    }else{//Set Pic to Default
        NSLog(@"Venue Detail: No Picture Was Found");
        self.venueProfilePic.image = [UIImage imageNamed:@"default_venue_Image.jpeg"];
    }
    
    //setFollowButton
    if (self.isFollowing) {
        [self.followButton setTitle:spadeFollowButtonTitleUnfollow forState:UIControlStateNormal];
    }else{
    
        [self.followButton setTitle:spadeFollowButtonTitleFollow forState:UIControlStateNormal];
    }
    
}

#define VENUE_TABLEVIEW_CONTROLLER 0
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //Reloading Table VIew to keep follow buttons in sync
    [[[[self.navigationController viewControllers]objectAtIndex:VENUE_TABLEVIEW_CONTROLLER] tableView]reloadData];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)followButtonPressed:(UIButton *)sender {
    //setFollowButton
    
    if([sender.titleLabel.text isEqualToString:spadeFollowButtonTitleFollow]){
        [sender setTitle:spadeFollowButtonTitleUnfollow forState:UIControlStateNormal];
         [[[SpadeCache sharedCache]followingVenues] addObject:[self.venue objectId]];
            [SpadeUtility user:[PFUser currentUser] followingVenue:self.venue];
            [self createAndDisplayFollowAlert];
    
    }else if ([sender.titleLabel.text isEqualToString:spadeFollowButtonTitleUnfollow]){
        [sender setTitle:spadeFollowButtonTitleFollow forState:UIControlStateNormal];
        [[[SpadeCache sharedCache]followingVenues]removeObject:[self.venue objectId]];
        [SpadeUtility user:[PFUser currentUser] unfollowingVenue:self.venue];
        
    }
    //Set Local Cache
    NSLog(@"%@",[[SpadeCache sharedCache]followingVenues]);
 
    
}
- (IBAction)createEventPressed:(id)sender {
    NSLog(@"Venue Detail/: Pew, Pew. Create Event Pressed");
}


-(void)actionButtonPressed
{
    UIActionSheet *venueActionList = [[UIActionSheet alloc]initWithTitle:@"Venue Action List" delegate:self cancelButtonTitle:@"Nevermind" destructiveButtonTitle:nil otherButtonTitles:@"Get Directions", nil];
    [venueActionList showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];

}
#define FIND_LOCATION_BUTTON 0
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == FIND_LOCATION_BUTTON) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        //Create Detail View
        UIViewController *mapViewController = [mainStoryboard   instantiateViewControllerWithIdentifier:@"mapViewController"];
        
        //FIRE
        

        [self.navigationController pushViewController:mapViewController animated:YES];
    }

}


#pragma mark helper methods { }
/*-(void)creatBackButton
{
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@" Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonPressed)];
    self.navigationItem.leftBarButtonItem = backButton;
    
}

-(void)backButtonPressed
{
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}*/


-(void)createAndDisplayFollowAlert{
    UIAlertView *followingVenue = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Following %@",self.title] message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [followingVenue show];

}




@end
