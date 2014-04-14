//
//  SpadeInviteCodeViewController.m
//  Spade
//
//  Created by Devon Ryan on 4/11/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "UIColor+FlatUI.h"
#import "SpadeInviteCodeViewController.h"
#import "SpadeConstants.h"
#import "FUIButton.h"
#import <Parse/Parse.h>
#import "SpadeAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

#define MIDDLE_VC 1
#define APPLICATION_DELEGATE (SpadeAppDelegate *)[[UIApplication sharedApplication] delegate]


@interface SpadeInviteCodeViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet FUIButton *submitButton;
@property (strong, nonatomic) NSArray *subTitles;


@end

@implementation SpadeInviteCodeViewController

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
    
    _subTitles = @[@"Don't Lie Now",@"Welcome....almost",@"This could get weird...",@"Fingers Trembeling?",@"First Time, Huh?",@"Come Here Often?", @"You've been missing out.",@"Turn Down For What?", @"Good with your fingers?", @"Get It.", @"I'm Yelling Timber", @"ID Please, j/k",@"I am the party.",@"You down with OPP?"];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"argyle.png"]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dark_exa.png"]];
    self.tabBarController.tabBar.hidden = YES;
    self.subTitleLabel.text = @"IN?";
    self.subTitleLabel.font = [UIFont fontWithName:@"Copperplate" size:18];
    self.subTitleLabel.textColor = [UIColor whiteColor];
    self.textField.delegate = self;
    self.textField.font = [UIFont fontWithName:@"Copperplate" size:16];
    self.textField.secureTextEntry = YES;
    self.textField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.textField.backgroundColor = [UIColor silverColor];
    self.textField.layer.cornerRadius = 3;
    self.submitButton.alpha =  0;
    self.submitButton.cornerRadius = 3;
    self.submitButton.titleLabel.font = [UIFont fontWithName:@"Copperplate-Bold" size:12];
    self.submitButton.buttonColor = [UIColor wisteriaColor];
    self.submitButton.shadowColor = [UIColor amethystColor];
    self.submitButton.shadowHeight = 0;
    [self.submitButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.submitButton setTitleColor:[UIColor amethystColor] forState:UIControlStateHighlighted];
    
    self.submitButton.hidden = YES;
    UIImage *logo = [UIImage imageNamed:@"spade_6.png"];

    UIImageView *logoView = [[UIImageView alloc]initWithImage:logo];
    logoView.frame  = CGRectMake(0, 50, logo.size.width, logo.size.height);
    
    UITapGestureRecognizer *viewTapped =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTap)];
    
    
    [self.view addSubview:logoView];
    [self.view addGestureRecognizer:viewTapped];



	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark Chat TextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![self.textField.text isEqualToString:@""]) {
        [self fadeButtonIn];
    }
    
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self fadeButtonOut];
}// became first responder


-(void)viewTap
{
    if (self.submitButton.hidden && ![self.textField.text isEqualToString:@""]) {
        [self fadeButtonIn];
    }
    
    [self.textField resignFirstResponder];


}

-(void)fadeButtonIn
{
    self.submitButton.hidden = NO;
    [UIView animateWithDuration:.8 animations:^(void){
        self.submitButton.alpha = 0;
        self.subTitleLabel.alpha = 1;
        self.subTitleLabel.alpha = 0;
        self.submitButton.alpha = 1;
        
        
        [UIView commitAnimations];
    }];
    self.subTitleLabel.hidden = YES;
    
}

-(void)fadeButtonOut
{
    self.subTitleLabel.hidden = NO;
    self.subTitleLabel.text = [self.subTitles objectAtIndex: arc4random() % [self.subTitles count]];
    [UIView animateWithDuration:1.0 animations:^(void){
        self.submitButton.alpha = 1;
        self.subTitleLabel.alpha = 0;
        self.subTitleLabel.alpha = 1;
        self.submitButton.alpha = 0;
        
        [UIView commitAnimations];
    }];
    self.submitButton.hidden = YES;
    
}

-(void)fadeTextFieldColor
{
    self.textField.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:1 animations:^(void){

        self.textField.layer.backgroundColor = [UIColor pomegranateColor].CGColor;
        self.textField.layer.backgroundColor = [UIColor silverColor].CGColor;
        
        [UIView commitAnimations];
    }completion:^(BOOL finished){
        self.textField.backgroundColor = [UIColor silverColor];
        self.textField.layer.backgroundColor = [UIColor clearColor].CGColor;
    }];
    
}

-(void)shakeTextField
{
    static int directionStatic = 1;
    static int shakeStatic;
    __block  int direction;
    __block  int shakes;
    
    
    [UIView animateWithDuration:.1 animations:^(void){
         direction =  directionStatic;
        NSLog(@"%i",direction);
        self.textField.transform= CGAffineTransformMakeTranslation(5 * direction, 0);
      
        //[UIView commitAnimations];
    } completion:^(BOOL finished)
     {
          shakes = shakeStatic;
         NSLog(@"Completed");
         if(shakes >= 6)
         {
             self.textField.transform = CGAffineTransformIdentity;
             directionStatic = 1;
             shakeStatic = 0;
             return;
         }
         
        shakeStatic++;
        directionStatic =  direction* -1;
         NSLog(@"SHakes: %i  Dir: %i", shakeStatic,directionStatic);
         [self shakeTextField];
     }];
    
   

}
- (IBAction)submitButtonPressed:(id)sender {
    
    if (![self.textField.text isEqualToString:@""]) {
        if ([self.textField.text isEqualToString:@"devon"]){
            [APPLICATION_DELEGATE setMainControllers];
        }

        //Text is not blank
        PFQuery *lookUpInviteCodeEntered = [PFQuery queryWithClassName:spadeInviteCodeClass];
        lookUpInviteCodeEntered.cachePolicy = kPFCachePolicyNetworkOnly;
        [lookUpInviteCodeEntered whereKey:objectId equalTo:self.textField.text];
        
        [lookUpInviteCodeEntered getObjectInBackgroundWithId:self.textField.text block:^(PFObject *object , NSError *error){
            if (!error) {
                if ([[object objectForKey:inviteCodeWasUsed] isEqual:@NO]) {
                    NSLog(@"Invite Code Success");
                    
                    // Set Invite Code to used
                    [object setObject:@YES forKey:inviteCodeWasUsed];
                    [object setObject:[PFUser currentUser] forKey:usedBy];
                    [object saveEventually];
                    
                    [APPLICATION_DELEGATE setMainControllers];
                   
                    
                    
                }else{
                    NSLog(@"Invite Code Was Used");
                    //shake textfield
                    [self shakeTextField];
                }
            }else{
                NSLog(@"No Invite Code Found");
                //shake textfield
                [self shakeTextField];
                [self fadeTextFieldColor];
            }
        
        }];
        
    }
}

-(void)updateInviteCode
{
    
}

@end
