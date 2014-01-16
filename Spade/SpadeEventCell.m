//
//  SpadeEventCell.m
//  Spade
//
//  Created by Devon Ryan on 1/8/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "SpadeEventCell.h"
@interface SpadeEventCell ()


@end

@implementation SpadeEventCell

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
    self.showCell = YES ;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
   // [self toggleShowCell];

}

-(void)toggleShowCell{

    if (self.showCell) {
        self.showCell = NO;
    }else{
        self.showCell = YES;
    
    }

}

@end
