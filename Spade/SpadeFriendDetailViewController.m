//
//  SpadeFriendDetailViewController.m
//  Spade
//
//  Created by Devon Ryan on 12/29/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//
#import "SpadeConstants.h"
#import "SpadeUtility.h"
#import "SpadeCache.h"
#import "SpadeFriendDetailViewController.h"


@interface SpadeFriendDetailViewController ()

@property (weak, nonatomic) IBOutlet PFImageView *friendProfileImage;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@end

@implementation SpadeFriendDetailViewController

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
    self.title = [self.friend objectForKey:spadeUserDisplayName];
    self.friendProfileImage.file  = [self.friend objectForKey:spadeUserMediumProfilePic];
    [self.friendProfileImage loadInBackground];
    
    //setFollowButton
    
    
    if ([[[[SpadeCache sharedCache].cache objectForKey:spadeCache]objectForKey:spadeCacheUser] containsObject:self.friend]) {
        [self.followButton setTitle:spadeFollowButtonTitleUnfollow forState:UIControlStateNormal];
    }else{
        
        [self.followButton setTitle:spadeFollowButtonTitleFollow forState:UIControlStateNormal];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[[[self.navigationController viewControllers]objectAtIndex:1]tableView]reloadData];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)followButtonPressed:(UIButton *)sender {
    
    
    if([sender.titleLabel.text isEqualToString:spadeFollowButtonTitleFollow]){
        [sender setTitle:spadeFollowButtonTitleUnfollow forState:UIControlStateNormal];
        [[SpadeCache sharedCache] addFollowedUser:self.friend];
    
        [self createAndDisplayFollowAlert];
        
    }else if ([sender.titleLabel.text isEqualToString:spadeFollowButtonTitleUnfollow]){
        
        [sender setTitle:spadeFollowButtonTitleFollow forState:UIControlStateNormal];
        
        [[SpadeCache sharedCache]removeFollowedUser:self.friend];
 
    }
}



#pragma mark { }

-(void)createAndDisplayFollowAlert{
    UIAlertView *followingUser = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Following %@",self.title] message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [followingUser show];
    
}

@end
