//
//  SpadeFollowCell.h
//  Spade
//
//  Created by Devon Ryan on 12/26/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FUIButton.h"
@protocol SpadeFollowCellDelegate;
@class PFImageView;

@interface SpadeFollowCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet FUIButton *followButton;
@property (weak, nonatomic) id <SpadeFollowCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;
@property (strong, nonatomic) PFObject *object;
@property (strong, nonatomic) PFUser *userObject;



@end

@protocol SpadeFollowCellDelegate <NSObject>
@required
-(void)followButtonWasPressedForCell:(SpadeFollowCell *)cell;

@end
