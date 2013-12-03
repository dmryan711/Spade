//
//  SpadeLoginViewController.m
//  Spade
//
//  Created by Devon Ryan on 11/24/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import "SpadeLoginViewController.h"

@interface SpadeLoginViewController ()

@end

@implementation SpadeLoginViewController

#pragma mark Init Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark Life Cycle Delegate Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"skyline_7.png"]]];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]]];
    
    // Set buttons appearance
    [self.logInView.facebookButton setTitle:@"uck promoters" forState:UIControlStateNormal];
    [self.logInView.facebookButton setTitle:@"uck promoters" forState:UIControlStateHighlighted];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
