//
//  UserMenuTableViewController.m
//  Spade
//
//  Created by Devon Ryan on 4/16/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "UserMenuTableViewController.h"
#import <Parse/Parse.h>
#import "SpadeProfileController.h"
#import "SpadeConstants.h"
#import "MenuTableViewCell.h"
#import "UIColor+FlatUI.h"

#define BUFFER_CELL_INDEX 0
#define BUFFER_PERCENTAGE .25
#define LAST_MENU_ITEM 3
#define AMOUNT_OF_MENU_ITEMS 4
#define MENU_ITEM_HEIGHT 75
#define PROFILE 1
#define FIND_FRIENDS 2
#define LOGOUT 3
#define DISMISS 5
#define STORYBOARD   [UIStoryboard storyboardWithName:@"Main" bundle: nil]


@interface UserMenuTableViewController ()

@property (strong, nonatomic) NSArray *menuItems;

@end

@implementation UserMenuTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(void)awakeFromNib
{
    _menuItems = @[@"",@"Profile",@"Find Friends",@"Logout",@"",@"Dismiss"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"grey_wash_wall"]];
    [self.tableView setScrollEnabled:NO];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"Count:%lu",(unsigned long)self.menuItems.count);
    return self.menuItems.count;
}


- (MenuTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserMenuCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    if (indexPath.row == BUFFER_CELL_INDEX) {
        [cell setUserInteractionEnabled:NO];
        cell.contentView.alpha = 0;
    }
    if (indexPath.row > LAST_MENU_ITEM && indexPath.row < self.menuItems.count - 1) [cell setUserInteractionEnabled:NO];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectedColor = [UIColor wisteriaColor];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = [self.menuItems objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Copperplate-Bold" size:20];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.alpha = 1.0f;
    
    NSLog(@"Cell Label:%@",[self.menuItems objectAtIndex:indexPath.row]);
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.row == BUFFER_CELL_INDEX) {
        return tableView.frame.size.height * BUFFER_PERCENTAGE;
    }else if(indexPath.row <= LAST_MENU_ITEM){
        return 75;
    }else if (indexPath.row > LAST_MENU_ITEM && indexPath.row < self.menuItems.count - 1){
        return tableView.frame.size.height - ((tableView.frame.size.height * BUFFER_PERCENTAGE) + (AMOUNT_OF_MENU_ITEMS * MENU_ITEM_HEIGHT));
    }else{
    
        return 75;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == PROFILE) {
        //Display Profile
        //Create Detail View
        SpadeProfileController *profileDetail = [STORYBOARD   instantiateViewControllerWithIdentifier:@"profileDetailView"];
        PFUser *user = [PFUser currentUser];
        
        [profileDetail setUserName:[user objectForKey:spadeUserDisplayName]];
        
        [self presentViewController:profileDetail animated:YES completion:nil];
        
    }else if (indexPath.row == FIND_FRIENDS){
        
        
    }else if (indexPath.row == LOGOUT){
       // [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        
        
    
    }else if (indexPath.row == DISMISS){
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    }

}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [[SpadePresentTransistion alloc]init];
    
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[SpadeDismissTransistion alloc] init];
}


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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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
