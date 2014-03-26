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
    
    self.parseClassName = spadeClassVenue;
    self.textKey = @"Name";
    self.pullToRefreshEnabled = YES;
    self.paginationEnabled = NO;
    self.objectsPerPage = 3;
   // self.tableView.backgroundColor = [UIColor blackColor];
    
    

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
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Parse

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}


// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query includeKey:@"objectId"];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByAscending:spadeVenueSpendLevel];
    
    return query;
}



// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (SpadeVenueFollowCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"VenueCell";
    
    SpadeVenueFollowCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SpadeVenueFollowCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.delegate = self;
    cell.object = object;
    
    // Configure the cell
    if ([[[[[SpadeCache sharedCache]cache]objectForKey:spadeCache]objectForKey:spadeCacheVenues] containsObject:object]) {
        [cell.followButton setTitle:spadeFollowButtonTitleUnfollow forState:UIControlStateNormal];
    }else{
        [cell.followButton setTitle:spadeFollowButtonTitleFollow forState:UIControlStateNormal];
        
    }

    cell.nameLabel.text = [object objectForKey:spadeVenueName];
    cell.addressLabel.text  = [object objectForKey:spadeVenueAddress];
    
    return cell;
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
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if (indexPath.row < [self.objects count]) {
        
        //Set Object
        PFObject *venueSelection = [self.objects objectAtIndex:indexPath.row];
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


@end
