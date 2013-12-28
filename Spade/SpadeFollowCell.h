//
//  SpadeFollowCell.h
//  Spade
//
//  Created by Devon Ryan on 12/26/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@protocol SpadeFollowCellDelegate;
@class PFImageView;

@interface SpadeFollowCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) id <SpadeFollowCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;
@property (strong, nonatomic) PFObject *object;



@end

@protocol SpadeFollowCellDelegate <NSObject>
@required
-(void)followWasPressedWithTitle:(NSString *)title forObject:(PFObject *)
object;
-(void)shouldToggleFollowButtonTitleforCell:(SpadeFollowCell *)cell;

@end
