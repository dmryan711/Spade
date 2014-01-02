//
//  SpadeVenueFollowCell.h
//  Spade
//
//  Created by Devon Ryan on 12/28/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import "SpadeFollowCell.h"

@interface SpadeVenueFollowCell : SpadeFollowCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet PFImageView *venueImage;

@end