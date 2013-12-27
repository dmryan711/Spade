//
//  SpadeProfileController.m
//  Spade
//
//  Created by Devon Ryan on 12/10/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//
#import "SpadeAppDelegate.h"
#import <Parse/Parse.h>
#import "SpadeConstants.h"
#import "SpadeUtility.h"
#import "SpadeProfileController.h"
#import "SpadeEditProfileViewController.h"

@interface SpadeProfileController ()
//@property (weak, nonatomic) IBOutlet PFImageView *profileImage;


@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
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
    NSLog(@"Profile View Loaded");
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
     //Bypassing Linker issue When the storyboarding class is loaded at runtime, the PF[.*]Class is referenced using a string. The linker doesn't analyze code functionality, so it doesn't know that the class is used. Since no other source files references that class, the linker optimizes it out of existence when making the executable
    [PFImageView class];
      self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editPressed)];
    self.profileImageFile = [[PFUser currentUser] objectForKey:spadeUserMediumProfilePic];
    

}

-(void)viewWillAppear:(BOOL)animated

{
    
    if (self.profileImageFile) {
        
        [SpadeUtility loadFile:self.profileImageFile forImageView:self.profileImage];
    }

    self.nameLabel.text = self.userName;

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark {  }
- (void)editPressed{
    //Create Profile Edit VC
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    //Create Detail View
    SpadeEditProfileViewController *profileEdit = [mainStoryboard   instantiateViewControllerWithIdentifier:@"profileEditViewController"];
    profileEdit.profileFileForEdit = self.profileImageFile;
    profileEdit.userNameForEdit =self.userName ;
    
    [self.navigationController pushViewController:profileEdit animated:YES];
}


@end
