//
//  MenuTableViewController.m
//  Spade
//
//  Created by Devon Ryan on 4/22/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "MenuTableViewController.h"
#import "SpadeContainerViewController.h"

@interface MenuTableViewController ()

@end

@implementation MenuTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *bufferView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * .65, self.view.frame.size.height)];
    UITapGestureRecognizer *dimissController = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissSelf)];
    [bufferView addGestureRecognizer:dimissController];
    [self.view addSubview:bufferView];
    
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(self.view.frame.size.width *.65, 0, self.view.frame.size.width *.35, self.view.frame.size.height)];
    [tableView setScrollEnabled:NO];
    [self.view addSubview:tableView];
    
    
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
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

-(void)dismissSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
    SpadeContainerViewController *presentingContainer = (SpadeContainerViewController *) self.presentingViewController;
    [UIView animateWithDuration:.5 animations:^(void){
        [presentingContainer.enclosingScrollView setFrame:CGRectMake(0, 0, presentingContainer.enclosingScrollView.frame.size.width, presentingContainer.enclosingScrollView.frame.size.height)];
    }];
   
    [presentingContainer.enclosingScrollView setUserInteractionEnabled:YES];

}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:; forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
