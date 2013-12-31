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
- (IBAction)whereButtonPressed:(id)sender {
    
    if (!self.venuePickerView.isHidden) {
        self.venuePickerView.hidden = YES;
    }else{
        if (!self.whenPickerView.isHidden) {
            self.whenPickerView.hidden = YES; //Hide the other
        }
        self.venuePickerView.hidden = NO; //Show it
    }
}


- (IBAction)whenButtonPressed:(id)sender {
    
    if (!self.whenPickerView.isHidden) {
        self.whenPickerView.hidden = YES;
    }else{
        if (!self.venuePickerView.isHidden) {
            self.venuePickerView.hidden = YES;
        }
        self.whenPickerView.hidden = NO;
    }
}
- (IBAction)viewTapped:(id)sender {
    if ([self.eventNameTextField isFirstResponder]) {
        [self.view endEditing:YES];
    }else if (![self.whenPickerView isHidden]){
        self.whenPickerView.hidden = YES;
    }else if (![self.venuePickerView isHidden]){
        self.venuePickerView.hidden = YES;
    }
}

#pragma mark TextField Delegation
- (BOOL)textFieldShouldReturn:(UITextField *)textField{ // called when 'return' key pressed. return NO to ignore.
    [textField resignFirstResponder];
 
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.whenPickerView.hidden = YES;
    self.venuePickerView.hidden =YES;

}

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

#define MY_EVENTS_SEGMENT 1
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
- (IBAction)uploadImageButtonPressed:(UIButton *)sender {
}

- (IBAction)saveButtonPressed:(UIButton *)sender {
    if ([self.eventNameTextField.text isEqualToString:@""] || [self.eventWhenLabel.text isEqualToString:spadeEventPlaceHolderWhenLabel] || [self.eventWhereLabel.text isEqualToString:spadeEventPlaceHolderWhereLabel]) {
        [self createNotEnoughInformationAlert];
    }else{
        [self createEventCreationConfirmationAlert];
    }
}

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

-(void)createEventCreationConfirmationAlert
{
    
    UIAlertView *eventCreationAlert = [[UIAlertView alloc]initWithTitle:@"Create Event" message:[NSString stringWithFormat:@"Please confirm the following event:\n Event Name:%@\n Where:%@\n When:%@",self.eventNameTextField.text,self.eventWhereLabel.text, self.eventWhenLabel.text] delegate:self cancelButtonTitle:@"Right On Nigga" otherButtonTitles: nil];
    [eventCreationAlert show];
}

-(void)createNotEnoughInformationAlert
{
    UIAlertView *notEnoughInformationAlert = [[UIAlertView alloc]initWithTitle:@"Not Enough Information" message:@"Please make sure you give your event a name, a where, and a when.\n The image is optional, but first appearences are everything.\n Let that sink in..." delegate:nil cancelButtonTitle:@"Roger That" otherButtonTitles: nil];
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
  
    self.eventWhenLabel.text =  [NSString stringWithFormat:@"%@   AT   %@",dateString,timeString];
                                                             
}


@end
