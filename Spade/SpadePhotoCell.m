//
//  SpadePhotoCell.m
//  Spade
//
//  Created by Devon Ryan on 1/14/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "SpadePhotoCell.h"


@implementation SpadePhotoCell

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
    
    self.imageLoadBar.hidden = YES;
    self.imageView.hidden = YES;
   // self.uploadButton.center = CGPointMake(320, 75);

}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(IBAction)uploadPhtoButtonPressed:(UIButton *)sender
{
    [self.delegate uploadPhotoButtonPressed];

}
@end
