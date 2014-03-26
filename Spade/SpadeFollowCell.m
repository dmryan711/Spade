//
//  SpadeFollowCell.m
//  Spade
//
//  Created by Devon Ryan on 12/26/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import "SpadeFollowCell.h"
#import "SpadeConstants.h"
#import "UIColor+FlatUI.h"

@interface SpadeFollowCell ()




@end

@implementation SpadeFollowCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}


-(void)awakeFromNib
{
    self.nameLabel.font = [UIFont fontWithName:@"Copperplate" size:16];
    self.dateAndTimeLabel.font  = [UIFont fontWithName:@"Copperplate-Light" size:12];
    self.followButton.cornerRadius = 3;
    self.followButton.titleLabel.font = [UIFont fontWithName:@"Copperplate-Bold" size:14];
    self.followButton.buttonColor = [UIColor wisteriaColor];
    self.followButton.shadowColor = [UIColor amethystColor];
    self.followButton.shadowHeight = 3;
    [self.followButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.followButton setTitleColor:[UIColor amethystColor] forState:UIControlStateHighlighted];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)followPressed:(UIButton *)button {
    [self.delegate followButtonWasPressedForCell:self];
}

#pragma mark { }


@end
