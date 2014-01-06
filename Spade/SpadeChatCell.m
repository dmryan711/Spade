//
//  SpadeChatCell.m
//  Spade
//
//  Created by Devon Ryan on 1/5/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "SpadeChatCell.h"

@implementation SpadeChatCell

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
    self.textString.backgroundColor = [UIColor clearColor];
    [self.textString setTextColor:[UIColor whiteColor]];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
