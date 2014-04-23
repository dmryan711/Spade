//
//  SpadeSlideCell.m
//  Spade
//
//  Created by Devon Ryan on 4/22/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "SpadeSlideCell.h"
#import <QuartzCore/QuartzCore.h>

#define USER_IMAGE_WIDTH 64
#define USER_IMAGE_HEIGHT 61
#define USER_BUFFER_FROM_EDGE 20

@implementation SpadeSlideCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUpUserImage];
        self.detailTextLabel.backgroundColor = [UIColor blackColor];
        self.detailTextLabel.layer.cornerRadius = 4.0f;
    }
    return self;
}

-(void)setUpUserImage{
    self.userImage = [[PFImageView alloc]initWithFrame:CGRectMake((self.frame.size.width/2) - (USER_IMAGE_WIDTH/2),USER_BUFFER_FROM_EDGE , USER_IMAGE_WIDTH, USER_IMAGE_HEIGHT)];
    self.userImage.layer.cornerRadius = 10.0f;
    self.userImage.backgroundColor = [UIColor redColor];
    
    [self.contentView addSubview:self.userImage];
    

}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    CGFloat featureNormaHeightDifference = RPSlidingCellFeatureHeight - RPSlidingCellCollapsedHeight;
    
    // how much its grown from normal to feature
    CGFloat amountGrown = RPSlidingCellFeatureHeight - self.frame.size.height;
    
    // percent of growth from normal to feature
    CGFloat percentOfGrowth = 1 - (amountGrown / featureNormaHeightDifference);
    
    //Curve the percent so that the animations move smoother
    percentOfGrowth = sin(percentOfGrowth * M_PI_2);
    
    
    //keeo the image above the text lavel
    //self.userImage.center = CGPointMake(self.center.x, self.textLabel.center.y - (self.textLabel.frame.size.height/2) - 20);
    // scale title as it collapses but keep origin x the same and the y location proportional to view height.  Also fade in alpha
    self.userImage.alpha = percentOfGrowth * 1.7;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
