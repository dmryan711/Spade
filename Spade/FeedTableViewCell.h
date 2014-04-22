//
//  FeedTableViewCell.h
//  Spade
//
//  Created by Devon Ryan on 4/16/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface FeedTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *eventCreator;
@property (weak, nonatomic) IBOutlet UILabel *venueTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *mainTItleLabel;

@end
