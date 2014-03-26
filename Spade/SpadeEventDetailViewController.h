//
//  SpadeEventDetailViewController.h
//  Spade
//
//  Created by Devon Ryan on 1/5/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpadeFollowCell.h"
#import <Parse/Parse.h>


@interface SpadeEventDetailViewController : UIViewController <SpadeFollowCellDelegate,UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) PFObject *object;
@property (weak, nonatomic) IBOutlet UIButton *attendButton;

@end
