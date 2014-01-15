//
//  SpadeChatViewController.m
//  Spade
//
//  Created by Devon Ryan on 1/7/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//
#import <Parse/Parse.h>
#import "SpadeChatViewController.h"
#import "SpadeChatCell.h"
#import "SpadeConstants.h"

@interface SpadeChatViewController ()
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) PFQuery *query;
@property (strong , nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *chatData;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UITextField *chatEntryField;
@property (weak, nonatomic) IBOutlet UIView *chatView;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation SpadeChatViewController



-(void)awakeFromNib
{
    self.query =  [PFQuery queryWithClassName:spadeClassChat];
    
}

#define RELOAD_INTERVAL 3
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"Loaded");
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
  
    
    self.title = [self.event objectForKey:spadeEventName];
    self.chatEntryField.delegate = self;
    self.chatEntryField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self registerForKeyboardNotifications];
    
    //Set Query and Run
    self.query.cachePolicy = kPFCachePolicyNetworkOnly;
    [self.query whereKey:spadeChatforEvent equalTo:self.event];
    [self.query includeKey:spadeChatFromUser];
    [self.query includeKey:spadeUserDisplayName];
    [self.query orderByDescending:@"createdAt"];
    
    //Add Refresh Controls
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(runQueryAndReloadData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Dismiss" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissChat)];
    
     [self runQueryAndReloadData];
    
  self.timer =  [NSTimer scheduledTimerWithTimeInterval:RELOAD_INTERVAL target:self selector:@selector(runQueryAndReloadData) userInfo:nil repeats:YES];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self freeKeyboardNotifications];
    NSLog(@"unloaded");
    
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
    if ([self.chatData count] == 0) {
        return 0;
    }else{
        
        return ([self.chatData count] *2)-1;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row % 2 == 1){
        return 40;
    }
    return 80;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger newIndex = (indexPath.row /2);
    static NSString *CellIdentifier = @"spadeChatCelll";
    static NSString *CellIdentifierUser = @"spadeUserChatCelll";
    static NSString *CellSpacer = @"spacer";
    if (indexPath.row % 2 == 1) { //odd
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellSpacer ];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellSpacer];
        }
        
        [cell.contentView setAlpha:0];
        cell.backgroundColor = [UIColor clearColor];
        [cell setUserInteractionEnabled:NO];
        
        return cell;
        
        
    }else if ([[[[self.chatData objectAtIndex:newIndex]objectForKey:spadeChatFromUser]objectId] isEqualToString:[[PFUser currentUser]objectId]]) {
        
        SpadeChatCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierUser];
        if (cell == nil) {
            cell = [[SpadeChatCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierUser];
        }
        
        PFObject *messageLog = [self.chatData objectAtIndex:newIndex];
        cell.userName.text = [[messageLog objectForKey:spadeChatFromUser]objectForKey:spadeUserDisplayName];
        cell.textString.text = [messageLog objectForKey:spadeChatMessage];
        
        return cell;
        
    }else{
        
        SpadeChatCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[SpadeChatCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        PFObject *messageLog = [self.chatData objectAtIndex:newIndex];
        cell.userName.text = [[messageLog objectForKey:spadeChatFromUser]objectForKey:spadeUserDisplayName];
        cell.textString.text = [messageLog objectForKey:spadeChatMessage];
        
        return cell;
        
    }
    
}

- (IBAction)viewTapped:(id)sender {
    
    [self.view endEditing:YES];
}
#pragma mark Chat TextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self sendPressed:nil];
    return YES;
}
-(void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


-(void) freeKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#define TABBAR_HEIGHT 57
-(void) keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"Keyboard was shown");
    NSDictionary* info = [aNotification userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [self.chatView setFrame:CGRectMake(self.chatView.frame.origin.x, self.chatView.frame.origin.y- keyboardFrame.size.height , self.chatView.frame.size.width, self.view.frame.size.height)];
    
    [UIView commitAnimations];
    
}

-(void) keyboardWillHide:(NSNotification*)aNotification
{
    NSLog(@"Keyboard will hide");
    NSDictionary* info = [aNotification userInfo];
    
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardFrame;
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&keyboardFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    [self.chatView setFrame:CGRectMake(self.chatView.frame.origin.x, self.chatView.frame.origin.y + keyboardFrame.size.height , self.chatView.frame.size.width, self.view.frame.size.height)];
    
    [UIView commitAnimations];
}
- (IBAction)sendPressed:(UIButton *)sender {
    
    PFObject *chatEntry = [PFObject objectWithClassName:spadeClassChat];
    [chatEntry setObject:self.chatEntryField.text forKey:spadeChatMessage];
    [chatEntry setObject:self.event forKey:spadeChatforEvent];
    [chatEntry setObject:[PFUser currentUser] forKey:spadeChatFromUser];
    [chatEntry saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded) {
           // [self runQueryAndReloadData];
        }
        
    }];
    
    self.chatEntryField.text =  @"";
    [self.view endEditing:YES];
    
    
}

#pragma mark { }
-(void)runQueryAndReloadData
{
    
    if (!_chatData) _chatData = [[NSMutableArray alloc]init];
    
    [self.query findObjectsInBackgroundWithBlock:^(NSArray *objectsFound, NSError *error){
        if (!error) {
            
            [self.chatData removeAllObjects];
            [self.chatData addObjectsFromArray:objectsFound];
            [self.tableView reloadData];
            [self.refreshControl  endRefreshing];
        }
        
    }];
    
}


-(void)dismissChat{
    [self dismissViewControllerAnimated:YES completion:nil];
    
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

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

@end
