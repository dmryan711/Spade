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
    // Do any additional setup after loading the view.
     self.manageEventsTableView.hidden = YES;
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
    [self runMyEventQueryAndReloadData];
    
    self.followedEventsQuery = [PFQuery queryWithClassName:spadeClassActivity];
    self.followedEventsQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [self.followedEventsQuery includeKey:spadeActivityToEvent];
    [self.followedEventsQuery whereKeyExists:spadeActivityToEvent];
    [self.followedEventsQuery whereKey:spadeActivityFromUser equalTo:[PFUser currentUser]];
    [self.followedEventsQuery whereKey:spadeActivityAction equalTo:spadeActivityActionAttendingEvent];
    [self runMyFollowedEventQueryAndReloadData];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(presentCreateEventViewController)];
    
    
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
        NSLog(@"manage table count");
        return [self.myEvents count];
    }else{
        NSLog(@"following table count");
        return [self.followedEvents count];
    }
    
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.manageEventsTableView) {
        static NSString *CellIdentifier = @"Cell";
    
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        PFObject *activityObject = [self.myEvents objectAtIndex:indexPath.row];
        NSLog(@"Managed Activity Object: %@",activityObject);
        cell.textLabel.text = [[activityObject objectForKey:spadeActivityToEvent] objectForKey:spadeEventName];
        
        return cell;
        
        
    }else{
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        PFObject *activityLog = [self.followedEvents objectAtIndex:indexPath.row];
        NSLog(@"Following Event Object: %@",activityLog);
        cell.textLabel.text =  [[activityLog objectForKey:spadeActivityToEvent]objectForKey:spadeEventName];

        return cell;
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}





#pragma mark { }


-(void)presentCreateEventViewController
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    //Create Detail View
    SpadeEventCreationViewController *createEvent = [mainStoryboard   instantiateViewControllerWithIdentifier:@"CreateEventViewController"];
    
    UINavigationController *tempNav = [[UINavigationController alloc]initWithRootViewController:createEvent];
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
            NSLog(@"Ran");
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


-(void)createNotEnoughInformationAlert
{
    UIAlertView *notEnoughInformationAlert = [[UIAlertView alloc]initWithTitle:@"Not Enough Information" message:@"Your Event needs:\n a NAME\n a WHERE\n and a WHEN\n The image is optional, but first appearences are everything.\n Let that sink in..." delegate:nil cancelButtonTitle:@"Roger That" otherButtonTitles: nil];
    [notEnoughInformationAlert show];
}

-(void)refresh:(UIRefreshControl *)refreshControl
{
    [refreshControl endRefreshing];
}


@end
