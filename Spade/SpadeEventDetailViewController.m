//
//  SpadeEventDetailViewController.m
//  Spade
//
//  Created by Devon Ryan on 1/5/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "SpadeEventDetailViewController.h"
#import "SpadeChatCell.h"
#import "SpadeConstants.h"

@interface SpadeEventDetailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *chatEntryField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *chatData;
@property (strong, nonatomic) PFQuery *query;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@end

@implementation SpadeEventDetailViewController

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
    self.query =  [PFQuery queryWithClassName:spadeClassChat];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self toggleChat];
	// Do any additional setup after loading the view.
    self.title = [self.object objectForKey:spadeEventName];
    self.chatEntryField.delegate = self;
    self.chatEntryField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self registerForKeyboardNotifications];
    
    [self.query whereKey:spadeChatforEvent equalTo:self.object];
    [self.query includeKey:spadeChatFromUser];
    [self.query includeKey:spadeUserDisplayName];
    [self.query orderByDescending:@"createdAt"];
    
    //Set Query and Run
    [self runQueryAndReloadData];
    
    //Add Refresh Control
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.refreshControl addTarget:self action:@selector(runQueryAndReloadData) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
   
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Chat" style:UIBarButtonItemStyleBordered target:self action:@selector(toggleChat)];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self freeKeyboardNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark TableView Data Source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger newIndex = (indexPath.row /2);
    static NSString *CellIdentifier = @"spadeChatCelll";
    static NSString *CellIdentifierUser = @"spadeUserChatCelll";
    static NSString *CellSpacer = @"spacer";
    if (indexPath.row % 2 == 1) { //odd
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellSpacer ];
        if (cell == nil) {
            cell = [[SpadeChatCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellSpacer];
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
    if (indexPath.row % 2 == 1)
        return 40;
    return 80;
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
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y- keyboardFrame.size.height + TABBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height)];
    
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
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + keyboardFrame.size.height-TABBAR_HEIGHT , self.view.frame.size.width, self.view.frame.size.height)];
    
    [UIView commitAnimations];
}
- (IBAction)sendPressed:(UIButton *)sender {
    
        PFObject *chatEntry = [PFObject objectWithClassName:spadeClassChat];
        [chatEntry setObject:self.chatEntryField.text forKey:spadeChatMessage];
        [chatEntry setObject:self.object forKey:spadeChatforEvent];
        [chatEntry setObject:[PFUser currentUser] forKey:spadeChatFromUser];
        [chatEntry saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if (succeeded) {
                [self runQueryAndReloadData];
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
            NSLog(@"Ran");
            [self.chatData removeAllObjects];
            [self.chatData addObjectsFromArray:objectsFound];
            [self.tableView reloadData];
            [self.refreshControl  endRefreshing];
            NSLog(@"%@",[self.chatData description]);
        }
        
    }];


}

-(void)toggleChat
{
    if (![self.tableView isHidden]) {
        self.tableView.hidden = YES;
        self.chatEntryField.hidden = YES;
        self.sendButton.hidden = YES;
    }else{
        self.tableView.hidden = NO;
        self.chatEntryField.hidden = NO;
        self.sendButton.hidden = NO;
    
    
    }
    


}

@end
