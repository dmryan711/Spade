//
//  SpadeSlideCell.h
//  Spade
//
//  Created by Devon Ryan on 4/22/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "RPSlidingMenuCell.h"

@interface SpadeSlideCell : RPSlidingMenuCell

/**
 The User Profile of the cell. If no Image is available , will use default
 */
@property (strong, nonatomic) PFImageView *userImage;

/** The Date label of the cell
 */
@property (strong, nonatomic) UILabel *dateLabel;

/** The Type Label of the cell
 */
@property (strong, nonatomic) UILabel *typeLabel;

@end
