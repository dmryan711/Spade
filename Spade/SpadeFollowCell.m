//
//  SpadeFollowCell.m
//  Spade
//
//  Created by Devon Ryan on 12/26/13.
//  Copyright (c) 2013 Devon Ryan. All rights reserved.
//

#import "SpadeFollowCell.h"
#import "SpadeConstants.h"

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
    //self.backgroundColor = [UIColor blackColor];

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)followPressed:(UIButton *)button {
    [self.delegate  shouldToggleFollowButtonTitleforCell:self];
    
    [self.delegate followWasPressedWithTitle:button.titleLabel.text forObject:self.object];
}

#pragma mark { }


@end
