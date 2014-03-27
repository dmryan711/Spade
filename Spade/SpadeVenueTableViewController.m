//
//  SpadeVenueTableViewController.m
//  Spade
//
//  Created by Devon Ryan on 12/14/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import "SpadeVenueTableViewController.h"
#import "SpadeVenueDetailViewController.h"
#import "SpadeUtility.h"
#import "SpadeCache.h"
#import "SpadeConstants.h"
#import "UINavigationBar+FlatUI.h"
#import "UIColor+FlatUI.h"

@interface SpadeVenueTableViewController ()

@property(strong,nonatomic)NSMutableArray *searchedObjects;
@property(strong,nonatomic)NSMutableArray *venueObjects;

@property (strong, nonatomic) PFQuery *searchQuery;
@property (strong, nonatomic) PFQuery *venueQuery;

@end

@implementation SpadeVenueTableViewController

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

    if (!_venueObjects) _venueObjects = [[NSMutableArray alloc] init];
    if (!_searchedObjects) _searchedObjects = [[NSMutableArray alloc] init];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"Venues";
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
     [UIColor whiteColor],NSForegroundColorAttributeName,
     [UIColor wisteriaColor],NSBackgroundColorAttributeName,[UIFont fontWithName:@"Copperplate" size:26],NSFontAttributeName, nil];
     self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor blendedColorWithForegroundColor:[UIColor blackColor] backgroundColor:[UIColor wisteriaColor] percentBlend:.6]];
    
    [self.tableView setContentOffset:CGPointMake(0,44) animated:YES];
    
    self.venueQuery = [PFQuery queryWithClassName:spadeClassVenue];
    self.venueQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [self.venueQuery orderByDescending:spadeVenueSpendLevel];
    
    [self runQueryandLoadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (SpadeVenueFollowCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"VenueCell";
    
    SpadeVenueFollowCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SpadeVenueFollowCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.delegate = self;
    PFObject *object;
    
    if (tableView == self.searchDisplayController.searchResultsTableView){
        object = [self.searchedObjects objectAtIndex:indexPath.row];
        
    }else{
        
        object = [self.venueObjects objectAtIndex:indexPath.row];
    }
        cell.object = object;
        
        if ([[[[[SpadeCache sharedCache]cache]objectForKey:spadeCache]objectForKey:spadeCacheVenues] containsObject:object]) {
            [cell.followButton setTitle:spadeFollowButtonTitleUnfollow forState:UIControlStateNormal];
        }else{
            [cell.followButton setTitle:spadeFollowButtonTitleFollow forState:UIControlStateNormal];
            
        }
        
        cell.nameLabel.text = [object objectForKey:spadeVenueName];
        cell.addressLabel.text  = [object objectForKey:spadeVenueAddress];
        
         return cell;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchedObjects count];
        
    } else {
        return [self.venueObjects count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

/*
 // Override if you need to change the ordering of objects in the table.
 - (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
 return [objects objectAtIndex:indexPath.row];
 }
 */

/*
 // Override to customize the look of the cell that allows the user to load the next page of objects.
 // The default implementation is a UITableViewCellStyleDefault cell with simple labels.
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
 static NSString *CellIdentifier = @"NextPage";
 
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
 if (cell == nil) {
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
 }
 
 cell.selectionStyle = UITableViewCellSelectionStyleNone;
 cell.textLabel.text = @"Load more...";
 
 return cell;
 }
 */

#pragma mark - Table view data source

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.searchDisplayController.searchResultsTableView){
        if (indexPath.row < [self.searchedObjects count]) {
            PFObject *venueSelection = [self.searchedObjects objectAtIndex:indexPath.row];
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            //Create Detail View
            SpadeVenueDetailViewController *venueDetail = [mainStoryboard   instantiateViewControllerWithIdentifier:@"venueDetailController"];
            
            [venueDetail setVenue:venueSelection]; //Hand Off Vnue Object
            
            //Check Cache to see if user is following the venue already
            
            if ([[[[[SpadeCache sharedCache]cache]objectForKey:spadeCache]objectForKey:spadeCacheVenues] containsObject:venueSelection]) {
                venueDetail.isFollowing = YES;
            }
            
            //FIRE
            [self.navigationController pushViewController:venueDetail animated:YES];
            
        }
    }else{
        if (indexPath.row < [self.venueObjects count]) {
            PFObject *venueSelection = [self.venueObjects objectAtIndex:indexPath.row];
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            //Create Detail View
            SpadeVenueDetailViewController *venueDetail = [mainStoryboard   instantiateViewControllerWithIdentifier:@"venueDetailController"];
            
            [venueDetail setVenue:venueSelection]; //Hand Off Vnue Object
            
            //Check Cache to see if user is following the venue already
            
            if ([[[[[SpadeCache sharedCache]cache]objectForKey:spadeCache]objectForKey:spadeCacheVenues] containsObject:venueSelection]) {
                venueDetail.isFollowing = YES;
            }
            
            //FIRE
            [self.navigationController pushViewController:venueDetail animated:YES];
        }
    }
    

}




#pragma mark Cell Delegate Methods
-(void)followButtonWasPressedForCell:(SpadeFollowCell *)cell
{
    if ([cell.followButton.titleLabel.text isEqualToString:spadeFollowButtonTitleFollow]) {
        [cell.followButton setTitle:spadeFollowButtonTitleUnfollow forState:UIControlStateNormal];
        //set cache to follow venue
        [[SpadeCache sharedCache]addFollowedVenue:cell.object];
        

        
    }else if ([cell.followButton.titleLabel.text isEqualToString:spadeFollowButtonTitleUnfollow]){
        [cell.followButton setTitle:spadeFollowButtonTitleFollow forState:UIControlStateNormal];
        
        //set cache to remove user from follow list
        [[SpadeCache sharedCache]removeFollowedVenue:cell.object];
        
        
    }else{
        NSError *error = [NSError errorWithDomain:@"Cell Title Not Matching Follow/Unfollow" code:1 userInfo:@{@"Title": [NSString stringWithFormat:@"Button Title: %@", cell.nameLabel.text ]}];
        NSLog(@"Error %@",error);
        
    }

}

#pragma mark Search Protocol

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:  (NSString *)searchString {
    [self filterResults:searchString];
    return YES;
}

#pragma mark { }

-(void)runQueryandLoadData
{
    
    [self.venueQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [self.venueObjects removeAllObjects];
        [self.venueObjects addObjectsFromArray:objects];
        [self.tableView reloadData];
    
    }];
    
}


- (void)filterResults:(NSString *)searchTerm {
    [self.searchedObjects removeAllObjects];
    
    PFQuery *query = [PFQuery queryWithClassName: spadeClassVenue];
    [query includeKey:@"objectId"];
    [query whereKey:spadeVenueName containsString:searchTerm];
    [query orderByDescending:spadeVenueSpendLevel];
    
   [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
       [self.searchedObjects addObjectsFromArray:objects];
       //self.searchDisplayController.searchResultsTableView
       [self.searchDisplayController.searchResultsTableView reloadData];
    }];
    
}




@end
