//
//  SpadeVenueFollowCell.m
//  Spade
//
//  Created by Devon Ryan on 12/28/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import "SpadeCache.h"
#import "SpadeConstants.h"
#import "SpadeVenueFollowCell.h"
#import "UIColor+FlatUI.h"

@implementation SpadeVenueFollowCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

-(void)awakeFromNib
{
    self.nameLabel.font = [UIFont fontWithName:@"Copperplate" size:16];
    self.addressLabel.font  = [UIFont fontWithName:@"Copperplate-Light" size:12];
    self.followButton.cornerRadius = 3;
    self.followButton.titleLabel.font = [UIFont fontWithName:@"Copperplate-Bold" size:12];
    self.followButton.buttonColor = [UIColor wisteriaColor];
    self.followButton.shadowColor = [UIColor amethystColor];
    self.followButton.shadowHeight = 0;
    [self.followButton setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
    [self.followButton setTitleColor:[UIColor amethystColor] forState:UIControlStateHighlighted];
    

}

/*- (void)setFrame:(CGRect)frame {
    frame.origin.x += 20;
    frame.size.width -= 40;
    [super setFrame:frame];
}*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (IBAction)followButtonPressed:(id)sender {
    [self.delegate followButtonWasPressedForCell:self];
}

@end
