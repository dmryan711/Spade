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
@property (strong, nonatomic) PFQuery *venueQuery;
@property (weak, nonatomic) IBOutlet UISegmentedControl *eventSegmentController;
@property (weak, nonatomic) IBOutlet UIView *createEventView;
@property (weak, nonatomic) IBOutlet PFImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (strong,nonatomic) PFFile *fileForEventImage;
@property (weak, nonatomic) IBOutlet UIProgressView *imageLoadBar;
@property (strong,nonatomic) UIImagePickerController *imagePicker;

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

    
    
    
    self.venueQuery = [PFQuery queryWithClassName:spadeClassVenue];
    NSLog(@"Venue Query %@",[self.venueQuery description]);
    [self runQueryAndLoadData];
    [self setDatePicker];
    
    
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
        
    }else if (sender.selectedSegmentIndex == CREATE_EVENT_SEGMENT){
        /*self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Invite Friends" style:UIBarButtonItemStyleBordered target:self action:nil];*/
        self.createEventView.hidden = NO;
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
    }
    if (![self.venuePickerView isHidden]){
        self.venuePickerView.hidden = YES;
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
        [self.fileForEventImage saveInBackgroundWithBlock:^(BOOL succeeded , NSError *error){
            if (!error) {
                [self.eventImageView setFile:self.fileForEventImage];
                [self.eventImageView loadInBackground];
                
                //Process & Upload to Parse
                [SpadeUtility processProfilePictureData:UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage],0.5)];
            }
            if (succeeded) {
                //self.imageLoadBar.hidden = YES;
                self.imageLoadBar.progress = 0.0;
            }
            
        }
                                            progressBlock:^(int percentDone){
                                                [self.imageLoadBar setProgress:(float)percentDone];
                                                if (percentDone == 100) {
                                                    self.imageLoadBar.hidden = YES;
                                                }
                                            }];
        
        //Upload Photo To Parse
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





#pragma mark { }
-(void)runQueryAndLoadData
{
    [self.venueQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            NSLog(@"Ran Query");
            [self.venues addObjectsFromArray:objects];
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
    
    UIAlertView *eventCreationAlert = [[UIAlertView alloc]initWithTitle:@"Create Event" message:[NSString stringWithFormat:@"Please confirm the following event:\n Event Name: %@\n Where: %@\n When: %@",self.eventNameTextField.text,self.eventWhereLabel.text, self.eventWhenLabel.text] delegate:self cancelButtonTitle:@"Edit" otherButtonTitles: @"Create Event",nil];
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


@end
