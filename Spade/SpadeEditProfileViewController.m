//
//  SpadeEditProfileViewController.m
//  Spade
//
//  Created by Devon Ryan on 12/24/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import "SpadeEditProfileViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SpadeUtility.h"
#import "SpadeProfileController.h"
#import "SpadeConstants.h"
#import "UIColor+FlatUI.h"


@interface SpadeEditProfileViewController ()
@property (weak, nonatomic) IBOutlet UIProgressView *imageLoad;
@property (weak, nonatomic) IBOutlet PFImageView *profileEditImageView;
@property (strong,nonatomic)  UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@end

@implementation SpadeEditProfileViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
  
    return self;
}


#pragma mark View Controller LifeCycle

-(void)awakeFromNib
{
    if (!_profileFileForEdit) _profileFileForEdit = [[PFFile alloc]init];
    if (!_userNameForEdit) _userNameForEdit = [[NSString alloc]init];
}



#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelPressed)];
    self.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(donePressed)];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dark_exa.png"]];
    self.userNameTextField.font = [UIFont fontWithName:@"Copperplate" size:16];
    self.userNameTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.userNameTextField.backgroundColor = [UIColor silverColor];
    self.userNameTextField.layer.cornerRadius = 3;

    
    //Bypassing Linker issue When the storyboarding class is loaded at runtime, the PF[.*]Class is referenced using a string. The linker doesn't analyze code functionality, so it doesn't know that the class is used. Since no other source files references that class, the linker optimizes it out of existence when making the executable
    [PFImageView class];
    self.imageLoad.hidden = YES;
    
    
    if (self.profileEditImageView) {
        [SpadeUtility loadFile:self.profileFileForEdit forImageView:self.profileEditImageView];
    }
    
    self.userNameTextField.delegate = self;
    self.userNameTextField.text = self.userNameForEdit;
    
    //Round corners
    
    [self.profileEditImageView.layer setMasksToBounds:YES];
    [self.profileEditImageView.layer setCornerRadius:10.0];
    
    //Set border
    [self.profileEditImageView.layer setBorderWidth:2];
    [self.profileEditImageView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    
    
    CGAffineTransform leftWobble = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-5.0));
    CGAffineTransform rightWobble = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(5.0));
    
    self.profileEditImageView.viewForBaselineLayout.transform = leftWobble;  // starting point
    
    [UIView beginAnimations:@"wobble" context:(__bridge void *)(self.profileEditImageView.viewForBaselineLayout)];
    [UIView setAnimationRepeatAutoreverses:YES]; // important
    [UIView setAnimationRepeatCount:10000];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(wobbleEnded:finished:context:)];
    
    self.profileEditImageView.viewForBaselineLayout.transform = rightWobble; // end here & auto-reverse
    
    [UIView commitAnimations];


    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)editProfilePressed:(id)sender {
    
    
     UIActionSheet *editProfilePictureSelection = [[UIActionSheet alloc]initWithTitle:@"Select Picture Source" delegate:self cancelButtonTitle:@"Nevermind" destructiveButtonTitle:nil otherButtonTitles:@"Choose From Library",@"Take a Photo", nil];
     
     [editProfilePictureSelection showFromTabBar:self.tabBarController.tabBar];
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


#pragma mark UIImagePicker Controller Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //Set User Changed Picture Flag so we don't overwrite with Facebook Image on each Log out
    if (![[NSUserDefaults standardUserDefaults]boolForKey:spadePicFLag] ){
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:spadePicFLag];
    }
    
    //UnHide the Image Load Process Bar
    self.imageLoad.hidden = NO;
    
    NSString *imageType = (NSString *)kUTTypeImage;
    if (![[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:imageType]) { // User did not select an Image, throw an alert
        
        //Dismiss Image Picker & Show ALert
        [self dismissViewControllerAnimated:YES completion:^(void) {
            UIAlertView *didNotSelectImage = [[UIAlertView alloc]initWithTitle:@"Pictures Only!" message:@"The image you have selected is not a picture" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [didNotSelectImage show];
            
        }];
    }else{
        //Switch Profile Image Locally & Animate Progress Bar
      self.profileFileForEdit = [PFFile fileWithData:UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 0.5)];
        [self.profileFileForEdit saveInBackgroundWithBlock:^(BOOL succeeded , NSError *error){
            if (!error) {
                [self.profileEditImageView setFile:self.profileFileForEdit];
                [self.profileEditImageView loadInBackground];
                
                
                //Process & Upload to Parse
                [SpadeUtility processProfilePictureData:UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage],0.5)];
            }
            if (succeeded) {
                self.imageLoad.hidden = YES;
                self.imageLoad.progress = 0.0;
            }
            
        }
                                 progressBlock:^(int percentDone){
                                     [self.imageLoad setProgress:(float)percentDone];
                                 }];
        
        //Upload Photo To Parse
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (IBAction)viewTapped:(id)sender {
    
    
    if ([self.userNameTextField isFirstResponder]) {
        self.userNameForEdit = self.userNameTextField.text;
        
         [self.view endEditing:YES];
    }
    
}

-(void)cancelPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)donePressed
{
    if ([self.userNameTextField isFirstResponder]) {
        if (self.userNameTextField.text.length > 0) {
            self.userNameForEdit = self.userNameTextField.text;
            [self.userNameTextField resignFirstResponder];
            [self passEditsBackToParent];
            [SpadeUtility processUserName:self.userNameForEdit forUser:[PFUser currentUser]];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            //Display Name Criteria Alert
            FUIAlertView *nameCriteriaAlert = [[FUIAlertView alloc]initWithTitle:@"No Name?" message:@"Hey There!\n Please include a name.\n We need to call you something :)" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            nameCriteriaAlert.defaultButtonColor = [UIColor amethystColor];
            nameCriteriaAlert.defaultButtonShadowColor = [UIColor wisteriaColor];
            nameCriteriaAlert.defaultButtonShadowHeight = 6.0f;
            nameCriteriaAlert.defaultButtonCornerRadius = 6.0f;
            nameCriteriaAlert.defaultButtonTitleColor = [UIColor cloudsColor];
            nameCriteriaAlert.alertContainer.backgroundColor = [UIColor clearColor];
            nameCriteriaAlert.backgroundOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
            nameCriteriaAlert.defaultButtonFont = [UIFont fontWithName:@"Copperplate" size:20];
            nameCriteriaAlert.messageLabel.font = [UIFont fontWithName:@"Copperplate-Bold" size:15];
            nameCriteriaAlert.titleLabel.font = [UIFont fontWithName:@"Copperplate-Bold" size:20];
            nameCriteriaAlert.messageLabel.textColor = [UIColor cloudsColor];
            nameCriteriaAlert.titleLabel.textColor = [UIColor cloudsColor];
            [nameCriteriaAlert show];

            
        }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


#pragma mark TextField Delegation
- (void)textFieldDidBeginEditing:(UITextField *)textField{ // became first responder
    if (![[NSUserDefaults standardUserDefaults]boolForKey:spadeNameFlag] ){
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:spadeNameFlag];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{ // called when 'return' key pressed. return NO to ignore.
    
    self.userNameForEdit = textField.text;
    [textField resignFirstResponder];
    
    
    return YES;
}

#pragma mark { }
-(void)passEditsBackToParent
{
     SpadeProfileController *parentViewController =[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    
    parentViewController.userName = self.userNameForEdit;
    parentViewController.profileImageFile = self.profileFileForEdit;

}


-(void)createAndDisplayMediaSourceAlert
{
    UIAlertView *mediaTypeNotAvailable = [[UIAlertView alloc]initWithTitle:@"Sorry" message:@"The Media Type you have selected is not available!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [mediaTypeNotAvailable show];

}

- (void) wobbleEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([finished boolValue]) {
        UIView* item = (__bridge UIView *)context;
        item.transform = CGAffineTransformIdentity;
    }
}














@end
