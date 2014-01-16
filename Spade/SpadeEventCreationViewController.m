//
//  SpadeEventCreationViewController.m
//  Spade
//
//  Created by Devon Ryan on 1/7/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import <Parse/Parse.h>
#import "SpadeEventCreationViewController.h"
#import "SpadeEventCell.h"
#import "SpadeEventVenueCell.h"
#import "SpadeNameCell.h"
#import "SpadeConstants.h"
#import <MobileCoreServices/MobileCoreServices.h>
@interface SpadeEventCreationViewController ()

@property int numberOFVenueRows;
@property int numberOFTimeRows;
@property int numberOfDateRows;
@property int numberOfPhotoRows;

@property (strong, nonatomic) PFQuery *venueQuery;
@property (strong, nonatomic) NSMutableArray *venues;
@property (strong, nonatomic)  UIPickerView *venuePickerView;
@property (strong, nonatomic) NSString *venuePickerSelection;
@property (strong, nonatomic) NSString *nameSelection;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIDatePicker *timePicker;
@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (weak, nonatomic) SpadeNameCell *nameCell;
@property (weak, nonatomic) SpadeEventCell *venueCell;
@property (weak, nonatomic) SpadeEventCell *dateCell;
@property (weak, nonatomic) SpadeEventCell *timeCell;
@property (weak,nonatomic) SpadePhotoCell *photoCell;


@end

@implementation SpadeEventCreationViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.numberOFVenueRows = 1;
    self.numberOfPhotoRows = 1;
    self.numberOfDateRows  = 1;
    self.numberOFTimeRows = 1;
    
    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.venueQuery = [PFQuery queryWithClassName:spadeClassVenue];
    self.venueQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [self.venueQuery orderByAscending:spadeVenueName];
    
    [self runVenueQueryAndLoadData];


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

#define NAME_SECTION 0
#define VENUE_SECTION 1
#define DATE_SECTION 2
#define TIME_SETION 3
#define PHOTO_SECTION 4

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == NAME_SECTION) {
        return 1;
       
    }else if (section == VENUE_SECTION){
        return self.numberOFVenueRows;
    }else if (section == DATE_SECTION){
        return self.numberOfDateRows;
    }else if (section == TIME_SETION){
        return self.numberOFTimeRows;
    }else {//if (section == PHOTO_SECTION){
        return 1;
        
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *NameCellIdentifier = @"EventNameLabelIdentifier";
    static NSString *LabelCellIdentifier = @"LabelIdentifier";
    static NSString *PhotoCellIdentifier = @"EventUploadImageIdentifier";

    if (indexPath.section == NAME_SECTION ) {
        self.nameCell = [tableView dequeueReusableCellWithIdentifier:NameCellIdentifier forIndexPath:indexPath];
        return self.nameCell;
    
    }else if (indexPath.section == VENUE_SECTION){
        if (indexPath.row > 0) {
            self.venuePickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, 320, 180)];
            
            self.venuePickerView.delegate = self;
            self.venuePickerView.dataSource = self;
            [self.venuePickerView reloadAllComponents];
            
            SpadeEventVenueCell *cell = [[SpadeEventVenueCell alloc]initWithFrame:CGRectMake(0, 0, 320, 180)];
            cell.value.text = self.venuePickerSelection;
            [cell addSubview:self.venuePickerView];
            [self.venuePickerView selectRow:[self.venues count]/2 inComponent:0 animated:YES];
            self.venuePickerSelection = [[self.venues objectAtIndex:[self.venues count]/2] objectForKey:spadeVenueName];
            return cell;
        }
        self.venueCell = [tableView dequeueReusableCellWithIdentifier:LabelCellIdentifier forIndexPath:indexPath];
        self.venueCell.label.text = @"Venue:";
        return self.venueCell;
        
    }else if (indexPath.section == DATE_SECTION){
        if (indexPath.row > 0) {
            self.datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0,0,320,100)];
            self.datePicker.minimumDate = [NSDate date];
            self.datePicker.datePickerMode = UIDatePickerModeDate;
            SpadeEventCell *cell = [[SpadeEventCell alloc]initWithFrame:CGRectMake(0, 0, 320, 100)];
            [cell addSubview:self.datePicker];
            return cell;
            
        }
        self.dateCell = [tableView dequeueReusableCellWithIdentifier:LabelCellIdentifier forIndexPath:indexPath];
        self.dateCell.label.text = @"Date:";
        return self.dateCell;
        
    }else if (indexPath.section == TIME_SETION){
        if (indexPath.row > 0) {
            self.timePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0,0,320,100)];
            self.timePicker.minimumDate = [NSDate date];
            self.timePicker.datePickerMode = UIDatePickerModeTime;
            SpadeEventCell *cell = [[SpadeEventCell alloc]initWithFrame:CGRectMake(0, 0, 320, 100)];
            [cell addSubview:self.timePicker];
            return cell;
        }

        self.timeCell = [tableView dequeueReusableCellWithIdentifier:LabelCellIdentifier forIndexPath:indexPath];
        self.timeCell.label.text = @"Time:";
        return self.timeCell;
    
    
    }else{ //if (indexPath.section == PHOTO_SECTION){
    
        self.photoCell = [tableView dequeueReusableCellWithIdentifier:PhotoCellIdentifier forIndexPath:indexPath];
        self.photoCell.delegate = self;
        return self.photoCell;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == NAME_SECTION) {
        return @"Enter a Name";
    }else if (section == VENUE_SECTION){
        return @"Select a Venue";
    }else if (section == DATE_SECTION){
        return @"Select a Date";
    }else if (section == TIME_SETION){
        return @"Select a Time";
    
    }else{ //if (section == PHOTO_SECTION){
        return @"Upload a Photo (Optional)";
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ((indexPath.row == 1 && indexPath.section == VENUE_SECTION) || (indexPath.row == 1 && indexPath.section == DATE_SECTION) || (indexPath.row == 1 && indexPath.section == TIME_SETION)) {
        return 190;
    }else if (indexPath.section == PHOTO_SECTION){
        return 120;
    
    }else{
        return 44;
        
    }
}

#pragma mark Spade Photo Delegate
-(void)uploadPhotoButtonPressed
{
    
    UIActionSheet *eventImage = [[UIActionSheet alloc]initWithTitle:@"Select Picture Source" delegate:self cancelButtonTitle:@"Nevermind" destructiveButtonTitle:nil otherButtonTitles:@"Choose From Library",@"Take a Photo", nil];
    
    [eventImage showFromTabBar:self.tabBarController.tabBar];

}

#pragma mark Chat TextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    [self changeNameCell];
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == NAME_SECTION) {
        
        [self changeNameCell];
        
    }else if (indexPath.section == VENUE_SECTION){
        //[self.venueCell toggleShowCell];
        [self changeVenueCell];
        [self.tableView cellForRowAtIndexPath:indexPath].selected  = NO;

      
    }else if (indexPath.section == DATE_SECTION){
        //[self.dateCell toggleShowCell];
        [self changeDateCell];
        [self.tableView cellForRowAtIndexPath:indexPath].selected  = NO;
        
        
    }else if (indexPath.section == TIME_SETION){
        //[self.timeCell toggleShowCell];
        [self changeTimeCell];
        [self.tableView cellForRowAtIndexPath:indexPath].selected  = NO;
        
    
    }else{ //if (indexpathsection == PHOTO_SECTION){
        
    }
}

#pragma mark UIImagePicker Controller Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    
    //UnHide the Image Load Process Bar
    self.photoCell.imageLoadBar.hidden = NO;
    
    NSString *imageType = (NSString *)kUTTypeImage;
    if (![[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:imageType]) { // User did not select an Image, throw an alert
        
        //Dismiss Image Picker & Show ALert
        [self dismissViewControllerAnimated:YES completion:^(void) {
            UIAlertView *didNotSelectImage = [[UIAlertView alloc]initWithTitle:@"Pictures Only!" message:@"The image you have selected is not a picture" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [didNotSelectImage show];
            
        }];
    }else{
        //Switch Profile Image Locally & Animate Progress Bar
        self.photoCell.fileForEventImage = [PFFile fileWithData:UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 0.5)];
        
        [self.photoCell.eventImageView setFile:self.photoCell.fileForEventImage];
        [self.photoCell.eventImageView loadInBackground];
        
        
        //Dimiss Photo View
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
    self.venuePickerSelection = [[self.venues objectAtIndex:row] objectForKey:spadeVenueName];
}


#pragma mark {  }
-(void)changeNameCell
{
    self.nameCell.selected = NO;
    if ([self.nameCell.nameLabel isHidden]) {
        if ([self.nameCell.nameEntry isFirstResponder]) {
            [self.nameCell.nameEntry resignFirstResponder];
        }
        self.nameCell.nameLabel.text = self.nameCell.nameEntry.text;
        self.nameCell.nameEntry.hidden = YES;
        self.nameCell.nameLabel.hidden = NO;
    }else{
        self.nameCell.nameEntry.text = self.nameCell.nameLabel.text;
        self.nameCell.nameLabel.hidden = YES;
        self.nameCell.nameEntry.hidden = NO;
        [self.nameCell.nameEntry becomeFirstResponder];
        [self removeVenuePicker];
        [self removeDatePicker];
        [self removeTimePicker];

    }
}

-(void)changeVenueCell
{
    if (self.venueCell.showCell ) {
        [self removeDatePicker];
        [self removeTimePicker];
        [self.nameCell.nameEntry resignFirstResponder];
        
        self.numberOFVenueRows++;
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:VENUE_SECTION]] withRowAnimation:UITableViewRowAnimationFade];
        [self.venuePickerView reloadAllComponents];
        
        self.venueCell.label.text = @"";
        self.venueCell.value.text = @"Done";// show done button image instead
        
        [self.venueCell toggleShowCell];
        
        
    }else{
        [self removeVenuePicker];
    }

}

-(void)removeVenuePicker
{
    if (self.venuePickerView) {
        self.numberOFVenueRows--;
        self.venueCell.value.text =  self.venuePickerSelection;
        self.venuePickerView = nil;
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:VENUE_SECTION]] withRowAnimation:UITableViewRowAnimationFade];
        self.venueCell.label.text = @"Venue:";
        [self.venueCell toggleShowCell];
    }


}

-(void)changeDateCell
{
    if (self.dateCell.showCell ) {
        
        [self removeVenuePicker];
        [self removeTimePicker];
        [self.nameCell.nameEntry resignFirstResponder];

        self.numberOfDateRows++;
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:DATE_SECTION]] withRowAnimation:UITableViewRowAnimationFade];
        
        self.dateCell.label.text = @"";
        self.dateCell.value.text = @"Done";// show done button image instead
        [self.dateCell toggleShowCell];
       
        
    }else{
        [self removeDatePicker];
    }

}







-(void)removeDatePicker
{
    if (self.datePicker) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
        [dateFormat setDateFormat:@"MM/dd/yyyy"];
        self.numberOfDateRows--;
        self.dateCell.value.text = [dateFormat stringFromDate:[self.datePicker date]];
        self.datePicker = nil;
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:DATE_SECTION]] withRowAnimation:UITableViewRowAnimationFade];
        self.dateCell.label.text = @"Date:";
        [self.dateCell toggleShowCell];
    }


}

-(void)changeTimeCell
{
    if (self.timeCell.showCell ) {
        [self removeVenuePicker];
        [self removeDatePicker];
        [self.nameCell.nameEntry resignFirstResponder];
        self.numberOFTimeRows++;
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:TIME_SETION]] withRowAnimation:UITableViewRowAnimationFade];
        
        self.timeCell.label.text = @"";
        self.timeCell.value.text = @"Done";// show done button image instead
        [self.timeCell toggleShowCell];
        
    }else{
        [self removeTimePicker];
    }
   
    
}
-(void)removeTimePicker
{
    if (self.timePicker) {
        NSDateFormatter *timeFormat = [[NSDateFormatter alloc]init];
        [timeFormat setDateFormat:@"hh:mm a"];
        self.numberOFTimeRows--;
        self.timeCell.value.text = [timeFormat stringFromDate:[self.timePicker date]];
        self.timePicker = nil;
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:TIME_SETION]] withRowAnimation:UITableViewRowAnimationFade];
        self.timeCell.label.text = @"Time:";
        [self.timeCell toggleShowCell];
    }

}

-(void)runVenueQueryAndLoadData
{
    
   
    [self.venueQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!_venues) _venues = [[NSMutableArray alloc]init];
        
        if (!error) {
            NSLog(@"Ran Query");
            
            [self.venues removeAllObjects];
            [self.venues addObjectsFromArray:objects];
       
        }
        
    }];
    
}

-(void)createAndDisplayMediaSourceAlert
{
    UIAlertView *mediaTypeNotAvailable = [[UIAlertView alloc]initWithTitle:@"Sorry" message:@"The Media Type you have selected is not available!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [mediaTypeNotAvailable show];
    
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
