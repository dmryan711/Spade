//
//  SpadePhotoCell.h
//  Spade
//
//  Created by Devon Ryan on 1/14/14.
//  Copyright (c) 2014 Devon Ryan. All rights reserved.
//

#import "SpadeEventCell.h"
#import <Parse/Parse.h>

@protocol SpadePhotoCellDelegate;
@interface SpadePhotoCell : SpadeEventCell

@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (strong, nonatomic) PFFile *fileForEventImage;
@property (weak, nonatomic) IBOutlet PFImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UIProgressView *imageLoadBar;
@property (weak, nonatomic) id <SpadePhotoCellDelegate> delegate;

@end

@protocol SpadePhotoCellDelegate <NSObject>

@required
-(void)uploadPhotoButtonPressed;

@end