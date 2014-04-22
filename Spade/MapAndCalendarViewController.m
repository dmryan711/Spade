//
//  MapAndCalendarViewController.m
//  Spade
//
//  Created by Devon Ryan on 4/17/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "MapAndCalendarViewController.h"
#import "RDVCalendarViewController.h"
#import "SpadeMapViewController.h"
#import "UIColor+FlatUI.h"
#import "SpadeConstants.h"
#import "FBShimmering.h"
#import "FBShimmeringView.h"

@interface MapAndCalendarViewController () 

@property (strong, nonatomic) RDVCalendarViewController *calendar;
@property (strong, nonatomic) SpadeMapViewController    *map;
@property (strong, nonatomic ) UIButton *mapExpandButton;
@property (strong , nonatomic) FBShimmeringView *shimmerView;
@property (strong, nonatomic) UIView *shimmerContainer;
@property (strong, nonatomic) UILabel *shimmerLabel;


@property (nonatomic) BOOL isMapExpanded;

@end

@implementation MapAndCalendarViewController

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
    // Do any additional setup after loading the view.
    

    
    
    //Draw Calendar View
    self.calendar = [[RDVCalendarViewController alloc]initWithNibName:nil bundle:nil];
    self.calendar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2);
    self.calendar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.calendar.view];
    
    self.map = [[SpadeMapViewController alloc]initWithNibName:nil bundle:nil];
    self.map.frame = CGRectMake(CGRectGetMinX(self.calendar.frame), CGRectGetMaxY(self.calendar.frame), self.view.frame.size.width, self.view.frame.size.height/2);
    
    if (!_shimmerContainer) _shimmerContainer = [[UIView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(self.calendar.view.bounds), self.view.frame.size.width, 30)];
    if (!_shimmerView) _shimmerView = [[FBShimmeringView alloc] initWithFrame:self.shimmerContainer.bounds];
    if (!_shimmerLabel) _shimmerLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.shimmerView.bounds.origin.x , self.shimmerView.bounds.origin.y +2 , self.shimmerView.frame.size.width, self.shimmerView.frame.size.height - 5)];

    UITapGestureRecognizer *resizeMapTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reSizeMap)];
    
    [self.shimmerLabel setUserInteractionEnabled:YES];
    [self.shimmerContainer setUserInteractionEnabled:YES];
    [self.shimmerView setUserInteractionEnabled:YES];
    [self.shimmerLabel addGestureRecognizer:resizeMapTap];
    //[self.shimmerContainer addGestureRecognizer:resizeMapTapB];
    //[self.shimmerView addGestureRecognizer:resizeMapTapC];
    
    self.shimmerLabel.textAlignment = NSTextAlignmentCenter;
    self.shimmerLabel.textColor = [UIColor wisteriaColor];
    self.shimmerLabel.font = [UIFont fontWithName:@"Avenir-Light" size:20];
    self.shimmerLabel.text = NSLocalizedString(@"Fullscreen Map", nil);
    self.shimmerView.contentView = self.shimmerLabel;
    [self.shimmerContainer addSubview:self.shimmerView];
    [self.view addSubview:self.shimmerContainer];
    self.shimmerContainer.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.map.view];
    [self.view bringSubviewToFront:self.shimmerContainer];
    
    
    // Start shimmering.
    self.shimmerView.shimmering = YES;
    //[self.map.view bringSubviewToFront:self.shimmerLabel];
   
    
    PFQuery *queryForVenues = [PFQuery queryWithClassName:spadeClassVenue];
    queryForVenues.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [queryForVenues whereKeyExists:spadeVenueAddress];
    [queryForVenues findObjectsInBackgroundWithBlock:^(NSArray *venues, NSError *error){
        [self.map addLocations:venues atIndex:0];
        
    }];
}

-(void)reSizeMap
{
    NSLog(@"Tap");
    if (self.isMapExpanded) {
        [UIView animateWithDuration:0.5f animations:^(void){
            self.map.view.frame = CGRectMake(CGRectGetMinX(self.calendar.frame), CGRectGetMaxY(self.calendar.frame), self.view.frame.size.width, self.view.frame.size.height/2);
            self.shimmerContainer.frame = CGRectMake(0,CGRectGetMaxY(self.calendar.view.bounds), self.view.frame.size.width, 30);
            self.map.directionsButton.frame =  CGRectMake(-10, self.map.view.bounds.size.height *.75 , 30, 50);

            
        } completion:nil];
        self.shimmerLabel.text = @"Fullscreen Map";
        self.shimmerLabel.font = [UIFont fontWithName:@"Avenir-Light" size:20];
        [self.map shiftDirectionsButton];
        self.isMapExpanded = NO;
        
    }else{
        [UIView animateWithDuration:0.5f animations:^(void){
            self.map.view.frame = CGRectMake(0, [[UIApplication sharedApplication] statusBarFrame].size.height, self.view.frame.size.width, self.view.frame.size.height -[[UIApplication sharedApplication] statusBarFrame].size.height);
            self.shimmerContainer.frame = CGRectMake(0,0 + [[UIApplication sharedApplication] statusBarFrame].size.height, self.view.frame.size.width, 30);
            self.map.directionsButton.frame =  CGRectMake(-10, self.map.view.bounds.size.height *.75 , 30, 50);

            
        } completion:nil];
        
        self.shimmerLabel.text = @"View Calendar";
        self.shimmerLabel.font = [UIFont fontWithName:@"Avenir-Light" size:20];

        self.isMapExpanded = YES;
    
    }


}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
