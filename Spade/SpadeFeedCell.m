//
//  SpadeFeedCell.m
//  Spade
//
//  Created by Devon Ryan on 1/3/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "SpadeFeedCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation SpadeFeedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }

    return self;
}

- (void)setFrame:(CGRect)frame {
    frame.origin.x += 20;
    frame.size.width -= 40;
    [super setFrame:frame];
    
    [self.layer setCornerRadius:7.0f];
    [self.layer setMasksToBounds:YES];
    [self.layer setBorderWidth:2.0f];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
