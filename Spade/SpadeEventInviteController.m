//
//  SpadeEventInviteController.m
//  Spade
//
//  Created by Devon Ryan on 12/30/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import "SpadeEventInviteController.h"

@interface SpadeEventInviteController ()
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *friendList;

@end

@implementation SpadeEventInviteController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
