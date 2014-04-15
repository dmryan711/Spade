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
#import "UINavigationBar+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "FUIButton.h"

#define AMOUNT_OF_REFERRALS 3

@interface SpadeProfileController ()
//@property (weak, nonatomic) IBOutlet PFImageView *profileImage;


@property (weak, nonatomic) IBOutlet PFImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UILabel *venuesFollowedLabel;
@property (weak, nonatomic) IBOutlet UILabel *usersFollowedLabel;
@property (strong, nonatomic) NSMutableArray *referralCodes;
@property (strong, nonatomic) FUIAlertView   *cantSendTextAlert;
@property (strong, nonatomic) FUIAlertView   *referralCodeAlert;


@property (weak, nonatomic) IBOutlet FUIButton *referralButton;

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
    
 [self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor blendedColorWithForegroundColor:[UIColor blackColor] backgroundColor:[UIColor wisteriaColor] percentBlend:.6]];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dark_exa.png"]];
    self.nameLabel.textColor  = [UIColor whiteColor];
    self.followersLabel.textColor = [UIColor whiteColor];
    self.venuesFollowedLabel.textColor = [UIColor whiteColor];
    self.usersFollowedLabel.textColor = [UIColor whiteColor];
    self.referralButton.buttonColor = [UIColor amethystColor];
    self.referralButton.shadowColor = [UIColor wisteriaColor];
    self.referralButton.shadowHeight = 3;
    self.referralButton.cornerRadius = 3;
    [self.referralButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    self.referralButton.titleLabel.font = [UIFont fontWithName:@"Copperplate" size:12];
    
    
    
    
	// Do any additional setup after loading the view.
    
     //Bypassing Linker issue When the storyboarding class is loaded at runtime, the PF[.*]Class is referenced using a string. The linker doesn't analyze code functionality, so it doesn't know that the class is used. Since no other source files references that class, the linker optimizes it out of existence when making the executable
    [PFImageView class];
      self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editPressed)];
    
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor cloudsColor];
    self.navigationItem.backBarButtonItem.tintColor = [UIColor cloudsColor];
    self.profileImageFile = [[PFUser currentUser] objectForKey:spadeUserMediumProfilePic];
    //Round corners

    [self.profileImage.layer setMasksToBounds:YES];
    [self.profileImage.layer setCornerRadius:10.0];
    
    //Set border
    [self.profileImage.layer setBorderWidth:2];
    [self.profileImage.layer setBorderColor:[[UIColor whiteColor] CGColor]];
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

#define TEXT 0
#define EMAIL 1
#pragma mark FUIAlertView Protocol
- (void)alertView:(FUIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView isEqual:self.referralCodeAlert]) {

        PFObject *referralCode = [self.referralCodes objectAtIndex:0];
        if (buttonIndex == TEXT) {
            if ([MFMessageComposeViewController canSendText]) {
                MFMessageComposeViewController *textReferral = [[MFMessageComposeViewController alloc]init];
                textReferral.body = [NSString stringWithFormat:@"Ok, so you party, I party, and Spade is going to help us party, so lets party. Here is your referral code: %@\nDownload spade at https://www.abc.com.\nThank me later.",referralCode.objectId];
                [textReferral setMessageComposeDelegate:self];
            
                [self presentViewController:textReferral animated:YES completion:nil];
            }else{
            
                self.cantSendTextAlert = [[FUIAlertView alloc]initWithTitle:@"Error" message:@"Sorry, doesn't look like your device can send texts" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                self.cantSendTextAlert.defaultButtonColor = [UIColor amethystColor];
                self.cantSendTextAlert.defaultButtonShadowColor = [UIColor wisteriaColor];
                self.cantSendTextAlert.defaultButtonShadowHeight = 6.0f;
                self.cantSendTextAlert.defaultButtonCornerRadius = 6.0f;
                self.cantSendTextAlert.defaultButtonTitleColor = [UIColor cloudsColor];
                self.cantSendTextAlert.alertContainer.backgroundColor = [UIColor clearColor];
                self.cantSendTextAlert.backgroundOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
                self.cantSendTextAlert.defaultButtonFont = [UIFont fontWithName:@"Copperplate" size:20];
                self.cantSendTextAlert.messageLabel.font = [UIFont fontWithName:@"Copperplate-Bold" size:15];
                self.cantSendTextAlert.titleLabel.font = [UIFont fontWithName:@"Copperplate-Bold" size:20];
                self.cantSendTextAlert.messageLabel.textColor = [UIColor cloudsColor];
                self.cantSendTextAlert.titleLabel.textColor = [UIColor cloudsColor];
                [self.cantSendTextAlert show];

            }
        }else if(buttonIndex == EMAIL){
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *emailReferral = [[MFMailComposeViewController alloc]init];
                [emailReferral setMailComposeDelegate:self];
                 [emailReferral setSubject:@"You have been invited to Spade NYC"];
                [emailReferral setMessageBody:[NSString stringWithFormat:@"Ok, so you party, I party, and Spade is going to help us party, so lets party. Here is your referral code: %@\nDownload spade at https://www.abc.com.\nThank me later.",referralCode.objectId] isHTML:NO];
                [emailReferral setMessageBody:[NSString stringWithFormat:@"<h2>Spade</h2><br/><p>Ok, so you party, I party, and Spade is going to help us party, so lets party.</p><br/> <p>Here is your referral code:<strong>%@<strong></p><br/><p>Download spade at https://www.abc.com.</p><br/><p>Thank me later.</p>",referralCode.objectId] isHTML:YES];
                
                [self.navigationController presentViewController:emailReferral animated:YES completion:nil];
               // [emailReferral setMessageBody: [NSString stringWithFormat:@"Welcome.\n You have been invited to Spade by your friend %@.\n Your referral code is %@",[PFUser currentUser],referralCode.objectId]];
               // sendReferral.
            }
        }
        
    }
}// after animation

#pragma mark MFMessage Protocol
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    NSLog(@"dimiss txt");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark MFMail Protocol

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSLog(@"dimiss email");
    [self dismissViewControllerAnimated:YES completion:nil];


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

- (IBAction)referralOnePressed:(id)sender {
    PFQuery *fetchReferrals =[PFQuery queryWithClassName:spadeInviteCodeClass];
    [fetchReferrals whereKey:belongsTo equalTo:[PFUser currentUser]];
    [fetchReferrals whereKey:amountUsed lessThan:[NSNumber numberWithInt:AMOUNT_OF_REFERRALS]];
    
    [fetchReferrals findObjectsInBackgroundWithBlock:^(NSArray *codes, NSError *error){
        if (!error) {
            if (codes && codes.count > 0) {
                int amountOfUsesLeft = [[[codes objectAtIndex:0]objectForKey:totalUses] intValue] -  [[[codes objectAtIndex:0]objectForKey:amountUsed] intValue];
                
                if (amountOfUsesLeft == 1) {
                    self.referralCodeAlert = [[FUIAlertView alloc]initWithTitle:@"Referal Codes" message:[NSString stringWithFormat:@"You have %i Referral left.\n We recommened using referrals for friends that you will interact with on Spade.\n That is all, Party On.", amountOfUsesLeft] delegate:self cancelButtonTitle:@"Send Via Text" otherButtonTitles:@"Send Via Email",nil];
                }else{
                     self.referralCodeAlert = [[FUIAlertView alloc]initWithTitle:@"Referal Codes" message:[NSString stringWithFormat:@"You have %i Referrals left.\n We recommened using referrals for friends that you will interact with on Spade.\n That is all, Party On.", amountOfUsesLeft] delegate:self cancelButtonTitle:@"Send Via Text" otherButtonTitles:@"Send Via Email",nil];
                }
                
               
                self.referralCodeAlert.defaultButtonColor = [UIColor amethystColor];
                self.referralCodeAlert.defaultButtonShadowColor = [UIColor wisteriaColor];
                self.referralCodeAlert.defaultButtonShadowHeight = 6.0f;
                self.referralCodeAlert.defaultButtonCornerRadius = 6.0f;
                self.referralCodeAlert.defaultButtonTitleColor = [UIColor cloudsColor];
                self.referralCodeAlert.alertContainer.backgroundColor = [UIColor clearColor];
                self.referralCodeAlert.backgroundOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
                self.referralCodeAlert.defaultButtonFont = [UIFont fontWithName:@"Copperplate" size:20];
                self.referralCodeAlert.messageLabel.font = [UIFont fontWithName:@"Copperplate-Bold" size:15];
                self.referralCodeAlert.titleLabel.font = [UIFont fontWithName:@"Copperplate-Bold" size:20];
                self.referralCodeAlert.messageLabel.textColor = [UIColor cloudsColor];
                self.referralCodeAlert.titleLabel.textColor = [UIColor cloudsColor];
                [self.referralCodeAlert show];
                
                _referralCodes = [NSMutableArray arrayWithArray:codes];
            }
        }
    }];
    
}


@end
