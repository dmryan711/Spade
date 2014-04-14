//
//  SpadeVenueDetailViewController.m
//  Spade
//
//  Created by Devon Ryan on 12/14/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import "SpadeVenueDetailViewController.h"
#import "SpadeMapSlideViewController.h"
#import "SpadeUtility.h"
#import "SpadeMapViewController.h"
#import "SpadeConstants.h"
#import "SpadeCache.h"
#import "SpadeEventCreationViewController.h"
#import "FUIButton.h"
#import "UIColor+FlatUI.h"
#import "iCarousel.h"

@interface SpadeVenueDetailViewController () <iCarouselDataSource, iCarouselDelegate>;

@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@property (weak, nonatomic) IBOutlet UILabel *coverLabel;

@property (weak, nonatomic) IBOutlet UILabel *musicLabel;

@property (weak, nonatomic) IBOutlet UILabel *spendLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottleServiceLabel;
//@property (weak, nonatomic) IBOutlet PFImageView *venueProfilePic;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet FUIButton  *followButton;

@property (weak, nonatomic) IBOutlet FUIButton *createEventButton;
@property (strong, nonatomic) NSMutableArray *venuePhotos;
@property (nonatomic) BOOL wrap;

@property (weak, nonatomic) IBOutlet iCarousel *carosel;

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

-(void)awakeFromNib
{
    if (!_venuePhotos) _venuePhotos = [[NSMutableArray alloc]init];
    self.venuePhotos = [NSMutableArray arrayWithArray:@[[UIImage imageNamed:@"default_venue_Image.jpeg"],[UIImage imageNamed:@"party_night-wide_3.jpg"],[UIImage imageNamed:@"AvatarPlaceholder.png"]]];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Kills Swipe Navigation
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor wisteriaColor],NSBackgroundColorAttributeName,[UIFont fontWithName:@"Copperplate" size:16],NSFontAttributeName, nil];
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Map" style:UIBarButtonItemStyleBordered target:self action:@selector(pushMapView)];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Copperplate-Bold" size:14]} forState:UIControlStateNormal];
    
      self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backToVenueTable)];
    
        [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Copperplate-Bold" size:14]} forState:UIControlStateNormal];
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.carosel.type = iCarouselTypeCoverFlow2
    ;
    self.wrap  = YES;
    
    //Set up Buttons
    self.followButton.buttonColor = [UIColor wisteriaColor];
    self.followButton.shadowColor = [UIColor amethystColor];
    self.followButton.highlightedColor = [UIColor wisteriaColor];
    self.followButton.shadowHeight = 3;
    self.followButton.cornerRadius = 3;
    self.followButton.titleLabel.font = [UIFont fontWithName:@"Copperplate" size:12];
    [self.followButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.followButton setTitleColor:[UIColor amethystColor] forState:UIControlStateHighlighted];
    
    self.createEventButton.buttonColor = [UIColor wisteriaColor];
    self.createEventButton.shadowColor = [UIColor amethystColor];
    self.createEventButton.highlightedColor = [UIColor wisteriaColor];
    self.createEventButton.shadowHeight = 3;
    self.createEventButton.cornerRadius = 3;
    self.createEventButton.titleLabel.font = [UIFont fontWithName:@"Copperplate" size:12];
    [self.createEventButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.createEventButton setTitleColor:[UIColor amethystColor] forState:UIControlStateHighlighted];
   
    
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
    
   
    /*self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed)];*/
  
    if ([self.venue objectForKey:spadeVenuePicture]) {
        
       // [SpadeUtility loadFile:[self.venue objectForKey:spadeVenuePicture]forImageView:self.venueProfilePic];
        
    }else{//Set Pic to Default
        //self.venueProfilePic.image = [UIImage imageNamed:@"default_venue_Image.jpeg"];
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
    UIActionSheet *venueActionList = [[UIActionSheet alloc]initWithTitle:@"Map" delegate:self cancelButtonTitle:@"Nevermind" destructiveButtonTitle:nil otherButtonTitles:@"See on Map", nil];
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
        
        NSLog(@"Venue Address: %@", [self.venue objectForKey:spadeVenueAddress]);
        
        mapViewController.address = [self.venue objectForKey:spadeVenueAddress];
        
        //FIRE
        [self.navigationController pushViewController:mapViewController animated:YES];
    }

}

#pragma mark iCarosel Protocol
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [self.venuePhotos count];
}


- (NSUInteger)numberOfVisibleItemsInCarousel:(iCarousel *)carousel
{
    //limit the number of items views loaded concurrently (for performance reasons)
    return 3;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index
{
    //create a numbered view
    UIView  *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self.venuePhotos objectAtIndex:index]]];
    return view;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    //create a numbered view
     view = [[UIImageView alloc] initWithImage:[self.venuePhotos objectAtIndex:index]];
    return view;
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
    //note: placeholder views are only displayed on some carousels if wrapping is disabled
    return 0;
}

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    //usually this should be slightly wider than the item views
    return 240;
}

- (BOOL)carouselShouldWrap:(iCarousel *)carousel
{
    //wrap all carousels
    return self.wrap;
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

-(void)pushMapView

{
    
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    
    //Create Map View
    SpadeMapViewController *mapViewController = [mainStoryboard   instantiateViewControllerWithIdentifier:@"mapViewController"];
    mapViewController.address = [self.venue objectForKey:spadeVenueAddress];
    
    //Create Mainslide View
    SpadeMapSlideViewController *mapSlideViewController = [mainStoryboard   instantiateViewControllerWithIdentifier:@"mapSlide"];
    
    mapSlideViewController.centerViewController = mapViewController;
    
    
    //FIRE
    [self.navigationController pushViewController:mapSlideViewController animated:YES];

}

-(void)backToVenueTable
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)createAndDisplayFollowAlert{
    UIAlertView *followingVenue = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Following %@",self.title] message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [followingVenue show];

}




@end
