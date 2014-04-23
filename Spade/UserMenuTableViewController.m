//
//  UserMenuTableViewController.m
//  Spade
//
//  Created by Devon Ryan on 4/16/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "UserMenuTableViewController.h"
#import "SpadeContainerViewController.h"

#define BUFFER_CELL_INDEX 0
#define BUFFER_PERCENTAGE .15
#define LAST_MENU_ITEM 3
#define AMOUNT_OF_MENU_ITEMS 4
#define MENU_ITEM_HEIGHT 75

@interface UserMenuTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *menuItems;
@property (strong, nonatomic)UITableView *tableView;

@end

@implementation UserMenuTableViewController

static NSString *CellIdenifier = @"Cell";

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
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdenifier];
    UIView *bufferView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * .65, self.view.frame.size.height)];
    
    UITapGestureRecognizer *dimissController = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bufferTapped)];
    [bufferView addGestureRecognizer:dimissController];
    [self.view addSubview:bufferView];
    
    
    
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(self.view.frame.size.width *.65, 0, self.view.frame.size.width *.35, self.view.frame.size.height)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setScrollEnabled:NO];
    
   
    
    UIView *shadowView = [[UIView alloc]initWithFrame:CGRectMake(self.tableView.bounds.origin.x,self.tableView.bounds.origin.y,3,self.tableView.frame.size.height)];
    
    shadowView.backgroundColor = [UIColor blackColor];
    shadowView.alpha = .4;
    [self.tableView addSubview:shadowView];

    [self.view addSubview:self.tableView];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"grey_wash_wall"]];
    [self.tableView setScrollEnabled:NO];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    if (!_menuItems) _menuItems = @[@"",@"Chat",@"Map",@"Friends",@"Venues",@"Options",@"Logout"];
    
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    
    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:CellIdenifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdenifier];
    }
    
    if (indexPath.row == self.menuItems.count - 1) {
        cell.backgroundColor = [UIColor redColor];
      
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = [self.menuItems objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:18];
        cell.textLabel.textColor = [UIColor blackColor];
    }else{
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = [self.menuItems objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:18];
        cell.textLabel.textColor = [UIColor whiteColor];
    
    }
    // Configure the cell...

    
    NSLog(@"Cell Label:%@",[self.menuItems objectAtIndex:indexPath.row]);
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.row == BUFFER_CELL_INDEX) {
        return tableView.frame.size.height * BUFFER_PERCENTAGE;
    }else
        return 75;
    
 

}

-(void)bufferTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
    SpadeContainerViewController *presentingContainer = (SpadeContainerViewController *) self.presentingViewController;
    [UIView animateWithDuration:.5 animations:^(void){
        [presentingContainer.enclosingScrollView setFrame:CGRectMake(0, 0, presentingContainer.enclosingScrollView.frame.size.width, presentingContainer.enclosingScrollView.frame.size.height)];
    }];
    
    [presentingContainer.enclosingScrollView setUserInteractionEnabled:YES];
    
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
