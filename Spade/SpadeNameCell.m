//
//  SpadeNameCell.m
//  Spade
//
//  Created by Devon Ryan on 1/11/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "SpadeNameCell.h"

@implementation SpadeNameCell

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
    self.nameEntry.keyboardAppearance = UIKeyboardAppearanceDark;
    self.nameLabel.hidden = YES;

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
