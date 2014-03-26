//
//  SpadeMyEventsCell.m
//  Spade
//
//  Created by Devon Ryan on 1/20/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "UIColor+FlatUI.h"
#import "SpadeMyEventsCell.h"

@implementation SpadeMyEventsCell

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
    self.eventNameLabel.font = [UIFont fontWithName:@"Copperplate" size:16];
    self.dateAndTimeLabel.font  = [UIFont fontWithName:@"Copperplate-Light" size:12];
    self.attendeeCountLabel.font  = [UIFont fontWithName:@"Copperplate-Bold" size:12];
    self.attendeeCountLabel.textColor = [UIColor asbestosColor];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
