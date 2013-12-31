//
//  SpadeFriendDetailViewController.h
//  Spade
//
//  Created by Devon Ryan on 12/29/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface SpadeFriendDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property  (strong,nonatomic) PFUser *friend;

@end
