//
//  SpadeVenueDetailViewController.m
//  Spade
//
//  Created by Devon Ryan on 12/14/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import "SpadeVenueDetailViewController.h"
#import "SpadeUtility.h"
#import "SpadeMapViewController.h"
#import "SpadeConstants.h"
#import "SpadeCache.h"
#import "SpadeEventCreationViewController.h"

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
        
        [SpadeUtility loadFile:[self.venue objectForKey:spadeVenuePicture]forImageView:self.venueProfilePic];
        
    }else{//Set Pic to Default
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
        [[SpadeCache sharedCache]addFollowedVenue:self.venue];

        [self createAndDisplayFollowAlert];
    
    }else if ([sender.titleLabel.text isEqualToString:spadeFollowButtonTitleUnfollow]){
        [sender setTitle:spadeFollowButtonTitleFollow forState:UIControlStateNormal];
        
        [[SpadeCache sharedCache]removeFollowedVenue:self.venue];
        
    }

 
    
}
- (IBAction)createEventPressed:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    //Create Detail View
    SpadeEventCreationViewController *createEvent = [mainStoryboard   instantiateViewControllerWithIdentifier:@"CreateEventViewController"];
    
    createEvent.venuePickerSelection = self.venue;
    
    UINavigationController *tempNav = [[UINavigationController alloc]initWithRootViewController:createEvent];
    [self presentViewController:tempNav animated:YES completion:nil];

}


-(void)actionButtonPressed
{
    UIActionSheet *venueActionList = [[UIActionSheet alloc]initWithTitle:@"Mao" delegate:self cancelButtonTitle:@"Nevermind" destructiveButtonTitle:nil otherButtonTitles:@"See on Map", nil];
    [venueActionList showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];

}
#define FIND_LOCATION_BUTTON 0
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == FIND_LOCATION_BUTTON) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        //Create Detail View
        SpadeMapViewController *mapViewController = [mainStoryboard   instantiateViewControllerWithIdentifier:@"mapViewController"];
        
        mapViewController.address = [self.venue objectForKey:spadeVenueAddress];
        
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
