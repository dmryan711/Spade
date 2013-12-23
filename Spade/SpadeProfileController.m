//
//  SpadeProfileController.m
//  Spade
//
//  Created by Devon Ryan on 12/10/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//
#import "SpadeAppDelegate.h"
#import <Parse/Parse.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "SpadeUtility.h"
#import "SpadeProfileController.h"

@interface SpadeProfileController ()
//@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (strong,nonatomic)  UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


@end

@implementation SpadeProfileController

#pragma mark View Controller LifeCycle Methods
#define APPLICATION_DELEGATE (SpadeAppDelegate *)[[UIApplication sharedApplication] delegate]
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
     //Bypassing Linker issue When the storyboarding class is loaded at runtime, the PF[.*]Class is referenced using a string. The linker doesn't analyze code functionality, so it doesn't know that the class is used. Since no other source files references that class, the linker optimizes it out of existence when making the executable
    [PFImageView class];
    self.progressBar.hidden = YES;
    PFFile *imageFile = [[PFUser currentUser] objectForKey:@"MediumProfilePic"];
    if (imageFile) {
        
        [SpadeUtility loadFile:imageFile forImageView:self.profileImage];
    }
    
    self.nameLabel.text = self.userName;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark {  }
- (IBAction)editPressed:(id)sender {
    
    UIActionSheet *editProfilePictureSelection = [[UIActionSheet alloc]initWithTitle:@"Select Picture Source" delegate:self cancelButtonTitle:@"Nevermind" destructiveButtonTitle:nil otherButtonTitles:@"Camera Roll", @"Facebook", nil];
    
    [editProfilePictureSelection showFromTabBar:self.tabBarController.tabBar];
}


#pragma mark Action Sheet Delegate Methods
#define CAMERA_ROLL 0
#define FBImage 1
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
            UIAlertView *mediaTypeNotAvailable = [[UIAlertView alloc]initWithTitle:@"Sorry" message:@"The Media Type you have selected is not available!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [mediaTypeNotAvailable show];
        }
    //}else if (buttonIndex == ){}
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex  // after animation
{}


#pragma mark UIImagePicker Controller Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //Set User Changed Picture Flag so we don't overwrite with Facebook Image on each Log out
    [[NSUserDefaults standardUserDefaults]setObject:@"Yes" forKey:@"picChangedFlag"];
    
    //UnHide the Image Load Process Bar
    self.progressBar.hidden = NO;
    
    NSString *imageType = (NSString *)kUTTypeImage;
    if (![[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:imageType]) { // User did not select an Image, throw an alert
        
        //Dismiss Image Picker & Show ALert
        [self dismissViewControllerAnimated:YES completion:^(void) {
            UIAlertView *didNotSelectImage = [[UIAlertView alloc]initWithTitle:@"Pictures Only!" message:@"The image you have selected is not a picture" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [didNotSelectImage show];
        
        }];
    }else{
        //Switch Profile Image Locally & Animate Progress Bar
        PFFile *cameraImage = [PFFile fileWithData:UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 0.5)];
        [cameraImage saveInBackgroundWithBlock:^(BOOL succeeded , NSError *error){
                                                if (!error) {
                                                    [self.profileImage setFile:cameraImage];
                                                    [self.profileImage loadInBackground];
                                                }
                                                if (succeeded) {
                                                    self.progressBar.hidden = YES;
                                                    self.progressBar.progress = 0.0;
                                                }
            
                                            }
                                 progressBlock:^(int percentDone){
                                     [self.progressBar setProgress:(float)percentDone];
        }];
        
        //Upload Photo To Parse
        [self dismissViewControllerAnimated:YES completion:^(void){
            [SpadeUtility processProfilePictureData:UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage],0.5)];
       }];
    }
}

@end
