//
//  SpadeEventController.m
//  Spade
//
//  Created by Devon Ryan on 12/9/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import <Parse/Parse.h>
#import "SpadeConstants.h"
#import "SpadeEventController.h"
#import "SpadeConstants.h"
#import "SpadeUtility.h"
#import "SpadeEventCreationViewController.h"
#import "SpadeFollowCell.h"
#import "SpadeMyEventsCell.h"
#import "SpadeEventDetailViewController.h"
#import "UINavigationBar+FlatUI.h"
#import "UIColor+FlatUI.h"


@interface SpadeEventController ()

@property (strong, nonatomic) NSMutableArray *myEvents;
@property (strong, nonatomic) NSMutableArray *followedEvents;
@property (strong, nonatomic) PFQuery *myEventsQuery;
@property (strong, nonatomic) PFQuery *followedEventsQuery;
@property (weak, nonatomic) IBOutlet UISegmentedControl *eventSegmentController;
@property (weak, nonatomic) IBOutlet UITableView *manageEventsTableView;
@property (strong, nonatomic) UIRefreshControl *myEventsTableRefreshControl;
@property (weak, nonatomic) IBOutlet UITableView *myFollowedEventsTableView;
@property (strong, nonatomic) UIRefreshControl *myFollowedEventsTableRefreshControl;

@end

@implementation SpadeEventController

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
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor blendedColorWithForegroundColor:[UIColor blackColor] backgroundColor:[UIColor wisteriaColor] percentBlend:.6]];
    
    // Do any additional setup after loading the view.
     self.manageEventsTableView.hidden = NO;
    self.myFollowedEventsTableView.hidden =  YES;
    
    //Set Refresh Controls
    self.myEventsTableRefreshControl = [[UIRefreshControl alloc]init];
    [self.myEventsTableRefreshControl addTarget:self action:@selector(runMyEventQueryAndReloadData ) forControlEvents:UIControlEventValueChanged];
    [self.manageEventsTableView addSubview:self.myEventsTableRefreshControl];
    
    
    self.myFollowedEventsTableRefreshControl = [[UIRefreshControl alloc]init];
    [self.myFollowedEventsTableRefreshControl addTarget:self action:@selector(runMyFollowedEventQueryAndReloadData) forControlEvents:UIControlEventValueChanged];
    [self.myFollowedEventsTableView addSubview:self.myFollowedEventsTableRefreshControl];
    
    self.myEventsQuery = [PFQuery queryWithClassName:spadeClassActivity];
    self.myEventsQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [self.myEventsQuery whereKeyExists:spadeActivityToEvent];
    [self.myEventsQuery includeKey:spadeActivityToEvent];
    [self.myEventsQuery whereKey:spadeActivityFromUser equalTo:[PFUser currentUser]];
    [self.myEventsQuery whereKey:spadeActivityAction equalTo:spadeActivityActionCreatedEvent];
    [self.myEventsQuery orderByDescending:@"createdAt"];
    [self runMyEventQueryAndReloadData];
    
    self.followedEventsQuery = [PFQuery queryWithClassName:spadeClassActivity];
    self.followedEventsQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [self.followedEventsQuery includeKey:spadeActivityToEvent];
    [self.followedEventsQuery whereKeyExists:spadeActivityToEvent];
    [self.followedEventsQuery whereKey:spadeActivityFromUser equalTo:[PFUser currentUser]];
    [self.followedEventsQuery whereKey:spadeActivityAction equalTo:spadeActivityActionAttendingEvent];
    [self.followedEventsQuery orderByDescending:@"createdAt"];
    [self runMyFollowedEventQueryAndReloadData];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(presentCreateEventViewController)];
    
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor cloudsColor];
    self.eventSegmentController.tintColor = [UIColor cloudsColor];
    [self.eventSegmentController setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Copperplate" size:12]} forState:UIControlStateNormal];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   // [self runMyEventQueryAndReloadData];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define MY_EVENTS_SEGMENT 0
#define FOLLOWING_EVENTS 1
//#define CREATE_EVENT_SEGMENT 0

- (IBAction)eventSegmentChanged:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == MY_EVENTS_SEGMENT ) {
        //self.navigationItem.rightBarButtonItem = nil;
        self.myFollowedEventsTableView.hidden = YES;
        self.manageEventsTableView.hidden = NO;
        [self runMyEventQueryAndReloadData];
        
   /* }else if (sender.selectedSegmentIndex == CREATE_EVENT_SEGMENT){
        self.myFollowedEventsTableView.hidden = YES;
        self.manageEventsTableView.hidden  = YES;*/
        
    }else if (sender.selectedSegmentIndex == FOLLOWING_EVENTS){
        self.myFollowedEventsTableView.hidden = NO;
        self.manageEventsTableView.hidden  = YES;
        [self runMyFollowedEventQueryAndReloadData];
    }
        
}

#pragma mark MY EVENTS SEGMENT
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.manageEventsTableView) {
        return [self.myEvents count];
    }else{
        return [self.followedEvents count];
    }
    
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *myEventsCellIdentifier = @"myEventsCell";
    static NSString *followedEventsCellIdentifier = @"followedEventsCell";
    if (tableView == self.manageEventsTableView) {
        
    
        SpadeMyEventsCell *cell = [tableView dequeueReusableCellWithIdentifier:myEventsCellIdentifier];
        if (cell == nil) {
            cell = [[SpadeMyEventsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:myEventsCellIdentifier];
        }
        
        PFObject *activityObject = [self.myEvents objectAtIndex:indexPath.row];
        cell.eventNameLabel.text = [[activityObject objectForKey:spadeActivityToEvent] objectForKey:spadeEventName];
        cell.dateAndTimeLabel.text = [NSString stringWithFormat:@"%@ @ %@",[[activityObject objectForKey:spadeActivityToEvent]objectForKey:spadeEventWhen],[[activityObject objectForKey:spadeActivityToEvent]objectForKey:spadeEventTime]];

        
        return cell;
        
        
    }else{
        
        
        SpadeFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:followedEventsCellIdentifier];
        if (cell == nil) {
            cell = [[SpadeFollowCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:followedEventsCellIdentifier];
        }
        
        PFObject *activityLog = [self.followedEvents objectAtIndex:indexPath.row];
        cell.nameLabel.text =  [[activityLog objectForKey:spadeActivityToEvent]objectForKey:spadeEventName];
        cell.dateAndTimeLabel.text = [NSString stringWithFormat:@"%@ @ %@",[[activityLog objectForKey:spadeActivityToEvent]objectForKey:spadeEventWhen],[[activityLog objectForKey:spadeActivityToEvent]objectForKey:spadeEventTime]];

        return cell;
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.manageEventsTableView) {
        //Create Detail View
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        SpadeEventDetailViewController *eventDetail = [mainStoryboard   instantiateViewControllerWithIdentifier:@"eventDetailController"];
                                                       
        
        eventDetail.object = [self.myEvents objectAtIndex:indexPath.row];
                                                       [tableView cellForRowAtIndexPath:indexPath].selected = NO;
        
        //UINavigationController *tempNav = [[UINavigationController alloc]initWithRootViewController:eventDetail];
        [self.navigationController pushViewController:eventDetail animated:YES];
        
    }else{ //followedEventsTableView
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        SpadeEventDetailViewController *eventDetail = [mainStoryboard   instantiateViewControllerWithIdentifier:@"eventDetailController"];
        
        eventDetail.object = [self.followedEvents objectAtIndex:indexPath.row];
        [tableView cellForRowAtIndexPath:indexPath].selected = NO;
        
        //UINavigationController *tempNav = [[UINavigationController alloc]initWithRootViewController:eventDetail];
        [self.navigationController pushViewController:eventDetail animated:YES];
    
    
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}


#pragma mark { }


-(void)presentCreateEventViewController
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    //Create Detail View
    SpadeEventCreationViewController *createEvent = [mainStoryboard   instantiateViewControllerWithIdentifier:@"CreateEventViewController"];
    
    UINavigationController *tempNav = [[UINavigationController alloc]initWithRootViewController:createEvent];
    tempNav.navigationBar.tintColor = [UIColor purpleColor];
    tempNav.navigationBar.translucent  = NO;
    [self presentViewController:tempNav animated:YES completion:nil];
}

-(void)runMyEventQueryAndReloadData
{
    if (!_myEvents) _myEvents = [[NSMutableArray alloc]init];
    
    [self.myEventsQuery findObjectsInBackgroundWithBlock:^(NSArray *objectsFound, NSError *error){
        if (!error) {
           /* NSMutableArray *myEvents  = [[NSMutableArray alloc]init];
            for (PFObject *activityLog in objectsFound) {
                [myEvents addObject:[activityLog objectForKey:spadeActivityToEvent]];
            }*/
            [self.myEvents removeAllObjects];
            [self.myEvents addObjectsFromArray:objectsFound];
            [self.myEventsTableRefreshControl endRefreshing];
            [self.manageEventsTableView reloadData];
            
            
        }
        
    }];
    
    
}

-(void)runMyFollowedEventQueryAndReloadData
{
    if (!_followedEvents) _followedEvents = [[NSMutableArray alloc]init];
    
    [self.followedEventsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
    
        if (!error) {
            [self.followedEvents removeAllObjects];
            [self.followedEvents addObjectsFromArray:objects];
            [self.myFollowedEventsTableRefreshControl endRefreshing];
            [self.myFollowedEventsTableView reloadData];
        }
    
    }];


}


-(void)refresh:(UIRefreshControl *)refreshControl
{
    [refreshControl endRefreshing];
}


@end
