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
#import <MobileCoreServices/MobileCoreServices.h>

@interface SpadeEventController ()
@property (weak, nonatomic) IBOutlet UITextField *eventNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *eventWhereLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventWhenLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *venuePickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *whenPickerView;
@property (strong, nonatomic) NSMutableArray *venues;
@property (strong, nonatomic) NSMutableArray *myEvents;
@property (strong, nonatomic) PFQuery *venueQuery;
@property (strong, nonatomic) PFQuery *myEventsQuery;
@property (weak, nonatomic) IBOutlet UISegmentedControl *eventSegmentController;
@property (weak, nonatomic) IBOutlet UIView *createEventView;
@property (weak, nonatomic) IBOutlet PFImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (strong,nonatomic) PFFile *fileForEventImage;
@property (weak, nonatomic) IBOutlet UIProgressView *imageLoadBar;
@property (strong,nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UITableView *manageEventsTableView;
@property (strong, nonatomic) UIRefreshControl *myEventsTableRefreshControl;
@property (weak, nonatomic) IBOutlet UILabel *myEventsLabel;
@property int venueIndex;

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

-(void)awakeFromNib
{
    if (!_venues) _venues = [[NSMutableArray alloc]init];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.eventNameTextField.delegate = self;
    self.venuePickerView.hidden = YES;
    self.whenPickerView.hidden = YES;
    self.imageLoadBar.hidden = YES;
    self.manageEventsTableView.hidden = YES;
    self.myEventsLabel.hidden = YES;
    
    //Set Refresh Controls
    self.myEventsTableRefreshControl = [[UIRefreshControl alloc]init];
    [self.myEventsTableRefreshControl addTarget:self action:@selector(runMyEventQueryAndReloadData ) forControlEvents:UIControlEventValueChanged];
    [self.manageEventsTableView addSubview:self.myEventsTableRefreshControl];
    
    self.venueQuery = [PFQuery queryWithClassName:spadeClassVenue];
    NSLog(@"Venue Query %@",[self.venueQuery description]);
    [self runVenueQueryAndLoadData];
    [self setDatePicker];
    
    self.myEventsQuery = [PFQuery queryWithClassName:spadeClassEvent];
    [self runMyEventQueryAndReloadData];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define MY_EVENTS_SEGMENT 1
#define FOLLOWING_EVENTS 2
#define CREATE_EVENT_SEGMENT 0

- (IBAction)eventSegmentChanged:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == MY_EVENTS_SEGMENT ) {
        //self.navigationItem.rightBarButtonItem = nil;
        self.createEventView.hidden = YES;
        self.myEventsLabel.hidden = NO;
        self.manageEventsTableView.hidden = NO;
        [self runMyEventQueryAndReloadData];
        
    }else if (sender.selectedSegmentIndex == CREATE_EVENT_SEGMENT){
        /*self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Invite Friends" style:UIBarButtonItemStyleBordered target:self action:nil];*/
        self.createEventView.hidden = NO;
        self.manageEventsTableView.hidden  = YES;
        self.myEventsLabel.hidden = YES;
    }
}

#pragma mark CREATE EVENT SEGMENT
- (IBAction)whereButtonPressed:(id)sender {
    
    if (!self.venuePickerView.isHidden) { //Venue Picker is Showing
       
        self.venuePickerView.hidden = YES; // Hide it
        self.saveButton.hidden = NO; // Show Save Button
        
    }else{ //Venue Picker is Hidden
        //Hide the other elements
        if (!self.whenPickerView.isHidden) {
            self.whenPickerView.hidden = YES;
        }
        if (!self.saveButton.isHidden) {
            self.saveButton.hidden = YES;
        }
        if ([self.eventNameTextField isFirstResponder]) {
            [self.eventNameTextField resignFirstResponder];
        }
        self.venuePickerView.hidden = NO; //Show it
        
    }
}


- (IBAction)whenButtonPressed:(id)sender {
    
    if (!self.whenPickerView.isHidden) { // When Picker is showing
        
        self.whenPickerView.hidden = YES; // Hide it
        self.saveButton.hidden = NO; //Show Save Button
        
    }else{ //When Picker is hidden
        //Hide the other elements
        if (!self.venuePickerView.isHidden) {
            self.venuePickerView.hidden = YES;
        }
        if (!self.saveButton.isHidden) {
            self.saveButton.hidden = YES;
        }
        if ([self.eventNameTextField isFirstResponder]) {
            [self.eventNameTextField resignFirstResponder];
        }
        self.whenPickerView.hidden = NO; //Show it
    }
}
- (IBAction)viewTapped:(id)sender {
    if ([self.eventNameTextField isFirstResponder]) {
        [self.view endEditing:YES];
    }
    if (![self.whenPickerView isHidden]){
        self.whenPickerView.hidden = YES;
        self.saveButton.hidden = NO;
    }
    if (![self.venuePickerView isHidden]){
        self.venuePickerView.hidden = YES;
        self.saveButton.hidden = NO;
    }
}

#pragma mark TextField Delegation
- (BOOL)textFieldShouldReturn:(UITextField *)textField{ // called when 'return' key pressed. return NO to ignore.
    [textField resignFirstResponder];
    self.saveButton.hidden = NO;
 
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.whenPickerView.hidden = YES;
    self.venuePickerView.hidden =YES;

}

#pragma mark Picker View Data Source Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.venues count];

}

#pragma mark Picker View Delegate Methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[self.venues objectAtIndex:row] objectForKey:spadeVenueName];

}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.venueIndex = row;
    self.eventWhereLabel.text = [[self.venues objectAtIndex:row]objectForKey:spadeVenueName];

}

#pragma mark Button Methods
- (IBAction)imageButtonPressed:(UIButton *)sender {
    
    
    UIActionSheet *editProfilePictureSelection = [[UIActionSheet alloc]initWithTitle:@"Select Picture Source" delegate:self cancelButtonTitle:@"Nevermind" destructiveButtonTitle:nil otherButtonTitles:@"Choose From Library",@"Take a Photo", nil];
    
    [editProfilePictureSelection showFromTabBar:self.tabBarController.tabBar];
}

- (IBAction)saveButtonPressed:(UIButton *)sender {
    if ([self.eventNameTextField.text isEqualToString:@""] || [self.eventWhenLabel.text isEqualToString:spadeEventPlaceHolderWhenLabel] || [self.eventWhereLabel.text isEqualToString:spadeEventPlaceHolderWhereLabel]) {
        [self createNotEnoughInformationAlert];
    }else{
        [self createEventCreationConfirmationAlert];
    }
}

#pragma mark UIImagePicker Controller Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //Set User Changed Picture Flag so we don't overwrite with Facebook Image on each Log out
    if (![[NSUserDefaults standardUserDefaults]boolForKey:spadePicFLag] ){
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:spadePicFLag];
    }
    
    //UnHide the Image Load Process Bar
    self.imageLoadBar.hidden = NO;
    
    NSString *imageType = (NSString *)kUTTypeImage;
    if (![[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:imageType]) { // User did not select an Image, throw an alert
        
        //Dismiss Image Picker & Show ALert
        [self dismissViewControllerAnimated:YES completion:^(void) {
            UIAlertView *didNotSelectImage = [[UIAlertView alloc]initWithTitle:@"Pictures Only!" message:@"The image you have selected is not a picture" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [didNotSelectImage show];
            
        }];
    }else{
        //Switch Profile Image Locally & Animate Progress Bar
        self.fileForEventImage = [PFFile fileWithData:UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 0.5)];

                [self.eventImageView setFile:self.fileForEventImage];
                [self.eventImageView loadInBackground];
                
        
        //Dimiss Photo View
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark Action Sheet Delegate Methods
#define CAMERA_ROLL 0
#define TAKE_PHOTO 1
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)actionSheetCancel:(UIActionSheet *)actionSheet{}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet  // before animation and showing view
{}
- (void)didPresentActionSheet:(UIActionSheet *)actionSheet  // after animation
{}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex // before animation and hiding view
{
    if (buttonIndex == CAMERA_ROLL) { //Camera Roll Was Selected
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){ // Selected Media Type is Available
            
            self.imagePicker = [[UIImagePickerController alloc]init];
            self.imagePicker.delegate = self;
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePicker.sourceType];
            [self presentViewController:self.imagePicker animated:YES completion:nil];
            
        }else{//Selected Media Type is not Available
            [self createAndDisplayMediaSourceAlert];
        }
    }else if (buttonIndex == TAKE_PHOTO){
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePicker = [[UIImagePickerController alloc]init];
            self.imagePicker.delegate = self;
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePicker.sourceType];
            [self presentViewController:self.imagePicker animated:YES completion:nil];
            
        }else{//No Camera is available
            [self createAndDisplayMediaSourceAlert];
        }
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex  // after animation
{}


#define EDIT_BUTTON 0
#define SUBMIT_BUTTON 1
#pragma mark Alert View Delegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:spadeAlertViewTitleConfirmEvent]) {
        
        if (buttonIndex == SUBMIT_BUTTON) {
            
            [SpadeUtility user:[PFUser currentUser] creatingEventWithName:self.eventNameTextField.text forVenue:[self.venues objectAtIndex:self.venueIndex] forWhen:self.eventWhenLabel.text withImageFile:self.fileForEventImage];
        }
    }

}

#pragma mark MY EVENTS SEGMENT
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.myEvents count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    PFObject *object = [self.myEvents objectAtIndex:indexPath.row];
    NSLog(@"%@",[object description]);
    cell.textLabel.text = [object objectForKey:spadeEventName];
    return cell;
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}





#pragma mark { }

-(void)runMyEventQueryAndReloadData
{
    if (!_myEvents) _myEvents = [[NSMutableArray alloc]init];
    
    [self.myEventsQuery findObjectsInBackgroundWithBlock:^(NSArray *objectsFound, NSError *error){
        if (!error) {
            NSLog(@"Ran");
            [self.myEvents removeAllObjects];
            [self.myEvents addObjectsFromArray:objectsFound];
            [self.myEventsTableRefreshControl endRefreshing];
            [self.manageEventsTableView reloadData];
            
            
        }
        
    }];
    
    
}


#pragma mark { }
-(void)runVenueQueryAndLoadData
{
    [self.venueQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            NSLog(@"Ran Query");
           
            [self.venues addObjectsFromArray:objects];
             NSLog(@"%@",[self.venues description]);
            [self.venuePickerView reloadAllComponents];
        }
    
    }];

}

-(void)createAndDisplayMediaSourceAlert
{
    UIAlertView *mediaTypeNotAvailable = [[UIAlertView alloc]initWithTitle:@"Sorry" message:@"The Media Type you have selected is not available!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [mediaTypeNotAvailable show];
    
}

-(void)createEventCreationConfirmationAlert
{
    
    UIAlertView *eventCreationAlert = [[UIAlertView alloc]initWithTitle:spadeAlertViewTitleConfirmEvent message:[NSString stringWithFormat:@"Please confirm the following event:\n Event Name: %@\n Where: %@\n When: %@",self.eventNameTextField.text,self.eventWhereLabel.text, self.eventWhenLabel.text] delegate:self cancelButtonTitle:@"Edit" otherButtonTitles: @"Create Event",nil];
    [eventCreationAlert show];
}

-(void)createNotEnoughInformationAlert
{
    UIAlertView *notEnoughInformationAlert = [[UIAlertView alloc]initWithTitle:@"Not Enough Information" message:@"Your Event needs:\n a NAME\n a WHERE\n and a WHEN\n The image is optional, but first appearences are everything.\n Let that sink in..." delegate:nil cancelButtonTitle:@"Roger That" otherButtonTitles: nil];
    [notEnoughInformationAlert show];
}

-(void)setDatePicker
{
    self.whenPickerView.minimumDate = [NSDate date];
    
    [self.whenPickerView addTarget:self action:@selector(changeWhenLabel) forControlEvents:UIControlEventValueChanged];
}

-(void)changeWhenLabel
{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc]init];
    [timeFormat setDateFormat:@"hh:mm a"];
    
    NSString *dateString = [dateFormat stringFromDate:[self.whenPickerView date]];
    NSString *timeString = [timeFormat stringFromDate:[self.whenPickerView date]];
  
    self.eventWhenLabel.text =  [NSString stringWithFormat:@"%@   at   %@",dateString,timeString];
                                                             
}

-(void)refresh:(UIRefreshControl *)refreshControl
{
    [refreshControl endRefreshing];
}


@end
