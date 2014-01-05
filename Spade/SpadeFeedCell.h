//
//  SpadeFeedCell.h
//  Spade
//
//  Created by Devon Ryan on 1/3/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@interface SpadeFeedCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;

@property (weak, nonatomic) IBOutlet  PFImageView *userImageView;
@end
