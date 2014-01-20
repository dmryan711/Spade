//
//  SpadeMyEventsCell.h
//  Spade
//
//  Created by Devon Ryan on 1/20/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SpadeMyEventsCell : UITableViewCell

@property (weak,nonatomic) IBOutlet PFImageView *eventImage;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;

@end
